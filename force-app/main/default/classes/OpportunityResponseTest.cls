@isTest
public class OpportunityResponseTest {
    
    @isTest
    public static void testOpportunityResponse() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            contact__c= testContact.Id,
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        
        // Set page parameters for the test
        Test.startTest();
        ApexPages.currentPage().getParameters().put('oppId', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('value', 'Other');
        
        // Mocking the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Instantiate controller
        OpportunityResponse controller = new OpportunityResponse();
        
        // Test doInit method
        controller.doInit();
        
        // Check initial conditions for the controller
        System.assertEquals(false, controller.success, 'Success should be false initially');
        System.assertEquals(true, controller.showOther, 'showOther should be true for "Other" value');
        
        // Test submitting feedback with empty feedbackText (should return an error)
        controller.feedbackText = '';
        controller.submitFeedback();
        
        // Check for error message on empty feedback
        List<ApexPages.Message> messages = ApexPages.getMessages();
        System.assertEquals(1, messages.size(), 'There should be one error message');
        System.assertEquals('Feedback cannot be empty.', messages[0].getSummary(), 'Error message should be "Feedback cannot be empty."');
        
        // Test submitting feedback with valid feedbackText
        controller.feedbackText = 'This is feedback';
        controller.submitFeedback();
        
        // Check if feedback is submitted successfully
        System.assertEquals(true, controller.success, 'Success should be true after submitting feedback');
        System.assertEquals('Thank you for your feedback!', controller.USER_MESSAGE, 'User message should indicate successful submission');
        
        // Verify that the Custom_Survey__c record has been created
        List<Custom_Survey__c> surveys = [SELECT Id, Opportunity__c, Customer_Closed_Lost_Reason__c, Customer_Closed_Won_Lost_Comments__c FROM Custom_Survey__c WHERE Opportunity__c = :testOpportunity.Id];
        System.assertEquals(1, surveys.size(), 'One survey record should be created');
        System.assertEquals(testOpportunity.Id, surveys[0].Opportunity__c, 'Survey should be related to the correct Opportunity');
        System.assertEquals('Other', surveys[0].Customer_Closed_Lost_Reason__c, 'Survey reason should be "Other"');
        System.assertEquals('This is feedback', surveys[0].Customer_Closed_Won_Lost_Comments__c, 'Survey comments should match the feedback');
        
        Test.stopTest();
    }
    @isTest
    public static void testFeedbackAlreadySubmitted() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount.Id
        );
        insert testContact;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Contact__c = testContact.Id,
            AccountId = testAccount.Id
        );
        insert testOpportunity;
        
        // Insert a Custom_Survey record to simulate feedback already submitted
        Custom_Survey__c existingSurvey = new Custom_Survey__c(
            Opportunity__c = testOpportunity.Id,
            Customer_Closed_Lost_Reason__c = 'Competition',
            Customer_Closed_Won_Lost_Comments__c = 'We lost to a competitor'
        );
        insert existingSurvey;
        
        // Set page parameters for the test
        Test.startTest();
        ApexPages.currentPage().getParameters().put('oppId', testOpportunity.Id);
        ApexPages.currentPage().getParameters().put('value', 'Other');
        
        // Mocking the callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        OpportunityResponse controller = new OpportunityResponse();
        
        // Try to submit feedback again — this should hit the "existing survey" logic inside createCustomSurvey
        controller.feedbackText = 'Second feedback';
        controller.submitFeedback();
        
        // Check that the controller recognizes existing feedback
        System.assertEquals(true, controller.success, 'Success should be true when feedback already exists');
        System.assertEquals(false, controller.showOther, 'showOther should be false when feedback already exists');
        System.assertEquals('Feedback already submitted!', controller.USER_MESSAGE, 'User message should indicate feedback has been submitted');
        Test.stopTest();
    }
}