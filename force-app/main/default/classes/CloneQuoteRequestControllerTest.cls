@IsTest
public class CloneQuoteRequestControllerTest {
    @IsTest
    static void testCreateQuoteRequest() 
    {
        
        Id quoteRequestNonRecordTypeId = Schema.SObjectType.Quote_Request__c.getRecordTypeInfosByName().get('Non-Calendar').getRecordTypeId();
        Id quoteProductNonRecordTypeId = Schema.SObjectType.Quote_Product__c.getRecordTypeInfosByName().get('Non-Calendar').getRecordTypeId();
        Id quoteRequestCustomRecordTypeId = Schema.SObjectType.Quote_Request__c.getRecordTypeInfosByName().get('Custom Calendar').getRecordTypeId();
        Id quoteProductCustomRecordTypeId = Schema.SObjectType.Quote_Product__c.getRecordTypeInfosByName().get('Custom Calendar').getRecordTypeId();
        
        // Create test data for Non Calendar
        Map<String, Object> quoteRequestProxy = new Map<String, Object>();
        quoteRequestProxy.put('Stage__c', 'Request in Draft');
        quoteRequestProxy.put('Production_Site__c', 'Domestic');
        quoteRequestProxy.put('EBS__c', 'Test EBS');
        quoteRequestProxy.put('Contact_Email__c', 'test@example.com');
        quoteRequestProxy.put('In_Hands_Date_Event_Date__c', Date.today());
        quoteRequestProxy.put('Additional_Files_or_Images__c', true);
        
		// Create test data for Custom Calendar
		
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]; // Replace with the desired profile name
        User testUser = new User(
            Alias = 'testus',
            Email = 'testuser123321@email.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser123321@email.com'
        );
        insert testUser;
        
        Map<String, Object> quoteRequestProxy1 = new Map<String, Object>();
        quoteRequestProxy1.put('Stage__c', 'Request in Draft');
        quoteRequestProxy1.put('Production_Site__c', 'Domestic');
        quoteRequestProxy1.put('EBS__c', 'Test EBS');
        quoteRequestProxy1.put('Contact_Email__c', 'test@example.com');
        quoteRequestProxy1.put('In_Hands_Date_Event_Date__c', Date.today());
        quoteRequestProxy1.put('Additional_Files_or_Images__c', true);
        quoteRequestProxy1.put('Program_Manager__c', testUser.Id);
        
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create a test Opportunity associated with the test Account
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', AccountId = testAccount.Id, StageName = 'Proposal', CloseDate = Date.today());
        insert testOpportunity;
        
        // Create a test Quote Request for Non Calendar Recordtype
        Quote_Request__c testQuoteRequest = new Quote_Request__c(
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id,
            RecordTypeId = quoteRequestNonRecordTypeId
        );
        insert testQuoteRequest;
        
        // Test Quote Product associated with the test Quote Request(Non Calendar)
        Quote_Product__c testQuoteProduct = new Quote_Product__c(
            Quote_Request__c = testQuoteRequest.Id,
            RecordTypeId = quoteProductNonRecordTypeId
        );
        insert testQuoteProduct;
        
        
        // Create a test Quote Request for Custom Calendar Recordtype
        Quote_Request__c testQuoteRequest1 = new Quote_Request__c(
            Account__c = testAccount.Id,
            Opportunity__c = testOpportunity.Id,
            RecordTypeId = quoteRequestCustomRecordTypeId
        );
        insert testQuoteRequest1;
        
        // Test Quote Product associated with the test Quote Request(Custom Calendar)
        Quote_Product__c testQuoteProduct1 = new Quote_Product__c(
            Quote_Request__c = testQuoteRequest1.Id,
            RecordTypeId = quoteProductCustomRecordTypeId
        );
        insert testQuoteProduct1;
        
        Test.startTest();
        String result = CloneQuoteRequestController.createQuoteRequest(quoteRequestProxy, testQuoteRequest.Id, quoteRequestNonRecordTypeId);
        String result1 = CloneQuoteRequestController.createQuoteRequest(quoteRequestProxy1, testQuoteRequest1.Id, quoteRequestCustomRecordTypeId);
        Test.stopTest();
        
    }
}