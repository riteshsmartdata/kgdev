@isTest
private class CaseEmailExportControllerTest {
    @testSetup
    static void setupData() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        SwitchTrigger__c st = new SwitchTrigger__c(
            Name = 'EmailLinkTrigger',
            Deactivate__c = false
        );
        insert st;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            Email = 'test@gmail.com',
            Phone = '5444545454'
        );
        insert con;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Delayed Order').getRecordTypeId();
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Phone',
            RecordTypeId = recordTypeId,
            AccountId = acc.Id,
            ContactId = con.Id
        );
        insert testCase;
        
        EmailMessage emailMessage1 = new EmailMessage(); 
        emailMessage1.Status = '3'; 
        emailMessage1.FromName = 'Test Email'; 
        emailMessage1.Subject = 'This is the Subject!'; 
        emailMessage1.HtmlBody = '<html><body><b>Hello</b></body></html>'; 
        emailMessage1.ParentId = testCase.Id;
        insert emailMessage1; 
    }
    
    @isTest
    static void testGetEmailBatchWithRecords() {
        Case testCase = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
        EmailMessage em = [SELECT Id, CreatedDate FROM EmailMessage LIMIT 1];
        
        Test.startTest();
        List<EmailMessage> result = CaseEmailExportController.getEmailBatch(
            null, 
            null, 
            10,   
            'RT Case' 
        );
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetEmailBatchWithPagination() {
        EmailMessage em = [SELECT Id, CreatedDate FROM EmailMessage LIMIT 1];
        
        Test.startTest();
        List<EmailMessage> result = CaseEmailExportController.getEmailBatch(
            em.Id, 
            em.CreatedDate, 
            10,
            'Delayed Order' 
        );
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'No new records should be returned for pagination');
    }
    
    @isTest
    static void testGetEmailBatchNoCases() {
        Test.startTest();
        List<EmailMessage> result = CaseEmailExportController.getEmailBatch(
            null, 
            null, 
            10,
            'NonExistingType'
        );
        CaseEmailExportController.getEmailFieldLabels();
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list when no cases exist for RecordType');
    }
}