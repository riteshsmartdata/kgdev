/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class AccountInactivate_Batch_Test {
    @isTest    
    public static void accountInactiveTest(){

        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        // Account Record Creation
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        accountRecord.Status__c = 'Inactive';
        accList.add(accountRecord);
        Insert accList;
         
        // Contact Record Creation
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Test Last Name';
        contactRecord.FirstName = 'Test First Name';
        contactRecord.Email = 'test@test.com';
        contactRecord.Contact_Status__c = 'Active';
        contactRecord.AccountId  = accountRecord.Id;
        conList.add(contactRecord);
        Insert conList;

        Test.startTest();
        
        AccountInactivate_Batch ba= new AccountInactivate_Batch();
        Id jobid= Database.executeBatch(ba,1); 
        ScheduleAccountInactivate sh1 = new ScheduleAccountInactivate();      
         String sch = '0 0 10 * * ?';
        system.schedule('Account inactivate check', sch, sh1);
        Test.stopTest();
    }
}