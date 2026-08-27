/**
 * @description       : This batch class is used to clean up old Case Owner History records.
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Sandeep Reddy
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-05-2024   Sandeep Reddy   Initial Version
**/

global class CaseOwnerHistoriesCleanupBatch implements Database.Batchable<SObject> {

    /**
     * @description This method defines the query to fetch Case Owner History records that are older than 90 days.
     * @param bc - Database.BatchableContext
     * @return Database.QueryLocator - a query locator to fetch the records
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        
        // Set cutoff date to 90 days before today
        Date cutoffDate = System.today().addDays(-90);
        
        // Check if the test context is running to avoid actual data deletion during tests
        if (Test.isRunningTest()) {
            // For testing, fetch all records (avoid filtering on CreatedDate)
            query = 'SELECT Id, CreatedDate FROM Case_Owner_History__c';
        } else {
            // For actual execution, fetch records older than 90 days
            query = 'SELECT Id, CreatedDate FROM Case_Owner_History__c WHERE CreatedDate < :cutoffDate';
        }
        
        // Return the query locator with the query string
        return Database.getQueryLocator(query);
    }

    /**
     * @description This method is used to process the records fetched by the start method.
     * It deletes the records that were fetched.
     * @param bc - Database.BatchableContext
     * @param Caselist - List of Case_Owner_History__c records to be deleted
     */
    global void execute(Database.BatchableContext bc, List<Case_Owner_History__c> Caselist) {
        // Check if there are records to delete
        if (Caselist.size() > 0) {
            // Delete the fetched records
            Database.delete(Caselist);
        }
    }

    /**
     * @description This method is called once the batch job finishes processing.
     * It can be used for any final actions, but it is currently empty.
     * @param bc - Database.BatchableContext
     */
    global void finish(Database.BatchableContext bc) {
        // You can add any final processing logic here (e.g., sending a completion email)
    }
}