/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ritesh Kumar
**/
@isTest
public with sharing class callingFenerateContactJSONDataTest {
 /*   @testSetUp
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
    }
    
    @isTest
    public static void GenerateContactJSON(){
        
        Contact con = new Contact();
        con.Phone = '9999999999';
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION';
        //con.Account_Industry__c = '';
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
        //con.Salesforce_com_ID__c = '';
        //con.Clean_Phone_Number__c = '';
        //con.CreatedById = '';
        //con.Account_Number__c = '5289';
        con.Email = 'test@testers.com';
        //con.LastModifiedById = '';
        con.Contact_Type__c = 'Permanent';
        //con.Contact_Account_Status__c = '';
        //con.IsDeleted = True;
        con.MobilePhone = '99999999999';
        //con.Territory__c = '99999999999';
        con.Address_Status__c = '99999999999';
        //con.RecordTypeId = ''; 
        con.Title = 'Mr';
        //con.OwnerId = ''; 
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = 'Mr';
        //con.AccountId = '';
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        callingFenerateContactJSONData.ContactRequest cr = new callingFenerateContactJSONData.ContactRequest(); 
        cr.newContact = con;
        callingFenerateContactJSONData.sendContactInformation(new List<callingFenerateContactJSONData.ContactRequest>{cr});
        Test.stopTest();
        
    }
    
     @isTest
    public static void GenerateContactJSON2(){
        
        Set<Id> setOfContactIds = new Set<Id>();
        
        Contact con = new Contact();
        con.Phone = '9999999999';
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION';
        //con.Account_Industry__c = '';
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
        //con.Salesforce_com_ID__c = '';
        //con.Clean_Phone_Number__c = '';
        //con.CreatedById = '';
        //con.Account_Number__c = '5289';
        con.Email = 'test@testers.com';
        //con.LastModifiedById = '';
        con.Contact_Type__c = 'Permanent';
        //con.Contact_Account_Status__c = '';
        //con.IsDeleted = True;
        con.MobilePhone = '99999999999';
        //con.Territory__c = '99999999999';
        con.Address_Status__c = '99999999999';
        //con.RecordTypeId = '';
        con.LastModifiedDate = System.today();
        con.Title = '';
        //con.OwnerId = '';
        con.CreatedDate = System.Today();
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = 'Mr';
        //con.AccountId = '';
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Set<String> fields = new Set<String>();
        fields.add('Phone');
        fields.add('LastName');
        fields.add('Contact_Status__c');
        fields.add('PhoneID__c');
        fields.add('Suffix');
        fields.add('Salutation');
        fields.add('FirstName');
        fields.add('OtherPhoneID__c');
        fields.add('MobilePhone');
        fields.add('Fax');
        fields.add('Email');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('Responsibility_Type__c');

        Test.startTest();
        callingFenerateContactJSONData.ContactRequest cr = new callingFenerateContactJSONData.ContactRequest(); 
        cr.newContact = con;
        cr.oldContact = con;
        callingFenerateContactJSONData.sendContactInformation(new List<callingFenerateContactJSONData.ContactRequest>{cr});
        Test.stopTest();
    }

    @isTest
    public static void GenerateContactJSON3(){
        
        Set<Id> setOfContactIds = new Set<Id>();
        
        Contact con = new Contact();
        con.Phone = '9999999999';
        con.Responsibility_Type__c = 'CLARIFICATION';
        
        con.MiddleName = 'J';
        con.LastName = 'Graham';
        con.Email = 'test@testers.com';
        con.MobilePhone = '99999999999';
        con.FirstName = 'Buller';
        insert con;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Set<String> fields = new Set<String>();
        fields.add('Phone');
        fields.add('PromoStandards_Contact__c');
        fields.add('PrimaryOtherEmailFlag__c');
        fields.add('Top_Producer__c');
        fields.add('Account_Industry__c');
        fields.add('Other_Email__c');
        fields.add('OtherPhone');
        fields.add('PrimaryEmailFlag__c');
        fields.add('EmailID__c');
        fields.add('Date_Verified__c');
        fields.add('FaxID__c');
        fields.add('Verified__c');
        fields.add('MiddleName');
        fields.add('PrimaryFaxFlag__c');
        fields.add('MailingPostalCode');
        fields.add('MailingCity');
        fields.add('MailingCountry');
        fields.add('MailingState');
        fields.add('MailingStreet');
        fields.add('Other_Email_ID__c');
        fields.add('Account_Number__c');
        fields.add('LastName');
        fields.add('Contact_Status__c');
        fields.add('PhoneID__c');
        fields.add('Suffix');
        fields.add('Salutation');
        fields.add('FirstName');
        fields.add('OtherPhoneID__c');
        fields.add('MobilePhone');
        fields.add('Fax');
        fields.add('Email');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('Responsibility_Type__c');

        Test.startTest();
        callingFenerateContactJSONData.ContactRequest cr = new callingFenerateContactJSONData.ContactRequest(); 
        cr.newContact = con;
        cr.oldContact = con;
        callingFenerateContactJSONData.sendContactInformation(new List<callingFenerateContactJSONData.ContactRequest>{cr});
        Test.stopTest();
    }*/
}