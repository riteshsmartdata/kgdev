@isTest
private class DeleteErrorLogBatchTest {

    @testSetup
    static void setupData() {
        List<ErrorLog__c> errorLogs = new List<ErrorLog__c>();

        for (Integer i = 0; i < 3; i++) {
            errorLogs.add(new ErrorLog__c(Name = 'Old Error ' + i));
        }
        insert errorLogs;

        Integer count = 0;
        for (ErrorLog__c log : errorLogs) {
            Test.setCreatedDate(log.Id, System.now().addMonths(-2)); // 2 months old
            count++;
        }

        List<ErrorLog__c> recentLogs = new List<ErrorLog__c>();
        for (Integer i = 0; i < 2; i++) {
            recentLogs.add(new ErrorLog__c(Name = 'Recent Error ' + i));
        }
        insert recentLogs;

        for (ErrorLog__c log : recentLogs) {
            Test.setCreatedDate(log.Id, System.now().addDays(-10)); // 10 days old
        }
    }

    @isTest
    static void testDeleteErrorLogBatch() {
        System.assertEquals(5, [SELECT COUNT() FROM ErrorLog__c], 'Initial record count should be 5');

        Test.startTest();
        DeleteErrorLogBatch batch = new DeleteErrorLogBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
    }

    @isTest
    static void testErrorLogScheduler() {
        Test.startTest();
        String jobId = System.schedule(
            'Test_Delete_ErrorLog_Schedule',
            '0 0 1 * * ?', // Every day at 1 AM
            new DeleteErrorLogScheduler()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
}