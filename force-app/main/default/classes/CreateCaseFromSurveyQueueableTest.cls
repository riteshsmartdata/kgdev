@isTest
private class CreateCaseFromSurveyQueueableTest {

    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account(Name='Test Account');
        insert acc;

        Case parentCase = new Case(
            Status = 'New',
            Origin = 'Phone',
            Subject = 'Parent Case',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Survey').getRecordTypeId()
        );
        insert parentCase;

        List<Custom_Survey__c> surveys = new List<Custom_Survey__c>();
        for (Integer i = 0; i < 1; i++) {
            surveys.add(new Custom_Survey__c(
                Email_Case_Feedback__c = 'Poor',
                Case__c = parentCase.Id,
                Survey_Type__c = 'Email Case Survey'
            ));
        }
        insert surveys;
    }

    @isTest
    static void testQueueableExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.startTest();
        // Directly enqueue the Queueable
        System.enqueueJob(new CreateCaseFromSurveyQueueable());
        Test.stopTest();

        List<Case> cases = [SELECT Id, Custom_Survey__c FROM Case WHERE Custom_Survey__c != null];
        System.assertEquals(1, cases.size(), '1 Cases should have been created from surveys');
    }

    @isTest
    static void testSchedulerExecution() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.startTest();
        CreateCaseFromSurveyScheduler scheduler = new CreateCaseFromSurveyScheduler();
        scheduler.execute(null); 
        Test.stopTest();

        List<Case> cases = [SELECT Id, Custom_Survey__c FROM Case WHERE Custom_Survey__c != null];
        System.assertEquals(1, cases.size(), 'Scheduler should have created 1 Cases');
    }
}