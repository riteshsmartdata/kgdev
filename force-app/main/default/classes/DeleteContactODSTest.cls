/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 08-03-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   07-25-2023   Ritesh Kumar   JIRA Ticket Number : SF-663
**/

@IsTest
public with sharing class DeleteContactODSTest {
    @testSetup
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox'; 
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(202);
            return res;
        }
    }
    
    @isTest
    public static void deleteContact_UnitTest(){

        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        Insert accountRecord; 

        Contact record = new Contact();
        record.Phone = '9999999999';
        record.PromoStandards_Contact__c = True;
        record.PrimaryOtherEmailFlag__c = True;
        record.Top_Producer__c = True;
        record.Responsibility_Type__c = 'CLARIFICATION';
        record.OtherPhone = '';
        record.Other_Email__c = '';
        record.EmailID__c = '';
        record.Date_Verified__c = System.Today();
        record.FaxID__c = '';
        record.Verified__c = True;
        record.MiddleName = 'J';
        record.MailingPostalCode = '250002';
        record.MailingCity = 'Texas';
        record.MailingCountry = 'US';
        record.MailingState = 'Nevada';
        record.MailingStreet = 'JASON Street';
        record.Other_Email_ID__c = '';
        record.LastName = 'Graham';
        record.Fax = '';
        record.PrimaryOtherPhoneFlag__c = True;
        record.Address_Type__c = '';
        record.Email = 'test@testers.com';
        record.Contact_Type__c = 'Permanent';
        record.MobilePhone = '99999999999';
        record.Address_Status__c = '99999999999';
        record.Title = 'Mr'; 
        record.OtherPhoneID__c = '';
        record.PhoneID__c = '';
        record.HasOptedOutOfEmail = True;
        record.FirstName = 'Buller';
        record.Do_Not_Mail__c = True;
        record.Suffix = 'Mr';
        record.Source__c = '';
        record.Contact_Status__c = 'Active'; 
        record.Salutation = 'Mr';
        record.AccountId  = accountRecord.Id;
        insert record; 
         
        Test.startTest();
        DeleteContactODS.syncContactThroughBatch(record.Id);
        Delete record;
        Test.stopTest();
        
    }
    
}