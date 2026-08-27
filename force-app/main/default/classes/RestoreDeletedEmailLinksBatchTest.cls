@IsTest
public class RestoreDeletedEmailLinksBatchTest {
    
    @TestSetup
    static void setupTestData() {
         SwitchTrigger__c cs = new SwitchTrigger__c();
        cs.Name='EmailLinkTrigger';
        cs.Deactivate__c = false;
        //cs.Other fiels values
        insert cs;
      Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
        EmailMessage  em = new EmailMessage () ;
        em.ParentID  = css.id;
        insert em;
        Email_Link__c el = new Email_Link__c() ;
        el.Case__c  = css.id;
        insert el;

        // Simulate deletion of records
        delete el;

        // Retrieve the deleted records to ensure they are in the recycle bin
        List<Email_Link__c> deletedEmailLinks = [
            SELECT Id, LastModifiedById, IsDeleted
            FROM Email_Link__c
            WHERE IsDeleted = true
            ALL ROWS
        ];

        // Verify records are deleted
    //    System.assertEquals(5, deletedEmailLinks.size(), '5 records should be soft deleted.');
    }

    @IsTest
    static void testBatchRestoreDeletedRecords() {
        // Set up test for running the batch
        Test.startTest();

        // Create an instance of the batch class and execute it
        RestoreDeletedEmailLinksBatch batchJob = new RestoreDeletedEmailLinksBatch();
        Database.executeBatch(batchJob, 100); // Set the batch size to 100

        Test.stopTest();

        // After the batch job runs, verify that the records have been restored
        List<Email_Link__c> restoredEmailLinks = [
            SELECT Id, Name, IsDeleted 
            FROM Email_Link__c
            WHERE IsDeleted = false
        ];

        // Assert that all records have been restored (IsDeleted = false)
    //    System.assertEquals(5, restoredEmailLinks.size(), 'All 5 records should be restored.');
    }
}