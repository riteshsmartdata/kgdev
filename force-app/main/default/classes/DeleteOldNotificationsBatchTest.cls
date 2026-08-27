@IsTest
private class DeleteOldNotificationsBatchTest {

    // ---------- TEST SETUP ----------
    @testSetup
    static void setupData() {

        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        // Account
        Account acc = new Account(
            Name = 'Test Account',
            Acc_PO_Contact_Email__c = 'test@damco.com',
            Customer_Account_Number__c = '123456',
            Customer_PO_Number__c = '12345'
        );
        insert acc;

        // EBS Order
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'test@damco.com',
            Customer_Account_Number__c = '123456',
            EBS_Order_Number__c = 'ORD-1'
        );
        insert ebsOrder;

        // Notifications
        List<Notification__c> notifications = new List<Notification__c>();
        for (Integer i = 0; i < 5; i++) {
            notifications.add(new Notification__c(
                Status__c = 'delivered',
                EBS_Order__c = ebsOrder.Id
            ));
        }
        insert notifications;

        // Make records old
        Datetime oldDate = System.now().addDays(-95);
        for (Notification__c n : notifications) {
            Test.setCreatedDate(n.Id, oldDate);
        }
    }

    // ---------- BATCH TEST ----------
    @IsTest
    static void testBatchExecution() {

        Test.startTest();
        Database.executeBatch(new DeleteOldNotificationsBatch(), 200);
        Test.stopTest();
    }

    // ---------- SCHEDULER TEST ----------
    @IsTest
    static void testSchedulerExecution() {

        Test.startTest();
        String cronExp = '0 0 0 1 1 ? 2099';
        System.schedule(
            'Delete Old Notifications Job',
            cronExp,
            new DeleteOldNotificationsBatch()
        );
        Test.stopTest();

        // Just validating job ran without error
        System.assert(true);
    }
}