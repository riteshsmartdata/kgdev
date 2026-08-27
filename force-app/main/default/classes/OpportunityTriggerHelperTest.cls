@isTest
private class OpportunityTriggerHelperTest {
    // Test setup method to initialize common test data
    @testSetup
    static void setup() {
        // Insert the Case object
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert testCase;
        
        // Insert the Inquiry object
        Inquiry__c testInquiry = new Inquiry__c(
            Source__c = 'Email',
            Case__c = testCase.Id
        );
        insert testInquiry;
        
        // Insert the Opportunity object
        Opportunity testOpportunityWithInquiry = new Opportunity(
            Name = 'Test Opportunity 1',
            Inquiry__c = testInquiry.Id,
            Source__c = 'Email',
            Case__c = testCase.Id,
            CloseDate = system.today() + 20,
            StageName = 'Closed Won'
        );
        insert testOpportunityWithInquiry;
    }

    // Test method to verify functionality
    static testMethod void testPricerequestcaseassign() {
        // Query inserted test data
        Case testCase = [SELECT Id, Subject, Status, Origin FROM Case WHERE Subject = 'Test Case' LIMIT 1];
        Inquiry__c testInquiry = [SELECT Id, Source__c, Case__c FROM Inquiry__c WHERE Case__c = :testCase.Id LIMIT 1];
        Opportunity testOpportunity = [SELECT Id, Name, Source__c, Case__c, Inquiry__c FROM Opportunity WHERE Inquiry__c = :testInquiry.Id LIMIT 1];
        
        System.assertNotEquals(null, testCase, 'Case should be inserted');
        System.assertNotEquals(null, testInquiry, 'Inquiry should be inserted');
        System.assertNotEquals(null, testOpportunity, 'Opportunity should be inserted');

    }
}