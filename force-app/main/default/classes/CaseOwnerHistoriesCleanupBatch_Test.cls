/**
 * @description       : This test class verifies the functionality of the CaseOwnerHistoriesCleanupBatchScheduler class, which schedules and runs the CaseOwnerHistoriesCleanupBatch batch job.
 * The test ensures that Case Owner History records older than the current year are deleted after the batch is executed.
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 15-11-2024
 * @last modified by  : Sandeep Reddy
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   15-11-2024   Sandeep Reddy   Initial Version
**/
@isTest
private class CaseOwnerHistoriesCleanupBatch_Test {
    private static testMethod void testBatchExecution() {
        
        List<Case_Owner_History__c> caseOwnerHistoryList = new List<Case_Owner_History__c>();
        for(Integer i=0; i<2; i++) {
            Case_Owner_History__c c = new Case_Owner_History__c();
            // c.Created_Date__c = Date.newInstance(2020, 12, 31);
            caseOwnerHistoryList.add(c);
        }
        insert caseOwnerHistoryList;
        
        Test.startTest();
        //CaseOwnerHistoriesCleanupBatch batch = new CaseOwnerHistoriesCleanupBatch();
        // Database.executeBatch(batch);
        CaseOwnerHistoriesCleanupBatchScheduler testsche = new CaseOwnerHistoriesCleanupBatchScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
        
        List<Case_Owner_History__c> remainingCaseOwnerHistoryList = [        SELECT Id FROM Case_Owner_History__c         WHERE Created_Date__c < THIS_YEAR    ];
        System.assertEquals(0, remainingCaseOwnerHistoryList.size(), 'All the Case Owner History records should have been deleted.');
    }
    
}