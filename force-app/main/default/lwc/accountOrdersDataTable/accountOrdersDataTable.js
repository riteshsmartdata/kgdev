import { LightningElement, api, wire, track } from 'lwc';
import getAccountOrders from '@salesforce/apex/AccountSampleOrdersController.getAccountOrders';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns = [
    { label: 'Name', fieldName: 'accLink', type: 'url', sortable: true, 
      typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } 
    },
    { label: 'EBS Order Number', fieldName: 'EBSOrderNumber', type: 'text', sortable: true },
    { label: 'External Product Name', fieldName: 'ExternalProductName', type: 'text', sortable: true },
    { label: 'Effective Date', fieldName: 'EffectiveDate', type: 'date', 
      sortable: true, typeAttributes: { day: '2-digit', month: '2-digit', year: 'numeric',
      hour: '2-digit', minute: '2-digit', hour12: true }
    },
    { label: 'Order Header Total', fieldName: 'OrderHeaderTotal', type: 'number', sortable: true },
    { label: 'Order Header Status', fieldName: 'OrderHeaderStatus', type: 'text', sortable: true },
    { label: 'Customer PO', fieldName: 'CustomerPO', type: 'text', sortable: true },
    { label: 'Incl in Samples Journey?', fieldName: 'Incl_in_Samples_Journey',  sortable: true    }
];


export default class accountOrdersDataTable extends LightningElement {
    @api recordId;
    @track orders;
    @track error;
    @track sortedBy;
    @track sortedDirection;
    columns = columns;
    page = 1;
    items = [];
    data = [];
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
    totalRecountCount = 0;
    totalPage = 0;
    @track isLoading = false;

    connectedCallback() {
        console.log('recordId--->', this.recordId);
    }

    @wire(getAccountOrders, { accountId: '$recordId' })
    wiredOrders({ error, data }) {
        this.isLoading = true;
        if (data) {
            data = JSON.parse(JSON.stringify(data));
            data.forEach(res => {
                res.accLink = '/' + res.Id;
            });
            this.items = data;
            // console.log('data--->', data);
          //  console.log('data--->', JSON.stringify(data));
            this.isLoading = false;
            this.totalRecountCount = data.length;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.data = this.items.slice(0, this.pageSize);
            this.endingRecord = this.pageSize;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.isLoading = false;
            this.data = undefined;
            this.showToast(this.error, 'Error', 'Error');
        }
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if (this.page < this.totalPage && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {
        this.startingRecord = (page - 1) * this.pageSize;
        this.endingRecord = this.pageSize * page;
        this.endingRecord = this.endingRecord > this.totalRecountCount ? this.totalRecountCount : this.endingRecord;
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
            function (x) {
                return primer(x[field]);
            } :
            function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}