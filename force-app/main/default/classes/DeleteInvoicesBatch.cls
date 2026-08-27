public class DeleteInvoicesBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date oneYearAgo = Date.today().addYears(-1);
        return Database.getQueryLocator([
            SELECT Id 
            FROM Invoice__c 
            WHERE Order__c = null AND CreatedDate < :oneYearAgo
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Invoice__c> scope) {
        if (scope == null || scope.isEmpty()) return;
        
        try {
            Database.delete(scope, false);
        } catch (Exception e) {
            System.debug('Unexpected error: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch completed. Invoices without EBS Orders processed.');
    }
}