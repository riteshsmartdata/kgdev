/**
 * @description       : This batch class is used to clean up old Contact History records.
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 15-11-2024
 * @last modified by  : Sandeep Reddy
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-05-2024   Sandeep Reddy   Initial Version
 * 1.1   15-11-2024   Sandeep Reddy   Added logic to delete records based on Type__c.
**/
global class DeleteOldContactHistoryBatch implements Database.Batchable<SObject> {

    // The 'start' method fetches all records matching the deletion criteria.
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Calculate the cutoff dates
        Date oneYearAgo = System.today().addYears(-1);
        Date ninetyDaysAgo = System.today().addDays(-90);

        System.debug('Batch start method - Fetching records to delete.');

        // Query to fetch records matching both conditions
        return Database.getQueryLocator(
            'SELECT Id, Type__c, CreatedDate ' +
            'FROM ContactHistory__c ' +
            'WHERE (Type__c = \'Init\' AND CreatedDate < :oneYearAgo) ' +
            'OR (Type__c != \'Init\' AND CreatedDate < :ninetyDaysAgo)'
        );
    }

    // The 'execute' method processes the batch of records in scope.
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Execute method - Processing ' + scope.size() + ' records.');
        
        List<ContactHistory__c> toDelete = new List<ContactHistory__c>();

        for (SObject record : scope) {
            ContactHistory__c contactHistory = (ContactHistory__c) record;

            // Check the criteria and add to delete list if it matches
            if ((contactHistory.Type__c == 'Init' && contactHistory.CreatedDate < System.today().addYears(-1)) ||
                (contactHistory.Type__c != 'Init' && contactHistory.CreatedDate < System.today().addDays(-90))) {
                toDelete.add(contactHistory);
            }
        }

        // Delete the records if the list is not empty
        if (!toDelete.isEmpty()) {
            Database.delete(toDelete);
        }
    }

    // The 'finish' method runs after all batches are processed.
    global void finish(Database.BatchableContext bc) {
        System.debug('ContactHistory__c records deletion process complete.');
    }
}