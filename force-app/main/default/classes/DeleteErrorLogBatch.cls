public class DeleteErrorLogBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id 
            FROM ErrorLog__c 
        ]);
    }

    public void execute(Database.BatchableContext BC, List<ErrorLog__c> scope) {
        if (scope == null || scope.isEmpty()) return;

        try {
            Database.delete(scope, false);
        } catch (Exception e) {
            System.debug('Unexpected error while deleting records: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch delete completed successfully.');
    }
}