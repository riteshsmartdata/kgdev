import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEmailBatch from '@salesforce/apex/CaseEmailExportController.getEmailBatch';
import getEmailFieldLabels from '@salesforce/apex/CaseEmailExportController.getEmailFieldLabels';

export default class EmailExportPagination extends LightningElement {
    @track isLoading = false;
    limitValue = 500;
    fieldLabels = {};
    selectedRecordType;

    recordTypeOptions = [
        { label: 'RT Case', value: 'RT Case' },
        { label: 'Claims', value: 'Claims' },
        { label: 'Delayed Order', value: 'Delayed Order' },
        { label: 'Inside Sales', value: 'Inside Sales' },
        { label: 'Clarification', value: 'Clarification' },
        { label: 'Case', value: 'Case' },
    ];

    connectedCallback() {
        getEmailFieldLabels()
            .then(result => {
                this.fieldLabels = result;
                this.fieldLabels['casenumber'] = 'Case Number';
            })
            .catch(error => {
                console.error('Error loading field labels', error);
            });
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
    }

    handleExportClick() {
        if (!this.selectedRecordType) {
            this.showToast('Error', 'Please select a Record Type before exporting.', 'error');
            return;
        }

        if (Object.keys(this.fieldLabels).length === 0) {
            this.showToast('Error', 'Field labels are still loading. Please try again in a moment.', 'error');
            return;
        }

        this.exportEmails(this.selectedRecordType);
    }

    async exportEmails(recordTypeName) {
        this.isLoading = true;
        let csvRows = [];
        let headers = [];
        let lastId = null;
        let lastCreatedDate = null;
        let totalRecords = 0;
        let headersSet = false;

        try {
            while (true) {
                const batch = await getEmailBatch({
                    lastId,
                    lastCreatedDate,
                    limitValue: this.limitValue,
                    recordTypeName
                });

                if (batch.length === 0) break;

                totalRecords += batch.length;

                batch.forEach(row => {
                    if (row.Parent) {
                        row.CaseNumber = row.Parent.CaseNumber;
                        delete row.Parent;
                    }

                    delete row.HtmlBody;

                    if (row.TextBody) {
                        row.TextBody = row.TextBody.replace(/[\r\n]+/g, ' ');
                    }

                    if (!headersSet) {
                        headers = Object.keys(row);

                        const headerLabels = headers.map(h => {
                            const lowerKey = h.toLowerCase();
                            return this.fieldLabels[lowerKey] ? this.fieldLabels[lowerKey] : h;
                        });

                        csvRows.push(headerLabels.map(h => `"${h}"`).join(','));
                        headersSet = true;
                    }

                    const values = headers.map(key => {
                        let val = row[key] !== undefined ? row[key] : '';
                        if (typeof val === 'string') {
                            val = val.replace(/"/g, '""'); // Escape quotes
                            val = val.replace(/[\r\n]+/g, ' '); // Remove newlines
                            val = `"${val}"`; // Wrap in quotes
                        }
                        return val;
                    });

                    csvRows.push(values.join(','));
                });

                await new Promise(resolve => setTimeout(resolve, 50));

                const lastRecord = batch[batch.length - 1];
                lastId = lastRecord.Id;
                lastCreatedDate = lastRecord.CreatedDate;
            }

            if (totalRecords > 0) {
                const csvContent = csvRows.join('\n');
                this.downloadCSV(csvContent, `${recordTypeName}_Emails.csv`);
                this.showToast('Success', `Export completed. Total ${totalRecords} emails downloaded.`, 'success');
            } else {
                this.showToast('Info', 'No emails found for the selected Record Type.', 'info');
            }

        } catch (error) {
            console.error('Error exporting emails:', error);
            this.showToast('Error', 'Something went wrong while exporting emails.', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    downloadCSV(csvContent, filename) {
        const element = document.createElement('a');
        element.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        element.download = filename;
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}