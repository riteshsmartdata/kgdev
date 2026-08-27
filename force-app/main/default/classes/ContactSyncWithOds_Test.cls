/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 04-28-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class ContactSyncWithOds_Test {

    @isTest    
    public static void ContactSyncWithOdsTest(){

        List<Apex_Errors__c> aeList = new List<Apex_Errors__c>();
        List<Contact> conlist = new List<Contact>();
        AppInfo__c ai = new AppInfo__c();
        ai.Name = 'Sandbox';
        ai.User__c = 'webclient';
        ai.Password__c = 'eh8q4ya4bvnx5';
        ai.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ai;
                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Account Record Creation
        Account accountRecord = new Account();
        accountRecord.Name = 'Account Testing';
        accountRecord.Customer_Account_Number__c = '243434';
        Insert accountRecord;
        
        // Contact Record Creation
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Last Name Testing';
        contactRecord.FirstName = 'First Name Testing';
        contactRecord.Email = 'testing@test.com';
        contactRecord.AccountId  = accountRecord.Id;
        insert contactRecord;
        conlist.add(contactRecord);
        
        Test.startTest();
        ContactSyncWithOds.odsCallout(conlist);
        Test.stopTest();
    } 
}