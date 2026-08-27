public class DeleteErrorLogScheduler implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        DeleteErrorLogBatch batch = new DeleteErrorLogBatch();
        Database.executeBatch(batch, 200);  
    }
}