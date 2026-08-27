global class EmailMessageCleanupBatchScheduler implements Schedulable  {
 global void execute(SchedulableContext SC) {
    
        EmailMessageCleanupBatch batch = new EmailMessageCleanupBatch();
        Database.executeBatch(batch);
    }
}