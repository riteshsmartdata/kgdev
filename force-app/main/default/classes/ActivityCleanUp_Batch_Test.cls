/*
* @description       : Test Class for ActivityCleanUp_Batch apex class which will test wherther the old tasks created by Integration Service user or Inactive users is getting deleted or not
* @author            : Anubhav Saxena
* @group             : DAMCO
* @created on        : 12-03-2024
* @last modified on  :
* @last modified by  : Anubhav Saxena
*/
@isTest
public with sharing class ActivityCleanUp_Batch_Test {
    /*
    * @description : Test Setup Method to create test data (Creating Integration Service user and Old Tasks)
    * @paramerters : none
    */
    @TestSetup
    private static void testData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccount = TestData.createAccount(false);
        insert testAccount;
        Contact testContact = TestData.createContact(false, testAccount.Id);
        insert testContact;
    }
    /*
    * @description : Testing scheduler method
    * @paramerters : none
    */
    @isTest
    private static void taskClenaUpBatchSchedulerTest(){
        Account testAccount = [SELECT Id FROM Account];
        Contact testContact= [SELECT Id FROM Contact LIMIT 1]; 
        List<Task> insertOldTaskList = new List<Task>();
        for (Integer i = 0; i < 5; i++) {
            Task t = new Task(CreatedDate=Date.today().addDays(-120),ActivityDate=Date.today().addDays(-70),Activity_Type__c='Outbound Sales Phone Call',Subject='Failed to send email',WhatId=testAccount.Id,WhoId=testContact.Id);
            insertOldTaskList.add(t);
        }
        Test.startTest();
            System.schedule('Test Schedule Method Job 1', '0 0 * * * ?', new ActivityCleanUp_Batch());
        Test.stopTest();
        List<Task> deletedtaskList = [SELECT Id,CreatedBy.Name,CreatedDate From Task];
        system.assert(deletedtaskList.size()==0,'All the expired tasks were not deleted!');   
    }
    /*
    * @description : Test Scenario : inserting Expired Actvities via Integration user.
    * @paramerters : none
    */
    @isTest
    private static void testTaskCleanUpBatch(){
        Account testAccount = [SELECT Id FROM Account];
        Contact testContact= [SELECT Id FROM Contact LIMIT 1]; 
        List<Task> insertOldTaskList = new List<Task>();
        for (Integer i = 0; i < 5; i++) {
            Task t = new Task(CreatedDate=Date.today().addDays(-120),ActivityDate=Date.today().addDays(-70),Activity_Type__c='Outbound Sales Phone Call',Subject='Failed to send email',WhatId=testAccount.Id,WhoId=testContact.Id);
            insertOldTaskList.add(t);
        }
        insert insertOldTaskList;
        Test.startTest();
            Database.executeBatch(new ActivityCleanUp_Batch(),10);
        Test.stopTest();
        List<Task> deletedtaskList = [SELECT Id,CreatedBy.Name,CreatedDate From Task];
        system.assert(deletedtaskList.size()==0,'All the expired tasks were not deleted!');    
    }
}