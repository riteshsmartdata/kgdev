import { LightningElement, wire, track } from 'lwc';
import getEmailMessagesFromEbsOrder from '@salesforce/apex/EbsOrderEmailMessageController.getEmailMessagesFromEbsOrder';
import { CurrentPageReference } from 'lightning/navigation';

const columns = [
    {
        label: 'Subject',
        fieldName: 'accLink',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Subject' }, target: '_blank' },
        sortable: true
    },
    { label: 'From', fieldName: 'FromAddress', type: 'email', sortable: true },
    { label: 'To', fieldName: 'ToAddress', type: 'email', sortable: true },
    { label: 'Text Body', fieldName: 'TextBody', type: 'text', sortable: true },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true }
];

export default class EbsOrderEmailMessages extends LightningElement {
    @track emailMessages = [];
    @track error;
    recordId;
    @track dataTableShowHide = false;
    @track isLoading = false; // Spinner control
    page = 1;
    items = [];
    data = [];
    columns = columns;
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 5;
    totalRecountCount = 0;
    totalPage = 0;
    sortBy;
    sortDir;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId;
            this.loadEmailMessages();
        }
    }

    loadEmailMessages() {
        this.isLoading = true; // Show spinner
        getEmailMessagesFromEbsOrder({ ebsOrderId: this.recordId })
            .then(result => {
                this.emailMessages = result.map(res => ({
                    ...res,
                    accLink: '/' + res.Id,
                    Subject: res.Subject
                }));

                this.items = this.emailMessages;
                this.totalRecountCount = result.length;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.emailMessages = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;
                this.error = undefined;
                this.dataTableShowHide = this.emailMessages.length > 0;
            })
            .catch(error => {
                this.error = error;
                this.dataTableShowHide = false;
            })
            .finally(() => {
                this.isLoading = false; // Hide spinner after loading
            });
    }

    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.emailMessages = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    updateSort(event) {
        let fieldName = event.detail.fieldName;
        fieldName = fieldName === 'accLink' ? 'Subject' : fieldName;
        let sortDirection = event.detail.sortDirection;
        this.sortBy = fieldName;
        this.sortDir = sortDirection;
        let reverse = sortDirection !== "asc";
        let data_clone = JSON.parse(JSON.stringify(this.emailMessages));
        this.emailMessages = data_clone.sort(this.sortData(fieldName, reverse));
        this.sortBy = event.detail.fieldName;
    }

    sortData(field, reverse, primer) {
        var key = function (x) {
            return primer ? primer(x[field]) : x[field];
        };
        return function (a, b) {
            var A = key(a),
                B = key(b);
            if (A === undefined) A = "";
            if (B === undefined) B = "";
            return (A < B ? -1 : A > B ? 1 : 0) * [1, -1][+!!reverse];
        };
    }

    get emailMessageCount() {
        return this.emailMessages ? this.emailMessages.length : 0;
    }

    get formattedTitle() {
        const count = this.totalRecountCount;
        return count > 0 ? `Email Messages (${count})` : 'Email Messages (0)';
    }

    get sortByLabel() {
        switch (this.sortBy) {
            case 'accLink':
                return 'Subject';
            case 'FromAddress':
                return 'From';
            case 'ToAddress':
                return 'To';
            case 'TextBody':
                return 'Text Body';
            default:
                return 'Created Date';
        }
    }
}