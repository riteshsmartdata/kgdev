import { LightningElement, api, wire, track } from 'lwc';
import getOpenCases from '@salesforce/apex/OpenContactCasesController.getOpenCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpenContactCases extends LightningElement {
    @api recordId;
    @track cases = [];
    @track error;
    page = 1;
    items = [];
    data = [];
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
    totalRecountCount = 0;
    totalPage = 0;
    tabelShowHide = false;
    @track isLoading = false;

    columns = [
        {
        label: 'Case Number', fieldName: 'caseLink', type: 'url',
        typeAttributes: { label: { fieldName: 'CaseNumber' }, target: '_blank' }    },
        { label: 'Subject', fieldName: 'Subject', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Record Type', fieldName: 'RecordTypeName', type: 'text' },
        { label: 'Case Reason Type', fieldName: 'Case_Reason_Type__c', type: 'text' },
        { label: 'EBS Order Number', fieldName: 'EBS_Order_Number__c', type: 'text' },
        { label: 'PO Number', fieldName: 'PO_Number__c', type: 'text' }
    ];

    @wire(getOpenCases, { recordId: '$recordId' })
    wiredCases({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.items = data.map(caseRecord => ({
                ...caseRecord,
                caseLink: `/${caseRecord.Id}`,
                RecordTypeName: caseRecord.RecordType?.Name
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
            this.cases = undefined;
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
        this.cases = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord += 1;
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

}