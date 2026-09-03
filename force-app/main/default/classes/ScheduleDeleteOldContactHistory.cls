/**
 * @description       : 
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Sandeep Reddy
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-05-2024   Sandeep Reddy   Initial Version
**/
global class ScheduleDeleteOldContactHistory implements Schedulable {

    // The 'execute' method schedules the batch job to run at the defined time.
    global void execute(SchedulableContext SC) {
        // Create an instance of the batch class
        DeleteOldContactHistoryBatch batchJob = new DeleteOldContactHistoryBatch();
        
        // Define the batch size (e.g., 200 records per batch)
        Integer batchSize = 200;
        
        // Schedule the batch job to run immediately or as per your needs
        Database.executeBatch(batchJob, batchSize);
    }
}