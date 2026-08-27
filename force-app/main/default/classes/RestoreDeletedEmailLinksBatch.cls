public class RestoreDeletedEmailLinksBatch implements Database.Batchable<SObject> {

    // Start method to query deleted records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query soft-deleted records from the Email_Link__c object deleted by the specified user
        String query = 'SELECT Id, Name, SystemModstamp, LastModifiedDate ' +
                       'FROM Email_Link__c ' +
                       'WHERE IsDeleted = true ' +
                       'AND LastModifiedById = \'0054w000009osgwAAA\' ' +
                       'ALL ROWS';
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch
    public void execute(Database.BatchableContext bc, List<Email_Link__c> deletedRecords) {
        // Check if there are any deleted records
        if (!deletedRecords.isEmpty()) {
            try {
                // Restore the deleted records using the undelete DML statement
                undelete deletedRecords;
                System.debug('Records successfully restored: ' + deletedRecords.size());
            } catch (DmlException e) {
                // Handle any errors during the undelete operation
                System.debug('Error restoring records: ' + e.getMessage());
            }
        } else {
            System.debug('No records found to restore.');
        }
    }

    // Finish method (optional)
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job finished successfully.');
    }
}