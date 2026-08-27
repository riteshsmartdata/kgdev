public class NotificationDataDeletionScheduler implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        NotificationDataDeletionBatch batch = new NotificationDataDeletionBatch();
        Database.executeBatch(batch, 200);  
    }
}