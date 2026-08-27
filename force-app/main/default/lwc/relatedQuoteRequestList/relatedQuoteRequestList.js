import { LightningElement, api, wire, track } from 'lwc';
import getRelatedQuoteRequests from '@salesforce/apex/RelatedQuoteRequestsController.getRelatedQuoteRequests';
import { NavigationMixin } from 'lightning/navigation';

export default class RelatedQuoteRequests extends NavigationMixin(LightningElement) {
    @api recordId; // Opportunity Id
    @track quoteRequests;

    @wire(getRelatedQuoteRequests, { opportunityId: '$recordId' })
    wiredQuoteRequests({ error, data }) {
        if (data) {
            this.quoteRequests = data;
        } else if (error) {
            console.error(error);
        }
    }

    get quoteRequestsLength() {
       // return this.quoteRequests ? this.quoteRequests.length : 0;
    }

    handleQuoteClick(event) {
        const quoteId = event.currentTarget.dataset.quoteId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });
    }
}