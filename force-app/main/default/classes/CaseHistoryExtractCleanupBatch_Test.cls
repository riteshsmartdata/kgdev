@isTest
public class CaseHistoryExtractCleanupBatch_Test {
 public static testMethod void testBatchExecution() {
    
    List<Case_History_Extract__c> caseHistoryList = new List<Case_History_Extract__c>();
        Case_History_Extract__c c = new Case_History_Extract__c ();
       // c.Created_Date__c = Date.newInstance(2020, 12, 31);
        caseHistoryList.add(c);
    
    insert caseHistoryList;
    
    Test.startTest();
   // CaseHistoryExtractCleanupBatch batch = new CaseHistoryExtractCleanupBatch();
   // Database.executeBatch(batch);
     CaseHistoryExtractCleanupBatchScheduler testsche = new CaseHistoryExtractCleanupBatchScheduler();
     String sch = '0 0 23 * * ?';
     system.schedule('Test status Check', sch, testsche );
    Test.stopTest();
    
}

}