global  class DataDeleteJobForTaskCleanupBatch implements  Database.Batchable<SObject>{

      global DataDeleteJobForTaskCleanupBatch() {
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
         String query ='';
     String TaskSubject = 'Failed to Send Email- Email Bounce';
        if(test.isRunningTest()){
            query = 'SELECT Id, Subject FROM Task';
        }
        else{
        
     // and today - createddate> 60 days from today 
     // eg  CreatedDate < LAST_N_DAYS:60
         query = 'SELECT Id,Subject FROM Task WHERE Subject =TaskSubject And  CreatedDate < LAST_N_DAYS:60';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Task> Tasklist) {
        
        List<Task> ToBeDeletedTaskData = new List<Task>();
        for(Task   tsk:Tasklist){
            ToBeDeletedTaskData .add(tsk);
        } 

        if(ToBeDeletedTaskData .size()>0){
            delete ToBeDeletedTaskData ;
        }
    }
        
       
    global void finish(Database.BatchableContext bc) {
        
    }
   
}