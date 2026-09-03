/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class SendContactInformationBatchTest {
     
   /* @TestSetup
    public static void makeData(){

        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
        
        Contact con = new Contact();
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
    }

    @isTest
    public static void sendContactInformation_test(){
        Test.StartTest();
        SendContactInformationBatch myBatchObject = new SendContactInformationBatch(); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id batchId = Database.executeBatch(myBatchObject, 1);
        
        Test.StopTest();
    }*/
}