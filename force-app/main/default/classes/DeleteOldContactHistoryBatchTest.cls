/**
* @description       : This test class is used to verify the functionality of the DeleteOldContactHistoryBatch class.
* It tests the deletion of old Contact History records based on the Type__c field, ensuring that records with Type__c = 'Init'
* older than one year are deleted, and records with Type__c != 'Init' older than 90 days are deleted.
* @author            : Sandeep Reddy
* @group             : 
* @last modified on  : 15-11-2024
* @last modified by  : Sandeep Reddy
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   15-11-2024   Sandeep Reddy   Initial Version
**/
@isTest
private class DeleteOldContactHistoryBatchTest {
    
    @TestSetup
    static void setupTestData() {
        List<ContactHistory__c> testRecords = new List<ContactHistory__c>();
        
        // Add records with Type__c = 'Init' older than 1 year
        testRecords.add(new ContactHistory__c(Type__c = 'Init', CreatedDate = Date.today().addYears(-2)));
        testRecords.add(new ContactHistory__c(Type__c = 'Init', CreatedDate = Date.today().addYears(-1).addDays(-1))); // Edge case
        
        // Add records with Type__c != 'Init' older than 90 days
        testRecords.add(new ContactHistory__c(Type__c = 'Other', CreatedDate = Date.today().addDays(-100)));
        testRecords.add(new ContactHistory__c(Type__c = 'Other', CreatedDate = Date.today().addDays(-91))); // Edge case
        
        // Add records that should NOT be deleted
        testRecords.add(new ContactHistory__c(Type__c = 'Init', CreatedDate = Date.today().addDays(-10))); // Recent Init
        testRecords.add(new ContactHistory__c(Type__c = 'Other', CreatedDate = Date.today().addDays(-10))); // Recent Other
        
        // Insert records into the database
        insert testRecords;
    }
    
    @isTest
    static void testBatchExecution_InitRecordsDeleted() {
        // Test deletion of records with Type__c = 'Init' older than 1 year
        Test.startTest();
        DeleteOldContactHistoryBatch batch = new DeleteOldContactHistoryBatch();
        Integer initialCount = [SELECT COUNT() FROM ContactHistory__c WHERE Type__c = 'Init'];
        System.debug('Initial Init records count: ' + initialCount);
        
        // Execute the batch
        Database.executeBatch(batch, 200); 
        Test.stopTest();
        
        // Verify that only records older than 1 year are deleted
        List<ContactHistory__c> remainingInitRecords = [
            SELECT Id, Type__c, CreatedDate 
            FROM ContactHistory__c 
            WHERE Type__c = 'Init'
        ];
        
        System.debug('Remaining Init records count: ' + remainingInitRecords.size());
        
        // Assert that records older than 1 year are deleted
        for (ContactHistory__c record : remainingInitRecords) {
            System.assert(
                record.CreatedDate >= Date.today().addYears(-1),
                'Init records older than 1 year should be deleted.'
            );
        }
        
    }
    
    @isTest
    static void testBatchExecution_NonInitRecordsDeleted() {
        // Test deletion of records with Type__c != 'Init' older than 90 days
        Test.startTest();
        DeleteOldContactHistoryBatch batch = new DeleteOldContactHistoryBatch();
        Integer initialNonInitCount = [SELECT COUNT() FROM ContactHistory__c WHERE Type__c != 'Init'];
        System.debug('Initial Non-Init records count: ' + initialNonInitCount);
        
        // Execute the batch
        Database.executeBatch(batch, 200); 
        Test.stopTest();
        
        // Verify that only records older than 90 days are deleted
        List<ContactHistory__c> remainingNonInitRecords = [
            SELECT Id, Type__c, CreatedDate 
            FROM ContactHistory__c 
            WHERE Type__c != 'Init'
        ];
        
        System.debug('Remaining Non-Init records count: ' + remainingNonInitRecords.size());
        
        // Assert that records older than 90 days are deleted
        for (ContactHistory__c record : remainingNonInitRecords) {
            System.assert(
                record.CreatedDate >= Date.today().addDays(-90),
                'Non-Init records older than 90 days should be deleted.'
            );
        }
        
    }
    
    @isTest
    static void testBatchExecution_NoRecordsDeleted() {
        // Test with records that should not match any deletion criteria
        List<ContactHistory__c> newRecords = new List<ContactHistory__c>{
            new ContactHistory__c(Type__c = 'Init', CreatedDate = Date.today().addDays(-10)),
                new ContactHistory__c(Type__c = 'Other', CreatedDate = Date.today().addDays(-10))
                };
                    insert newRecords;
        
        Test.startTest();
        DeleteOldContactHistoryBatch batch = new DeleteOldContactHistoryBatch();
        
        // Execute the batch
        Database.executeBatch(batch, 200); 
        Test.stopTest();
        
        // Verify no records are deleted
        List<ContactHistory__c> countAfterBatch = [SELECT Id FROM ContactHistory__c WHERE Id IN :newRecords];
        
        
        System.debug('Count After Batch: ' + countAfterBatch);
        System.assertEquals(2, countAfterBatch.Size(), 'No records should be deleted when criteria do not match.');
    }
    
    @isTest
    static  void testScheduler() {
        // Instantiate the schedulable class
        ScheduleDeleteOldContactHistory schedBatch = new ScheduleDeleteOldContactHistory();
        
        // Define the schedule string (e.g., every day at midnight)
        String sch = '0 0 0 * * ?';
        
        Test.startTest();
        // Schedule the class
        String jobId = System.schedule('Test Scheduled Batch', sch, schedBatch);
        Test.stopTest();
        
        // Assert that the job was scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals('0 0 0 * * ?', ct.CronExpression, 'Cron expression should match the schedule.');
    }
}