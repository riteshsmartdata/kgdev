@isTest
public class DataDeleteJobForTaskCleanupBatchTest {
public static testMethod void testBatchExecution() {
    
    List<Task>  DataDeleteJobList = new List<Task>();
    for(Integer i=0; i<2; i++) {
        Task t = new Task();
       
        DataDeleteJobList.add(t);
    }
    insert DataDeleteJobList;
    
    Test.startTest();
    //CaseOwnerHistoriesCleanupBatch batch = new CaseOwnerHistoriesCleanupBatch();
   // Database.executeBatch(batch);
     DataDeleteJobForTaskScheduler testsche = new DataDeleteJobForTaskScheduler();
     String sch = '0 0 23 * * ?';
     system.schedule('Test status Check', sch, testsche );
    Test.stopTest();
       List<Task> remainingTaskList = [SELECT Id FROM Task WHERE Subject ='Failed to Send Email- Email Bounce'];
    System.assertEquals(0, remainingTaskList.size(), 'All the Task records should have been deleted.');
}
}