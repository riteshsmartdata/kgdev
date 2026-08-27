/**
* @description       : 
* @author            : Mohammad Arafat Ali
* @group             : 
* @last modified on  : 04-11-2023
* @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class GenerateContactRoleJSONDataTest {
    @TestSetup
    public static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
        Account acc = TestData.createAccount(false);
        acc.Name = 'Clarification Account';
        acc.Customer_Account_Number__c = '4356789';
        acc.RecordTypeId = RecordTypeId;
        insert acc;
        Contact con = TestData.createContact(false, acc.Id);
        con.AccountId = acc.Id;
        con.Phone = '9999999999';
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION'; 
        con.OtherPhone = '';
        con.Other_Email__c = '';
        con.EmailID__c = '';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = '';
        con.Verified__c = True;
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '';
        con.LastName = 'Graham';
        con.Fax = '';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = ''; 
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent';  
        con.MobilePhone = '99999999999'; 
        con.Address_Status__c = '99999999999'; 
        con.LastModifiedDate = System.today();
        con.Title = 'Mr';  
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = ''; 
        con.Source__c = '';
        con.Contact_Status__c = 'Active';
        con.CreatedDate =    System.Today() -1;
        con.LastModifiedDate = System.Today();
        con.Salutation = 'Mr';
        insert con;
    }
    @isTest
    public static void GenerateContactRoleJSON(){
        Account acc  = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact_Roles__c cr = new Contact_Roles__c();
        cr.Primary__c = true;
        cr.Contact__c = con.Id;
        cr.Account__c = acc.Id; 
        cr.Contact_Role_Name__c = 'CLARIFICATIONS';
        cr.CreatedDate =    System.Today() -1;
        cr.LastModifiedDate = System.Today();
        insert cr;
        Test.startTest();
            GenerateContactRoleJSONData.sendContactRoleData(GenerateContactRoleJSONData.insertManyContactRoleJSON(cr), 'INSERT');
            GenerateContactRoleJSONData.sendContactRoleInformation(GenerateContactRoleJSONData.insertManyContactRoleJSON(cr), 'INSERT');
        Test.stopTest();
    }
    @isTest
    public static void UpdateContactRoleJSON(){
        Account acc  = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact_Roles__c cr = new Contact_Roles__c();
        cr.Primary__c = true;
        cr.CreatedDate =    System.Today() -1;
        cr.LastModifiedDate = System.Today();
        cr.Contact__c=con.Id;
        insert cr;
        Set<String> fields = new Set<String>();
        fields.add('Primary__c');
        fields.add('Contact__c');
        fields.add('Account__c');
        fields.add('Contact_Role_Name__c');
        fields.add('LastModifiedById');
        fields.add('Customer_Account_Number__c');
        fields.add('CreatedDate');
        List<Contact_Roles__c> lstContactRole = KoozieUtility.getAllFieldValues('Contact_Roles__c', cr.Id);
        Test.startTest();
            GenerateContactRoleJSONData.sendContactRoleData(GenerateContactRoleJSONData.UpdateoneContactRoleJSON(lstContactRole.get(0),  fields), 'UPDATE');
            GenerateContactRoleJSONData.sendContactRoleInformation(GenerateContactRoleJSONData.insertManyContactRoleJSON(lstContactRole.get(0)), 'UPDATE');
        Test.stopTest();
    }
    @isTest
    public static void UpdateContactRoleJSON2(){
        Account acc  = [SELECT Id FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact_Roles__c cr = new Contact_Roles__c();
        cr.Primary__c = true;
        cr.CreatedDate =    System.Today() -1;
        cr.LastModifiedDate = System.Today();
        cr.Contact_Role_Name__c='CLARIFICATIONS';
        insert cr;
        Set<String> fields = new Set<String>();
        fields.add('Primary__c');
        fields.add('Contact__c');
        fields.add('Contact_Role_Name__c');
        fields.add('Customer_Account_Number__c');
        List<Contact_Roles__c> lstContactRole = KoozieUtility.getAllFieldValues('Contact_Roles__c', cr.Id);
        Test.startTest();
            GenerateContactRoleJSONData.sendContactRoleData(GenerateContactRoleJSONData.UpdateoneContactRoleJSON(lstContactRole.get(0),  fields), 'UPDATE');
            GenerateContactRoleJSONData.sendContactRoleInformation(GenerateContactRoleJSONData.insertManyContactRoleJSON(lstContactRole.get(0)), 'UPDATE');
        Test.stopTest();
    }
}