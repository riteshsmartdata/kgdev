import { LightningElement, api, wire, track } from 'lwc';
import getCasesForEbsOrder from '@salesforce/apex/EbsOrderCaseController.getCasesForEbsOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Columns for the data table with sortable attribute
const columns = [
    {
        label: 'Case Number', fieldName: 'caseLink', type: 'url',
        typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' },
        sortable: true
    },
    { label: 'Subject', fieldName: 'Subject', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
    { label: 'Record Type', fieldName: 'recordTypeName', type: 'text', sortable: true },
    { label: 'Case Reason Type', fieldName: 'Case_Reason_Type__c', type: 'text', sortable: true }
];

export default class EbsOrderRelatedCasesShowInDataTable extends LightningElement {
    @api recordId;
    @track cases = [];
    @track error;
    page = 1;
    items = [];
    data = [];
    columns = columns;
    sortedBy;
    sortDir = 'asc';
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 5;
    totalRecountCount = 0;
    totalPage = 0;
    tabelShowHide = false;
    @track isLoading = false; // Spinner control

    @wire(getCasesForEbsOrder, { caseId: '$recordId' })
    wiredCases({ error, data }) {
        console.log('error.error=====> ', error);
        console.log('data.data=====> ', data);
        this.isLoading = true; // Show spinner
        if (data) {
            console.log('this.datadata=====> ', data);
            this.items = data.map(caseRecord => ({
                ...caseRecord,
                caseLink: `/${caseRecord.Id}`,
                recordTypeName: caseRecord.RecordType ? caseRecord.RecordType.Name : ''
            }));

            this.totalRecountCount = data.length;
            this.tabelShowHide = data.length > 0;
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
            this.displayRecordPerPage(this.page);
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            this.tabelShowHide = false;
            this.isLoading = false;
            this.error = error;
            this.data = undefined;
            console.log('this.error=====> ', this.error);
            this.showToast(this.error, 'Error', 'Error');
        }
    }

    previousHandler() {
        if (this.page > 1) {
            this.page -= 1;
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
        if (this.page < this.totalPage) {
            this.page += 1;
            this.displayRecordPerPage(this.page);
        }
    }

    displayRecordPerPage(page) {
        this.startingRecord = (page - 1) * this.pageSize;
        this.endingRecord = Math.min(page * this.pageSize, this.totalRecountCount);
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord += 1;
    }

    updateSort(event) {
        let fieldName = event.detail.fieldName;
        fieldName = fieldName === 'caseLink' ? 'CaseNumber' : fieldName;
        let sortDirection = event.detail.sortDirection;
        this.sortedBy = fieldName;
        this.sortDir = sortDirection;
        let reverse = sortDirection !== "asc";
        let data_clone = JSON.parse(JSON.stringify(this.data));
        this.data = data_clone.sort(this.sortData(fieldName, reverse));
        // keep this line at the end to reset the name field back to url so we get the sort diections.
        this.sortedBy = event.detail.fieldName;;
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

    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    // Getter to display the name of the sorted field
    get sortByLabel() {
        switch (this.sortedBy) {
            case 'caseLink':
                return 'Case Number';
            case 'Subject':
                return 'Subject';
            case 'Status':
                return 'Status';
            case 'recordTypeName':
                return 'Record Type';
            case 'Case_Reason_Type__c':
                return 'Case Reason Type';
            default:
                return 'Created Date';
        }
    }
}