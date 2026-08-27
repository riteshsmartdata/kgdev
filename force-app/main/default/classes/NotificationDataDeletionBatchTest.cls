@isTest
private class NotificationDataDeletionBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create EBS Order Records
        EBS_Order__c order1 = new EBS_Order__c(
            Status__c = 'Closed',
            CreatedDate = System.now().addDays(-40) 
        );
        insert order1;
        
        EBS_Order__c order2 = new EBS_Order__c(
            Status__c = 'Cancelled',
            CreatedDate = System.now().addDays(-35) 
        );
        insert order2;
        
        // Create Notification Records linked to above orders
        Notification__c notif1 = new Notification__c(
            EBS_Order__c = order1.Id
        );
        
        Notification__c notif2 = new Notification__c(
            EBS_Order__c = order2.Id
        );
        
        insert new List<Notification__c> {notif1, notif2};
            }
    
    @isTest
    static void testBatchExecution() {
        Test.startTest();
        
        NotificationDataDeletionBatch batch = new NotificationDataDeletionBatch();
        Database.executeBatch(batch, 200);
        
        Test.stopTest();
        
        List<Notification__c> notifications = [
            SELECT Id FROM Notification__c
        ];
        
        System.assertEquals(0, notifications.size(), 'All matching notifications should be deleted.');
    }
    
    @isTest
    static void testSchedulerExecution() {
        Test.startTest();
        
        String cronExp = '0 0 0 15 9 ? 2025';  
        String jobId = System.schedule('TestNotificationDeletionJob', cronExp, new NotificationDataDeletionScheduler());
        
        Test.stopTest();
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
    }
}