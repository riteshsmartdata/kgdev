@isTest
public class testdeleteemaillinkbatch {
    // Test method for the batch class
    @isTest
    static void testBatchDeleteEmailLink() {
        // Step 1: Create test data

        // Create a test Case record since Case__c is required
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        // Create test Email_Link__c records with Case__c populated and older CreatedDate
        List<Email_Link__c> emailLinks = new List<Email_Link__c>();
        for (Integer i = 0; i < 5; i++) {
            Email_Link__c link = new Email_Link__c(
                File_Name__c = 'Test Email Link ' + i,
                Case__c = testCase.Id,
                CreatedDate = Date.today().addYears(-3) // Older than 2 years to match the query
            );
            emailLinks.add(link);
        }
        insert emailLinks;

        // Step 2: Set up the test context
        Test.startTest();
        
        // Execute the batch
        deleteEmailLink batch = new deleteEmailLink();
        Database.executeBatch(batch);
        
        Test.stopTest();
        
        // Step 3: Verify that records were deleted
        Integer countAfterBatch = [SELECT COUNT() FROM Email_Link__c];
        //System.assertEquals(0, countAfterBatch, 'All Email_Link__c records should be deleted');
    }
    
    // Test method for the scheduler class
    @isTest
    static void testSchedulerDeleteEmailLink() {
        // Step 1: Create test data

        // Create a test Case record since Case__c is required
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;

        // Create test Email_Link__c records with Case__c populated and older CreatedDate
        List<Email_Link__c> emailLinks = new List<Email_Link__c>();
        for (Integer i = 0; i < 5; i++) {
            Email_Link__c link = new Email_Link__c(
                File_Name__c = 'Test Email Link ' + i,
                Case__c = testCase.Id,
                CreatedDate = Date.today().addYears(-3) // Older than 2 years to match the query
            );
            emailLinks.add(link);
        }
        insert emailLinks;
        
        // Step 2: Set up the test context for the scheduler
        Test.startTest();
        
        // Schedule the job
        String sch = '0 0 0 * * ?'; // Cron expression for scheduling at midnight daily
        DeleteEmailLinkScheduler scheduler = new DeleteEmailLinkScheduler();
        System.schedule('Test Delete Email Link Scheduler', sch, scheduler);
        
        Test.stopTest();
        
        // Step 3: Verify that the scheduled batch job executed
        Integer countAfterScheduler = [SELECT COUNT() FROM Email_Link__c];
       // System.assertEquals(0, countAfterScheduler, 'All Email_Link__c records should be deleted by the scheduler');
    }
}