global class DataDeleteJobForTaskScheduler  implements Schedulable {
global void execute(SchedulableContext SC) {
    
        DataDeleteJobForTaskCleanupBatch batch = new DataDeleteJobForTaskCleanupBatch();
        Database.executeBatch(batch);
    }
}