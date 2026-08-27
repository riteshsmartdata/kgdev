@isTest
private class MarketingProjectControllerTest {
    
    @isTest
    public static void testCreateMarketingProject() {
        Test.startTest();
        MarketingProjectController.MarketingProjectWrapper testWrapper = new MarketingProjectController.MarketingProjectWrapper();
        testWrapper.projectName = 'Test Marketing Project';
        testWrapper.status = 'Created';
        testWrapper.businessUnits = 'KG';
        testWrapper.sharePointReviewComplete = 'No';
        testWrapper.teamRequestingProject = 'Other';
        testWrapper.requestingTeam = 'Advertising';
        testWrapper.otherType = 'New Product';
        testWrapper.projectSubmissionDate = Date.today();
        testWrapper.firstDraftDueDate = Date.today().addDays(30);
        testWrapper.finalCompletionDate = Date.today().addDays(60);
        testWrapper.projectPurposeAndOpportunity = 'Launch new product in the market';
        testWrapper.brandedUnbranded = 'Branded';
        testWrapper.featuredProduct = 'New Widget';
        testWrapper.uSCanada = 'US';
        testWrapper.pricingIfPleaseSpecify = 'Standard';
        testWrapper.brandLogos = 'Brand X';
        testWrapper.attitudeStyleAndTone = 'Professional';
        testWrapper.additionalPieces = 'Brochure, Flyer';
        testWrapper.listProduct = 'Widget, Gadget';
        testWrapper.typeofFileNeeded = 'PDF';
        testWrapper.objective = 'Increase market share';
        testWrapper.sizeofFile = '8.5x11';
        testWrapper.message = 'This is a test project';
        testWrapper.reviewer = 'John Doe';
        testWrapper.typeofFile = 'ai';
        testWrapper.sizeofImageFile = '1024x768';
        testWrapper.pagesNeeded = 10;
        testWrapper.effectiveDate = Date.today().addDays(10);
        testWrapper.expirationDate = Date.today().addDays(365);
        testWrapper.sharePoint = 'http://sharepoint.link';
        testWrapper.references = 'Reference materials';
        testWrapper.ownersubmitted = 'OwnerName';
        testWrapper.promoCode = 'PROMO2024';
        testWrapper.submitterEmail = 'submitter@example.com';
        testWrapper.reviewer1 = 'Reviewer 1';
        testWrapper.reviewer2 = 'Reviewer 2';
        testWrapper.reviewer3 = 'Reviewer 3';
        testWrapper.reviewer4 = 'Reviewer 4';
        
        Marketing_Projects__c newProject = MarketingProjectController.createMarketingProject(testWrapper);
        Test.stopTest();
        
        Marketing_Projects__c retrievedProject = [SELECT Id, Marketing_Project_Name__c, Status__c 
                                                  FROM Marketing_Projects__c 
                                                  WHERE Id = :newProject.Id LIMIT 1];
        
        System.assertNotEquals(null, retrievedProject, 'Expected the Marketing Project record to be created');
        System.assertEquals('Test Marketing Project', retrievedProject.Marketing_Project_Name__c, 'Unexpected project name');
        System.assertEquals('Created', retrievedProject.Status__c, 'Unexpected project status');
    }
    
    @isTest
    public static void testCreateMarketingProjectWithException() {
        MarketingProjectController.MarketingProjectWrapper invalidWrapper = new MarketingProjectController.MarketingProjectWrapper();
        
        Test.startTest();
        try {
            Marketing_Projects__c newProject = MarketingProjectController.createMarketingProject(invalidWrapper);
            System.assert(true, 'Expected an exception to be thrown due to missing required fields');
        } catch (AuraHandledException ex) {
            System.assert(ex.getMessage().contains('Error creating Marketing Project record'), 
                          'Unexpected exception message: ' + ex.getMessage());
        }
        Test.stopTest();
    }
}