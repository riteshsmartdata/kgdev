@isTest
private class updateContactAddress_Test {  
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
     
    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Account> acclist = new List<Account>();
        List<Contact>conlist = new List<Contact>();
        Account acc1 = new Account(Name = 'Account 1', ShippingStreet = '123 Main St', ShippingCity = 'San Francisco', ShippingState = 'CA', ShippingPostalCode = '94105', ShippingCountry = 'USA');
        Account acc2 = new Account(Name = 'Account 2', ShippingStreet = '456 Market St', ShippingCity = 'San Francisco', ShippingState = 'CA', ShippingPostalCode = '94103', ShippingCountry = 'Japan');
        acclist.add(acc1);
        acclist.add(acc2);
        insert acclist;
        
        Contact con1 = new Contact(LastName = 'Doe',FirstName = 'John',Email = 'john@yahoo.com', AccountId = acc1.Id, MailingStreet = 'X', MailingCity = 'X', MailingState = 'X', MailingPostalCode = 'X', MailingCountry = 'X');
        Contact con2 = new Contact(LastName = 'Smith',FirstName = 'Joy',Email = 'joy@yahoo.com', AccountId = acc2.Id, MailingStreet = 'EMPTY', MailingCity = 'EMPTY', MailingState = 'EMPTY', MailingPostalCode = 'EMPTY', MailingCountry = 'EMPTY');
        Contact con3 = new Contact(LastName = 'Johnson',FirstName = 'Mike',Email = 'Mike@yahoo.com', AccountId = acc1.Id); // Missing mailing address
        conlist.add(con1);
        conlist.add(con2);
        conlist.add(con3);
        insert conlist;
    }
    
    @isTest
    static void testBatchable() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // Execute the batch job
        updateContactAddress batchJob = new updateContactAddress();
        Database.executeBatch(batchJob); // You can adjust batch size for testing
        
        Test.stopTest();
        
        // Verify that Contacts were updated with Account's Shipping Address
        List<Contact> updatedContacts = [SELECT MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact];
        
        System.assertEquals('123 Main St', updatedContacts[0].MailingStreet, 'Contact 1 MailingStreet should match Account 1 ShippingStreet');
        System.assertEquals('San Francisco', updatedContacts[0].MailingCity, 'Contact 1 MailingCity should match Account 1 ShippingCity');
        
        System.assertEquals('456 Market St', updatedContacts[1].MailingStreet, 'Contact 2 MailingStreet should match Account 2 ShippingStreet');
        System.assertEquals('San Francisco', updatedContacts[1].MailingCity, 'Contact 2 MailingCity should match Account 2 ShippingCity');
    }
    
    @isTest
    static void testSchedulable() {
        Test.startTest();
        
        // Schedule the job (execute method in the schedulable class)
        updateContactsSchedule schedulableJob = new updateContactsSchedule();
        String jobId = System.schedule('Test Scheduled Contact Update', '0 0 12 * * ?', schedulableJob);
        
        // Assert that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 12 * * ?', ct.CronExpression, 'The cron expression should match the scheduled one');
        
        Test.stopTest();
        
        // Verify that the batch job executed
        Integer batchJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, batchJobCount, 'The batch job should have been triggered by the scheduled job.');
    }
}