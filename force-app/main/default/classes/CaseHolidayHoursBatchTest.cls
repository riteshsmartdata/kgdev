@isTest
private class CaseHolidayHoursBatchTest {
    @testSetup
    static void setupTestData() {
        // Create Holiday records
        List<Holidays_2__c> holidays = new List<Holidays_2__c>{
            new Holidays_2__c(Holiday_Date__c = Date.today().addDays(-10)),
            new Holidays_2__c(Holiday_Date__c = Date.today().addDays(-5))
        };
        insert holidays;

        // Create Case records
        List<Case> cases = new List<Case>{
            new Case(Status = 'Open', CreatedDate = System.today().addDays(-15), ReOpen_Date__c = null),
            new Case(Status = 'Open', CreatedDate = System.today().addDays(-20),  ReOpen_Date__c = System.today().addDays(-8))
        };
        insert cases;
    }
    
    @isTest
    static void testCaseHolidayBatch() {
        Test.startTest();
        CaseHolidayHoursBatch batch = new CaseHolidayHoursBatch();
        Database.executeBatch(batch, 2);
        Test.stopTest();
        
        // Verify that the cases have been updated
        for (Case c : [SELECT Id, Holiday_Hours__c, Holiday_Count__c FROM Case]) {
            System.assertNotEquals(0, c.Holiday_Count__c, 'Holiday count should be updated');
            System.assertNotEquals(0, c.Holiday_Hours__c, 'Holiday hours should be updated');
        }
    }
    
    @isTest
    static void testCaseHolidayScheduler() {
        Test.startTest();
        CaseHolidayScheduler scheduler = new CaseHolidayScheduler();
        scheduler.execute(null);
        Test.stopTest();
    }
}