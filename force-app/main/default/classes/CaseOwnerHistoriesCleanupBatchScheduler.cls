global class CaseOwnerHistoriesCleanupBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        
        CaseOwnerHistoriesCleanupBatch batch = new CaseOwnerHistoriesCleanupBatch();
        Database.executeBatch(batch);
    }
}