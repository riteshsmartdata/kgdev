@isTest
private class DeleteInvoicesBatchTest {
    
    @testSetup
    static void setupData() {
        // Insert orphan invoices older than 1 year
        List<Invoice__c> orphanInvoices = new List<Invoice__c>();
        for (Integer i = 0; i < 3; i++) {
            orphanInvoices.add(new Invoice__c(Invoice_Amount__c = 500));
        }
        insert orphanInvoices;

        // Set CreatedDate to more than 1 year ago
        for (Invoice__c inv : orphanInvoices) {
            Test.setCreatedDate(inv.Id, DateTime.now().addYears(-1).addDays(-1));
        }

        // Insert a linked EBS_Order__c
        EBS_Order__c eo = new EBS_Order__c(
            PO_Contact_Email__c = 'contact1@ebsorder.com', 
            Customer_Account_Number__c = '1234567', 
            Order_Type__c = 'Standard',
            Quote_Number__c = 'QR-144031',
            EBS_Order_Number__c = '27903373661'
        );
        insert eo;

        // Insert linked invoices (Order__c set and recent)
        List<Invoice__c> linkedInvoices = new List<Invoice__c>();
        for (Integer i = 0; i < 2; i++) {
            linkedInvoices.add(new Invoice__c(Invoice_Amount__c = 200 + i, Order__c = eo.Id));
        }
        insert linkedInvoices;
    }
    
    @isTest
    static void testDeleteInvoicesBatch() {
        // Verify 5 invoices inserted
        System.assertEquals(5, [SELECT COUNT() FROM Invoice__c]);

        // Run the batch
        Test.startTest();
        DeleteInvoicesBatch batch = new DeleteInvoicesBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Only the 2 linked (recent) invoices should remain
        List<Invoice__c> remaining = [SELECT Id, Order__c FROM Invoice__c];
        System.assertEquals(2, remaining.size(), 'Only linked invoices should remain.');
        for (Invoice__c inv : remaining) {
            System.assertNotEquals(null, inv.Order__c, 'Remaining invoices must have an Order__c value.');
        }
    }
    
    @isTest
    static void testDeleteInvoicesScheduler() {
        Test.startTest();
        String jobId = System.schedule(
            'Test_Delete_Invoice_Schedule',
            '0 0 1 * * ?', // Daily at 1 AM
            new DeleteInvoicesScheduler()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
}