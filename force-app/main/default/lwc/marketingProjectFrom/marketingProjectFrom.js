import { LightningElement, track, wire, api } from 'lwc';
import createMarketingProject from '@salesforce/apex/MarketingProjectController.createMarketingProject';

export default class MarketingProjectFrom extends LightningElement {
    @track showSpinner = false;
    @track today;
    @track error;

    selectedStatus = 'Project Submitted';
    statusOptions = [
        { label: 'Created', value: 'Created' },
        { label: 'Project Submitted', value: 'project_submitted' },
        { label: 'First Draft Routing', value: 'First Draft' },
        { label: 'On-Hold', value: 'On-Hold' },
        { label: 'Complete', value: 'Complete' },
        { label: 'Cancelled', value: 'Cancelled' },
        { label: 'Project Assigned', value: 'Project_Assigned' }
        // Add more options as needed based on the picklist values
    ];
    BusinessUnits = '';
    BusinessUnitsOptions = [
        { label: 'KG', value: 'KG' },
        { label: 'MCM', value: 'MCM' },
        { label: 'IB', value: 'IB' },
        { label: 'All', value: 'All' }
    ];
    sharePointReviewComplete = '';
    SharePointReviewCompleteOptions = [
        { label: 'No', value: 'No' },
        { label: 'Yes', value: 'Yes' }
    ];
    teamRequestingProject = '';
    teamRequestingProjectOptions = [
        { label: 'Sales', value: 'Sales' },
        { label: 'HR', value: 'HR' },
        { label: 'IT', value: 'IT' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Other', value: 'Other' },
        { label: 'Marketing', value: 'Marketing' }
    ];
    projectType = '';
    projectTypeOptions = [
        { label: 'Booklet', value: 'Booklet' },
        { label: 'Brochure-Calendar', value: 'Brochure' },
        { label: 'Catalog', value: 'Catalog' },
        { label: 'Digital Ads', value: 'Digital Ads' },
        { label: 'Photography', value: 'Photography' },
        { label: 'Print Ads', value: 'Print Ad' },
        { label: 'Postcard', value: 'Postcard' },
        { label: 'Social/Blog/Newsletter Image', value: 'Newsletter' },
        { label: 'Virtual', value: 'Virtual' },
        { label: 'Other', value: 'Other' },
        { label: 'Flyer', value: 'eFlyer' }
    ];
    brandedUnbranded = '';
    brandedUnbrandedOptions = [
        { label: 'Branded', value: 'Branded' },
        { label: 'Unbranded', value: 'Unbranded' },
        { label: 'Both', value: 'Both' }
    ];
    uSCanada = '';
    uSCanadaOptions = [
        { label: 'US', value: 'US' },
        { label: 'Canada', value: 'Canada' },
        { label: 'Both', value: 'Both' }
    ];
    pricingforItems = '';
    pricingforItemsOptions = [
        { label: 'Catalog', value: 'Catalog' },
        { label: 'EQP', value: 'EQP' },
        { label: 'Other - Please Specify', value: 'Other - Please Specify' }
    ];
    typeofFile = '';
    typeofFileOptions = [
        { label: 'ai', value: 'ai' },
        { label: 'eps', value: 'eps' },
        { label: 'InDesign', value: 'InDesign' },
        { label: 'jpg', value: 'jpg' },
        { label: 'PDF', value: 'PDF' },
        { label: 'PNG', value: 'PNG' },
        { label: 'Other / Multiple', value: 'Other' }
    ];


    marketingProjectName = '';
    requestingTeam = '';
    otherType = '';
    projectSubmissionDate = this.today;
    firstDraftDueDate;
    finalCompletionDate;
    projectPurposeAndOpportunity;
    featuredProduct;
    pricingIfPleaseSpecify = '';
    brandLogos = '';
    attitudeStyleandtone = '';
    additionalPieces = '';
    listProduct = '';
    typeofFileNeeded = '';
    objective = '';
    sizeofFile = '';
    message = '';
    reviewer = '';
    sizeofImageFile = '';
    pagesNeeded;
    effectiveDate;
    expirationDate;
    sharePoint;
    references;
    ownersubmitted;
    promoCode;
    submitterEmail;
    reviewer1;
    reviewer2;
    reviewer3;
    reviewer4;

    connectedCallback() {
        // Get today's date and format it to YYYY-MM-DD
        const date = new Date();
        const year = date.getFullYear();
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const day = date.getDate().toString().padStart(2, '0');
        this.today = `${year}-${month}-${day}`;
        this.projectSubmissionDate = this.today;
        console.log('projectSubmissionDate kkk--> ', this.projectSubmissionDate);
    }


    handleInputChange(event) {
        const fieldName = event.target.name;
        if (fieldName === 'marketingProjectName') {
            this.marketingProjectName = event.target.value;
        } else if (fieldName === 'selectedStatus') {
            this.selectedStatus = event.target.value;
        } else if (fieldName === 'BusinessUnits') {
            this.BusinessUnits = event.target.value;
        } else if (fieldName === 'sharePointReviewComplete') {
            this.sharePointReviewComplete = event.target.value;
        } else if (fieldName === 'teamRequestingProject') {
            this.teamRequestingProject = event.target.value;
        } else if (fieldName === 'requestingTeam') {
            this.requestingTeam = event.target.value;
        } else if (fieldName === 'projectType') {
            this.projectType = event.target.value;
        } else if (fieldName === 'otherType') {
            console.log('OtherType1-->', this.otherType);
            this.otherType = event.target.value;
        } else if (fieldName === 'projectSubmissionDate') {
            this.projectSubmissionDate = event.target.value;
        } else if (fieldName === 'firstDraftDueDate') {
            this.firstDraftDueDate = event.target.value;
        } else if (fieldName === 'finalCompletionDate') {
            this.finalCompletionDate = event.target.value;
        } else if (fieldName === 'projectPurposeAndOpportunity') {
            this.projectPurposeAndOpportunity = event.target.value;
        } else if (fieldName === 'brandedUnbranded') {
            this.brandedUnbranded = event.target.value;
        } else if (fieldName === 'featuredProduct') {
            this.featuredProduct = event.target.value;
        } else if (fieldName === 'uSCanada') {
            this.uSCanada = event.target.value;
        } else if (fieldName === 'pricingIfPleaseSpecify') {
            this.pricingIfPleaseSpecify = event.target.value;
        } else if (fieldName === 'brandLogos') {
            this.brandLogos = event.target.value;
        } else if (fieldName === 'attitudeStyleandtone') {
            this.attitudeStyleandtone = event.target.value;
        } else if (fieldName === 'pricingforItems') {
            this.pricingforItems = event.target.value;
        } else if (fieldName === 'additionalPieces') {
            this.additionalPieces = event.target.value;
        } else if (fieldName === 'listProduct') {
            this.listProduct = event.target.value;
        } else if (fieldName === 'typeofFileNeeded') {
            this.typeofFileNeeded = event.target.value;
        } else if (fieldName === 'objective') {
            this.objective = event.target.value;
        } else if (fieldName === 'sizeofFile') {
            this.sizeofFile = event.target.value;
        } else if (fieldName === 'message') {
            this.message = event.target.value;
        } else if (fieldName === 'reviewer') {
            this.reviewer = event.target.value;
        } else if (fieldName === 'typeofFile') {
            this.typeofFile = event.target.value;
        } else if (fieldName === 'sizeofImageFile') {
            this.sizeofImageFile = event.target.value;
        } else if (fieldName === 'pagesNeeded') {
            this.pagesNeeded = event.target.value;
        } else if (fieldName === 'effectiveDate') {
            this.effectiveDate = event.target.value;
        } else if (fieldName === 'expirationDate') {
            this.expirationDate = event.target.value;
        } else if (fieldName === 'sharePoint') {
            this.sharePoint = event.target.value;
        } else if (fieldName === 'references') {
            this.references = event.target.value;
        } else if (fieldName === 'reviewer') {
            this.reviewer = event.target.value;
        } else if (fieldName === 'ownersubmitted') {
            this.ownersubmitted = event.target.value;
        } else if (fieldName === 'promoCode') {
            this.promoCode = event.target.value;
        } else if (fieldName === 'submitterEmail') {
            this.submitterEmail = event.target.value;
        } else if (fieldName === 'reviewer1') {
            this.reviewer1 = event.target.value;
        } else if (fieldName === 'reviewer2') {
            this.reviewer2 = event.target.value;
        } else if (fieldName === 'reviewer3') {
            this.reviewer3 = event.target.value;
        } else if (fieldName === 'reviewer4') {
            this.reviewer4 = event.target.value;
        } 
    }


    async handleSave() {
        if (this.handleValidation()) {
            this.showSpinner = true;
            console.log('Save Button');
            console.log('OtherType2-->', this.otherType);
            // Call the Apex method to create the Marketing Project record
            const params = {
                projectName: this.marketingProjectName,
                status: this.selectedStatus,
                BusinessUnits: this.BusinessUnits,
                SharePointReviewComplete: this.sharePointReviewComplete,
                teamRequestingProject: this.teamRequestingProject,
                requestingTeam: this.requestingTeam,
                projectType: this.projectType,
                otherType: this.otherType,
                projectSubmissionDate: this.projectSubmissionDate,
                firstDraftDueDate: this.firstDraftDueDate,
                finalCompletionDate: this.finalCompletionDate,
                projectPurposeAndOpportunity: this.projectPurposeAndOpportunity,
                brandedUnbranded: this.brandedUnbranded,
                featuredProduct: this.featuredProduct,
                uSCanada: this.uSCanada,
                pricingIfPleaseSpecify: this.pricingIfPleaseSpecify,
                brandLogos: this.brandLogos,
                attitudeStyleandtone: this.attitudeStyleandtone,
                pricingforItems: this.pricingforItems,
                additionalPieces: this.additionalPieces,
                listProduct: this.listProduct,
                typeofFileNeeded: this.typeofFileNeeded,
                objective: this.objective,
                sizeofFile: this.sizeofFile,
                message: this.message,
                reviewer: this.reviewer,
                typeofFile: this.typeofFile,
                sizeofImageFile: this.sizeofImageFile,
                pagesNeeded: this.pagesNeeded,
                effectiveDate: this.effectiveDate,
                expirationDate: this.expirationDate,
                sharePoint: this.sharePoint,
                references: this.references,
                ownersubmitted: this.ownersubmitted,
                promoCode: this.promoCode,
                submitterEmail: this.submitterEmail,
                reviewer1: this.reviewer1,
                reviewer2: this.reviewer2,
                reviewer3: this.reviewer3,
                reviewer4: this.reviewer4

            };
            console.log('params ->', params);
            createMarketingProject({ params: params })
                .then(result => {
                    this.showSpinner = false;
                    console.log('result11aaq', result.status);
                    console.log('Id----> ', result.Id);
                    this.error = false;
                    alert('Your marketing project has been submitted! Please check your email for the marketing project number. Thanks!');
                    this.refreshValue();
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.error = true;
                    console.log('error', error);
                   // this.refreshValue();
                });

        } else {

            console.log('Validation failed');
        }
    }

    handleValidation() {
        let isValid = true; // Initialize the variable to true

        // Get references to the input fields using querySelector
        let projectNameInput = this.template.querySelector(".nameCls");
        let projectSubmissionDateInput = this.template.querySelector(".projectSubmissionDateCls");
        let finalCompletionDateInput = this.template.querySelector(".finalCompletionDateCls");
        let firstDraftDueDateInput = this.template.querySelector(".firstDraftDueDateCls");
        let objectiveInput = this.template.querySelector(".objectiveCls");
        let reviewerInput = this.template.querySelector(".reviewerCls");
        let expirationDateInput = this.template.querySelector(".expirationDateCls");
        let sharePointReviewCompleteInput = this.template.querySelector(".sharePointReviewCompleteCls");
        let teamRequestingProjectInput = this.template.querySelector(".teamRequestingProjectCls");
        let projectTypeInput = this.template.querySelector(".projectTypeCls");
        let brandedUnbrandedInput = this.template.querySelector(".brandedUnbrandedCls");
        let uSCanadaInput = this.template.querySelector(".uSCanadaCls");
        let submitterEmailInput = this.template.querySelector(".EmailCls");
        let requestingTeamInput = this.template.querySelector(".requestingTeamCls");

        // Check if any of the required fields are empty
        if (!projectNameInput.value || !projectSubmissionDateInput.value || !finalCompletionDateInput.value || !firstDraftDueDateInput.value || !objectiveInput.value || !reviewerInput.value || !expirationDateInput.value || !sharePointReviewCompleteInput.value || !teamRequestingProjectInput.value || !projectTypeInput.value || !brandedUnbrandedInput.value || !uSCanadaInput.value) {
            isValid = false; // Update isValid to false if any validation fails
        }
        console.log('teamRequestingProject.value--->', teamRequestingProjectInput.value);
        console.log('requestingTeamInput--->', requestingTeamInput.value);
        if(teamRequestingProjectInput.value === 'Other' && requestingTeamInput.value === ''){
            requestingTeamInput.setCustomValidity("Please specify Other Team");
            isValid = false;
        } else {
            requestingTeamInput.setCustomValidity(""); // Clear any previous validation message
        }

        // Check if First Draft Due Date is within 9 days after Project Submission Date
        const submissionDate = new Date(this.today);
        const draftDueDate = new Date(firstDraftDueDateInput.value);
        const nineDaysAfterSubmission = new Date(submissionDate);
        nineDaysAfterSubmission.setDate(submissionDate.getDate() + 10);

        if (draftDueDate < nineDaysAfterSubmission) {
            firstDraftDueDateInput.setCustomValidity("Date must be a minimum of 7-working days");
            isValid = false;
        } else {
            firstDraftDueDateInput.setCustomValidity(""); // Clear any previous validation message
        }

        // Set custom validity for each field if empty
        projectNameInput.setCustomValidity(projectNameInput.value ? "" : "Marketing Project Name is required");
        projectSubmissionDateInput.setCustomValidity(projectSubmissionDateInput.value ? "" : "Project Submission Date is required");
        finalCompletionDateInput.setCustomValidity(finalCompletionDateInput.value ? "" : "Final Completion Date is required");
        objectiveInput.setCustomValidity(objectiveInput.value ? "" : "Objective is required");
        reviewerInput.setCustomValidity(reviewerInput.value ? "" : "Reviewer is required");
        expirationDateInput.setCustomValidity(expirationDateInput.value ? "" : "Expiration Date is required");
        sharePointReviewCompleteInput.setCustomValidity(sharePointReviewCompleteInput.value ? "" : "Share Point Review Complete is required");
        teamRequestingProjectInput.setCustomValidity(teamRequestingProjectInput.value ? "" : "Team Requesting Project is required");
        projectTypeInput.setCustomValidity(projectTypeInput.value ? "" : "Project Type is required");
        //firstDraftDueDateInput.setCustomValidity(firstDraftDueDateInput.value ? "" : "First Draft Due Date is required");
        brandedUnbrandedInput.setCustomValidity(brandedUnbrandedInput.value ? "" : "Branded/Unbranded is required");
        uSCanadaInput.setCustomValidity(uSCanadaInput.value ? "" : "US/Canada is required");
        submitterEmailInput.setCustomValidity(submitterEmailInput.value ? "" : "Submitter Email is required");

        // Report validity to show the error message
        projectNameInput.reportValidity();
        projectSubmissionDateInput.reportValidity();
        finalCompletionDateInput.reportValidity();
        objectiveInput.reportValidity();
        reviewerInput.reportValidity();
        expirationDateInput.reportValidity();
        sharePointReviewCompleteInput.reportValidity();
        teamRequestingProjectInput.reportValidity();
        requestingTeamInput.reportValidity();
        projectTypeInput.reportValidity();
        firstDraftDueDateInput.reportValidity();
        brandedUnbrandedInput.reportValidity();
        uSCanadaInput.reportValidity();
        submitterEmailInput.reportValidity();

        return isValid;
    }

    refreshValue() {
        console.log('refreshValue');
        this.marketingProjectName = '';
        this.BusinessUnits = '';
        this.sharePointReviewComplete = '';
        this.teamRequestingProject = '';
        this.projectType = '';
        this.requestingTeam = '';
        this.otherType = '';
        this.firstDraftDueDate = null;
        this.finalCompletionDate = null;
        this.projectPurposeAndOpportunity = '';
        this.brandedUnbranded = '';
        this.featuredProduct = '';
        this.uSCanada = '';
        this.pricingIfPleaseSpecify = '';
        this.brandLogos = '';
        this.attitudeStyleandtone = '';
        this.pricingforItems = '';
        this.additionalPieces = '';
        this.listProduct = '';
        this.typeofFileNeeded = '';
        this.objective = '';
        this.sizeofFile = '';
        this.message = '';
        this.reviewer = '';
        this.typeofFile = '';
        this.sizeofImageFile = '';
        this.pagesNeeded = null;
        this.effectiveDate = null;
        this.expirationDate = null;
        this.sharePoint = '';
        this.references = '';
        this.ownersubmitted = '';
        this.promoCode = '';
        this.submitterEmail = '';
        this.reviewer1 = '';
        this.reviewer2 = '';
        this.reviewer3 = '';
        this.reviewer4 = '';
    }
}