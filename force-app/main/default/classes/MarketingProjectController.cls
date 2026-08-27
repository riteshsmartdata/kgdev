public class MarketingProjectController {
    
    public class MarketingProjectWrapper {
        @AuraEnabled public String projectName { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String businessUnits { get; set; }
        @AuraEnabled public String sharePointReviewComplete { get; set; }
        @AuraEnabled public String teamRequestingProject { get; set; }
        @AuraEnabled public String requestingTeam { get; set; }
        @AuraEnabled public String projectType { get; set; }
        @AuraEnabled public String otherType { get; set; }
        @AuraEnabled public Date projectSubmissionDate { get; set; }
        @AuraEnabled public Date firstDraftDueDate { get; set; }
        @AuraEnabled public Date finalCompletionDate { get; set; }
        @AuraEnabled public String projectPurposeAndOpportunity { get; set; } 
        @AuraEnabled public String brandedUnbranded { get; set; }
        @AuraEnabled public String featuredProduct { get; set; }
        @AuraEnabled public String uSCanada { get; set; }
        @AuraEnabled public String pricingIfPleaseSpecify { get; set; }
        @AuraEnabled public String brandLogos { get; set; }
        @AuraEnabled public String attitudeStyleAndTone { get; set; }
        @AuraEnabled public String pricingforItems { get; set; }
        @AuraEnabled public String additionalPieces { get; set; }
        @AuraEnabled public String listProduct { get; set; }
        @AuraEnabled public String typeofFileNeeded { get; set; }
        @AuraEnabled public String objective { get; set; }
        @AuraEnabled public String sizeofFile { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String reviewer { get; set; }
        @AuraEnabled public String typeofFile { get; set; }
        @AuraEnabled public String sizeofImageFile { get; set; }
        @AuraEnabled public Decimal pagesNeeded { get; set; }
        @AuraEnabled public Date effectiveDate { get; set; }
        @AuraEnabled public Date expirationDate { get; set; }
        @AuraEnabled public String sharePoint { get; set; }
        @AuraEnabled public String references { get; set; }
        @AuraEnabled public String ownersubmitted { get; set; }
        @AuraEnabled public String promoCode { get; set; }
        @AuraEnabled public String submitterEmail { get; set; }
        @AuraEnabled public String reviewer1 { get; set; }
        @AuraEnabled public String reviewer2 { get; set; }
        @AuraEnabled public String reviewer3 { get; set; }
        @AuraEnabled public String reviewer4 { get; set; }
    }
    
    @AuraEnabled(cacheable=false)
    public static Marketing_Projects__c  createMarketingProject(MarketingProjectWrapper params) {
        try {
            // Create a new Marketing Project record 
            system.debug('teee=> ' + params.projectName);
            Marketing_Projects__c newProject = new Marketing_Projects__c();
            newProject.Marketing_Project_Name__c = params.projectName;
            newProject.Status__c = params.status;
            newProject.Business_Units__c = params.businessUnits;
            newProject.SharePoint_Review_Complete__c = params.sharePointReviewComplete;
            newProject.Team_Requesting_Project__c = params.teamRequestingProject;
            newProject.Requesting_Team_Specify_if_Other__c = params.requestingTeam;
            newProject.Product_Type__c = params.projectType;
            newProject.Other_Type__c = params.otherType;
            newProject.Due_Date_Project_Submission__c = params.projectSubmissionDate;
            newProject.First_Draft_Due_Date__c = params.firstDraftDueDate;
            newProject.Final_Completion_Date__c = params.finalCompletionDate;
            newProject.Project_Purpose_and_Opportunity__c = params.projectPurposeAndOpportunity;
            newProject.Branded_Unbranded__c = params.brandedUnbranded;
            newProject.Featured_Product_s__c = params.featuredProduct;
            newProject.US_Canada__c = params.uSCanada;
            newProject.Pricing_If_Other_Please_Specify__c = params.pricingIfPleaseSpecify;
            newProject.Brand_Logos__c = params.brandLogos;
            newProject.Attitude_style_and_tone__c = params.attitudeStyleAndTone;
            newProject.Pricing_for_Items_If_Applicable__c = params.pricingforItems;
            newProject.Additional_Pieces_to_be_Produced__c = params.additionalPieces;
            newProject.List_Product_Information_to_be_included__c = params.listProduct;
            newProject.Type_of_File_Needed_Other_Multiple__c = params.typeofFileNeeded;
            newProject.Objective__c = params.objective;
            newProject.Size_of_File_Needed_if_other_8_5x11__c = params.sizeofFile;
            newProject.Message__c = params.message;
            newProject.Reviewer__c = params.reviewer;
            newProject.File_Type__c = params.typeofFile;
            newProject.Size_of_Image_File_Pixels__c = params.sizeofImageFile;
            newProject.Pages_Needed_If_other_than_1__c = params.pagesNeeded;
            newProject.Effective_Date__c = params.effectiveDate;
            newProject.Expiration_Date__c = params.expirationDate;
            newProject.Link_to_File_s__c = params.sharePoint;
            newProject.References__c = params.references;
            newProject.owner__c = params.ownersubmitted;
            newProject.Promo_Code__c = params.promoCode;
            newProject.Submitter_Email__c = params.submitterEmail;
            newProject.Reviewer1__c = params.reviewer1;
            newProject.Reviewer2__c = params.reviewer2;
            newProject.Reviewer3__c = params.reviewer3;
            newProject.Reviewer4__c = params.reviewer4;
            
            insert newProject;
            system.debug('newProject  ->>'+ newProject.Id );
            
            return newProject;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
}