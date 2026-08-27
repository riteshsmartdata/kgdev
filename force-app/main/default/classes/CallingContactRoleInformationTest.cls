/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 07-21-2022
* @last modified by  : Ritesh Kumar
**/
@isTest
public with sharing class CallingContactRoleInformationTest {
    @TestSetup
    public static void makeData(){
        
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
    }
    
    @isTest
    public static void GenerateContactRoleJSON(){
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Clarification Account';
        acc.Customer_Account_Number__c = '4356789';
        acc.RecordTypeId = RecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        
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
        con.CreatedDate = System.Today();
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = ''; 
        con.Source__c = '';
        con.Contact_Status__c = 'Active';
        con.LastModifiedDate = System.Today();
        con.Salutation = 'Mr';
        insert con; 
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Contact_Roles__c cr = new Contact_Roles__c();
        
        cr.Primary__c = true;
        cr.Contact__c = con.Id;
        cr.Account__c = acc.Id; 
        cr.Contact_Role_Name__c = 'CLARIFICATIONS';  
        insert cr;
        
        CallingContactRoleInformation.ContactRoleRequest contactRole = new CallingContactRoleInformation.ContactRoleRequest();
        contactRole.oldContactRole = cr; 
        
        Test.startTest();
        CallingContactRoleInformation.sendContactRoleInformation(new List<CallingContactRoleInformation.ContactRoleRequest>{contactRole});
        Test.stopTest();
        
    }

    @isTest
    public static void GenerateContactRoleJSON_A(){
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Clarification Account';
        acc.Customer_Account_Number__c = '4356789';
        acc.RecordTypeId = RecordTypeId;
        insert acc;
        
        Contact con = new Contact();
        
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
        con.Title = 'Mr';  
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = ''; 
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con; 
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Contact_Roles__c cr = new Contact_Roles__c();
         
        cr.Contact__c = con.Id;
        cr.Account__c = acc.Id; 
        cr.Contact_Role_Name__c = 'CLARIFICATIONS';  
        insert cr;
        
        CallingContactRoleInformation.ContactRoleRequest contactRole = new CallingContactRoleInformation.ContactRoleRequest();
        contactRole.oldContactRole = cr; 
        
        Test.startTest();
        CallingContactRoleInformation.sendContactRoleInformation(new List<CallingContactRoleInformation.ContactRoleRequest>{contactRole});
        Test.stopTest();
        
    }
    
    @isTest
    public static void UpdateContactRoleJSON_B(){
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Clarification Account';
        acc.Customer_Account_Number__c = '4356789';
        acc.RecordTypeId = RecordTypeId;
        insert acc; 
        
        Contact con = new Contact();
        
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
        con.Title = 'Mr';  
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = ''; 
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Contact_Roles__c cr = new Contact_Roles__c();
        
        cr.Primary__c = true;
        cr.Contact__c = con.Id;
        cr.Account__c = acc.Id; 
        cr.Contact_Role_Name__c = 'CLARIFICATIONS';  
        insert cr;
        
        CallingContactRoleInformation.ContactRoleRequest contactRole = new CallingContactRoleInformation.ContactRoleRequest();
        contactRole.oldContactRole = cr; 
        contactRole.newContactRole = cr;
        
        Test.startTest();
        CallingContactRoleInformation.sendContactRoleInformation(new List<CallingContactRoleInformation.ContactRoleRequest>{contactRole});
        Test.stopTest(); 
    }

    
    @isTest
    public static void UpdateContactRoleJSON(){
        
        Id RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Clarification Account';
        acc.Customer_Account_Number__c = '4356789';
        acc.RecordTypeId = RecordTypeId;
        insert acc; 
        
        Contact con = new Contact();
        
        con.AccountId = acc.Id;
        con.Phone = '9999999999'; 
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
         
        con.Email = 'test@testers.com';  
        con.Title = 'Mr' ;
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Contact_Roles__c cr = new Contact_Roles__c(); 
        cr.Contact__c = con.Id;
        cr.Account__c = acc.Id;  
        insert cr;
        
        CallingContactRoleInformation.ContactRoleRequest contactRole = new CallingContactRoleInformation.ContactRoleRequest();
        contactRole.oldContactRole = cr; 
        contactRole.newContactRole = cr;
        
        Test.startTest();
        CallingContactRoleInformation.sendContactRoleInformation(new List<CallingContactRoleInformation.ContactRoleRequest>{contactRole});
        Test.stopTest(); 
    }
}