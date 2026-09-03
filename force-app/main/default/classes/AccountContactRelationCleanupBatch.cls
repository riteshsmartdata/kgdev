global without sharing class AccountContactRelationCleanupBatch implements Database.Batchable<SObject>, Schedulable {

    // ===== BATCH LOGIC =====
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Fetch AccountContactRelation records where Active = false and were deactivated more than 14 days ago
        DateTime threshold = System.now().addDays(-14);
        return Database.getQueryLocator([
            SELECT Id  
            FROM AccountContactRelation 
            WHERE IsActive = false 
            AND LastModifiedDate < :threshold
        ]);   
    }

    public void execute(Database.BatchableContext bc, List<AccountContactRelation> scope) {
        if (scope.isEmpty()) {
            System.debug('No AccountContactRelation records to process in this scope.');
            return;
        }
        try {
            // Use partial delete to capture per-record failures (flows/validations/sharing)
            Database.DeleteResult[] results = Database.delete(scope, false);
            Integer success = 0, failures = 0;
            for (Integer i = 0; i < results.size(); i++) {
                if (results[i].isSuccess()) {
                    success++;
                } else {
                    failures++;
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug(LoggingLevel.ERROR,
                            'Failed to delete ACR ' + scope[i].Id + ' => ' + err.getStatusCode() + ' - ' + err.getMessage());
                    }
                }
            }
            System.debug('AccountContactRelationCleanupBatch summary: deleted=' + success + ', failed=' + failures);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Batch-level delete error: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Cleanup completed for inactive AccountContactRelation records older than 2 weeks.');
    }
    
    // ===== SCHEDULABLE INTERFACE =====
    global void execute(SchedulableContext sc) {
        Database.executeBatch(this);
    }
    
    // ===== SCHEDULE METHODS =====
    global static void scheduleWeeklyJob() {
        // Schedule to run daily at 12 AM
        String cronExp = '0 0 0 * * ?';
        System.schedule('Daily AccountContactRelation Cleanup', cronExp, new AccountContactRelationCleanupBatch());
    }
}