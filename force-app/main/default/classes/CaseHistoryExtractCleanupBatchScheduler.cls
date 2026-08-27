global class CaseHistoryExtractCleanupBatchScheduler implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        CaseHistoryExtractCleanupBatch batch = new CaseHistoryExtractCleanupBatch();
        Database.executeBatch(batch);
    }
    
}