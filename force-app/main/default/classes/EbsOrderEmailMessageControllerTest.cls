@isTest
private class EbsOrderEmailMessageControllerTest {
    
    @testSetup
    static void setupTestData() {
        
        SwitchTrigger__c switchTrigger = new SwitchTrigger__c(Name = 'EmailLinkTrigger', Deactivate__c = false); // Provide appropriate data
        insert switchTrigger;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(Name = 'Test Account', Customer_Account_Number__c = '12345');
        insert acc;
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact_Email__c = 'contact1@ebsorder.com'; 
        eo.Customer_Account_Number__c = '1234567'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L1';
        eo.Quote_Number__c = 'QR-144031';
        eo.EBS_Order_Number__c = '27903373661';
        insert eo;
        
        // Create a Case related to the EBS Order
        Case testCase = new Case(EBS_Order__c = eo.Id, Subject = 'Test Case');
        insert testCase;
        
        // Create EmailMessages related to the Case
        EmailMessage email1 = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email 1',
            FromAddress = 'test1@example.com',
            ToAddress = 'to1@example.com',
            TextBody = 'This is a test email body 1'
        );
        EmailMessage email2 = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email 2',
            FromAddress = 'test2@example.com',
            ToAddress = 'to2@example.com',
            TextBody = 'This is a test email body 2'
        );
        insert new List<EmailMessage>{email1, email2};
            }
    
    @isTest
    static void testGetEmailMessagesFromEbsOrder() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Fetch the EBS Order created in the test setup
        EBS_Order__c ebsOrder = [SELECT Id FROM EBS_Order__c LIMIT 1];
        
        // Call the method under test
        Test.startTest();
        List<EbsOrderEmailMessageController.EmailMessageWrapper> result = 
            EbsOrderEmailMessageController.getEmailMessagesFromEbsOrder(ebsOrder.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(2, result.size(), 'There should be 2 email messages');
        
        // Verify the content of the email messages
        EbsOrderEmailMessageController.EmailMessageWrapper email1 = result[0];
        System.assertEquals('Test Email 1', email1.Subject);
        System.assertEquals('test1@example.com', email1.FromAddress);
        System.assertEquals('to1@example.com', email1.ToAddress);
        System.assertEquals('This is a test email body 1', email1.TextBody);
        
        EbsOrderEmailMessageController.EmailMessageWrapper email2 = result[1];
        System.assertEquals('Test Email 2', email2.Subject);
        System.assertEquals('test2@example.com', email2.FromAddress);
        System.assertEquals('to2@example.com', email2.ToAddress);
        System.assertEquals('This is a test email body 2', email2.TextBody);
    }
    
    @isTest
    static void testNoEmailMessages() {
        // Create an EBS Order without any associated cases or email messages
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        EBS_Order__c eo = new EBS_Order__c();
        eo.PO_Contact_Email__c = 'contact1@ebsordder.com'; 
        eo.Customer_Account_Number__c = '12345267'; 
        eo.Customer_PO__c = 'PK110014362L1';
        eo.Quote_Number__c = 'QR-1424031';
        eo.EBS_Order_Number__c = '279032373661';
        insert eo;
        
        // Call the method under test
        Test.startTest();
        List<EbsOrderEmailMessageController.EmailMessageWrapper> result = 
            EbsOrderEmailMessageController.getEmailMessagesFromEbsOrder(eo.Id);
        Test.stopTest();
        
        // Verify the result is empty
        System.assertEquals(0, result.size(), 'There should be no email messages');
    }
}