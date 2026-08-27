import { LightningElement, track } from 'lwc';
import getObjectOptions from '@salesforce/apex/ObjectRecordTypeController.getObjectOptions';
import getRecordTypesByObject from '@salesforce/apex/ObjectRecordTypeController.getRecordTypesByObject';
import duplicateEmail from '@salesforce/apex/ObjectRecordTypeController.duplicateEmail';
import getFilteredRecords from '@salesforce/apex/ObjectRecordTypeController.getFilteredRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class FetchDuplicateEmails extends LightningElement {
    @track selectedObject = '';
    @track selectedRecordType = '';
    @track selectedYear = '';
    @track objectOptions = [];
    @track recordTypeOptions = [];
    isRecordTypeDisabled = true;
    @track fetchedData = [];
    @track allFetchedData = [];
    @track isLoading = false;
    @track noEmailsFound = false;
    xlsxJsLoaded = false;
    // @track duplicateEmails = [];
    @track currentPage = 1;
    @track recordsPerPage = 10;
    @track totalRecords = 0;
    @track isExporting = false;



    // @track yearOptions = [
    //     { label: '2025', value: '2025' },
    //     { label: '2024', value: '2024' },
    //     { label: '2023', value: '2023' },
    //     { label: '2022', value: '2022' },
    // ];

    //    @track isContact = false;
    // @track isAccount = false;
    connectedCallback() {
        this.loadObjects();


    }
    get yearOptions() {
        const currentYear = new Date().getFullYear();
        const years = [];
        for (let i = 0; i <= 10; i++) {
            years.push({
                label: `${currentYear - i}`,
                value: `${currentYear - i}`
            });
        }
        return years;
    }


    // duplicateEmail() {
    //     this.isLoading = true;
    //     this.noEmailsFound = false;
    //     this.fetchedData = [];
    //     duplicateEmail({ objectName: this.selectedObject, recordTypeId: this.selectedRecordType, yearOffset: parseInt(this.selectedYear) })
    //         .then(result => {
    //             if (result.length === 0) {
    //                 this.noEmailsFound = true;
    //             }
    //             console.log('year ' + this.selectedYear);
    //             console.log('Duplicate Emails:' + JSON.stringify(result.slice(0, 10)));
    //             console.log('Duplicate Emails:' + JSON.stringify(result.length));
    //             // this.fetchedData = result.slice(0, 10);
    //             this.allFetchedData = result;
    //             // this.totalRecords = result.length;
    //             this.totalRecords = result.length;
    //             if (this.totalRecords === 0) {
    //                 this.noEmailsFound = true;
    //             } else {
    //                 this.fetchedData = this.paginateData(result);
    //             }
    //             this.isLoading = false;

    //         }).catch(error => {
    //             this.isLoading= false;
    //             console.error('Error fetching duplicate emails:', error);
    //         });

    // }



    async duplicateEmail() {
        this.isLoading = true;
        this.noEmailsFound = false;
        this.fetchedData = [];

        try {
            // **Step 1: Fetch duplicate email records**
            const duplicateRecords = await duplicateEmail({
                objectName: this.selectedObject,
                recordTypeId: this.selectedRecordType,
                yearOffset: parseInt(this.selectedYear)
            });

            console.log('Duplicate Email Records:11 ->', duplicateRecords.length);

            let allFetchedDataVar = [...duplicateRecords];

            // **Step 2: If duplicateRecords reaches 50,000, fetch filtered records**
            if (duplicateRecords.length === 50000) {
                const duplicateRecordIds = duplicateRecords.map(record => record.Id);
                console.log('duplicateRecordIdsaa  --->', duplicateRecordIds);
                allFetchedDataVar = await this.fetchFilteredRecordsRecursively(duplicateRecordIds);
                console.log('allFetchedData Email Records:', allFetchedDataVar.length);
            }

            this.allFetchedData = allFetchedDataVar;
            this.totalRecords = this.allFetchedData.length;
            console.log('totalRecords ', this.totalRecords);
            console.log('allFetchedData ', this.allFetchedData);

            if (this.totalRecords === 0) {
                this.noEmailsFound = true;
            } else {
                this.fetchedData = this.paginateData(allFetchedDataVar);
            }

        } catch (error) {
            console.error('Error fetching records:', error);
        } finally {
            this.isLoading = false;
        }
    }


    async fetchFilteredRecordsRecursively(excludedIds) {
        console.log('Fetching additional records, Excluded IDs:', excludedIds.length);

        // Fetch next batch of filtered records
        const filteredRecords = await getFilteredRecords({
            objectName: this.selectedObject,
            recordTypeId: this.selectedRecordType,
            yearOffset: parseInt(this.selectedYear),
            excludeIds: excludedIds
        });

        console.log('Filtered Records Count:', filteredRecords.length);

        // Append new records
        this.allFetchedData.push(...filteredRecords);

        // If we still hit 50,000, continue fetching more
        if (filteredRecords.length === 50000) {
            const newExcludedIds = filteredRecords.map(record => record.Id);
            return this.fetchFilteredRecordsRecursively([...excludedIds, ...newExcludedIds]);
        }

        return this.allFetchedData;
    }




    handleYearChange(event) {
        this.selectedYear = event.detail.value;
        //  if (this.selectedYear) {
        //     this.duplicateEmail();
        // }
    }

    loadObjects() {
        getObjectOptions()
            .then((data) => {
                this.objectOptions = data.map(item => ({
                    label: item.label,
                    value: item.value
                }));
            })
            .catch((error) => {
                console.error('Error loading objects:', error);
            });
    }
    paginateData(data) {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = start + this.recordsPerPage;
        return data.slice(start, end);
    }
    handleNext() {
        if (this.currentPage < Math.ceil(this.totalRecords / this.recordsPerPage)) {
            this.currentPage += 1;
            this.duplicateEmail();
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.duplicateEmail();
        }
    }
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage >= Math.ceil(this.totalRecords / this.recordsPerPage);
    }


    handleObjectChange(event) {
        this.selectedObject = event.detail.value;
        this.selectedRecordType = '';
        this.isRecordTypeDisabled = !this.selectedObject;

        //   this.isContact = this.selectedObject === 'Contact';
        // this.isAccount = this.selectedObject === 'Account';
        if (this.selectedObject) {
            this.loadRecordTypes();
        }
    }

    loadRecordTypes() {
        getRecordTypesByObject({ objectName: this.selectedObject })
            .then((data) => {
                this.recordTypeOptions = data.map(item => ({
                    label: item.label,
                    value: item.value
                }));
            })
            .catch((error) => {
                console.error('Error loading record types:', error);
            });
    }

    handleRecordTypeChange(event) {
        this.selectedRecordType = event.detail.value;
    }
    handleExport() {
        this.duplicateEmail();
    }

    handleExportToExcel() {
        this.isExporting = true;
        this.exportContactData();
        console.log('Button clicked');
    }

    showToast(message, variant) {
        const evt = new ShowToastEvent({
            title: 'Export Successful',
            message: message,
            variant: variant,
            mode: 'dismissable',
        });
        this.dispatchEvent(evt);
    }

    exportContactData() {
        try {
            let csvContent = "Email,Id,FirstName,LastName,Contact_Domain__c,RecordTypeId,Web_Id__c,Contact_Status__c,Verified,LastModifiedDate,CreatedDate,AccountId,Account Name\n";

            // Loop through each record and create a CSV row
            this.allFetchedData.forEach(record => {

                let accName = record.Account != undefined ? record.Account.Name : '';
                csvContent += `${record.Email},${record.Id},${record.FirstName},${record.LastName},${record.Contact_Domain__c},${record.RecordTypeId},${record.Web_Id__c},${record.Contact_Status__c},${record.Verified__c},${record.LastModifiedDate},${record.CreatedDate},${record.AccountId},${accName},\n`;
            });

            console.log(JSON.stringify(this.allFetchedData[0]));


            var element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            let downloadElement = document.createElement('a');
            downloadElement.href = element;
            downloadElement.target = '_self';
            downloadElement.download = 'DuplicateData.csv';
            document.body.appendChild(downloadElement);
            downloadElement.click();

            window.setTimeout(() => {
                this.isExporting = false;
                this.showToast('Your data has been successfully exported!', 'success');
            }, 1500);
        } catch (error) {
            this.isExporting = false; // Hide spinner if an error occurs
            console.error('Error exporting data:', error);
            this.showToast('An error occurred while exporting data. Please try again.', 'error'); // Show error toast
        }
        //   this.showToast('Your data has been successfully exported!', 'success');
    }



}