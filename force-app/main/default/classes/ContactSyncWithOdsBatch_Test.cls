/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class ContactSyncWithOdsBatch_Test {
    @TestSetup
    private static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Account Testers';
        accountRecord.Customer_Account_Number__c = '987654321';
        insert accountRecord;

        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Testers Last Name';
        contactRecord.FirstName = 'Testers First Name';
        contactRecord.Email = 'testers@test.com';
        contactRecord.AccountId  = accountRecord.Id;
        insert contactRecord;
    }
    @isTest
    private static void testSchdeuler(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
            System.schedule('Test Schedule Method Job 1', '0 0 * * * ?', new ContactSyncWithOdsBatch());
        Test.stopTest();
    }
    @isTest    
    public static void ContactSyncWithOdsTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
            ContactSyncWithOdsBatch cswob = new ContactSyncWithOdsBatch();
            Database.executeBatch(cswob,1);
        Test.stopTest();
    } 
}