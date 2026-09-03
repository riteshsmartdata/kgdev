/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-26-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-21-2023   Ritesh Kumar   JIRA SF-884
**/
@isTest
public class DeleteWebsiteContactTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('Error : {Error:{ "data":"Testing error"}} ;; {"Error":"Error Test"}, 202\', \'003XXXXXX123');
            res.setStatusCode(202);
            return res;
        }
    }
    @TestSetup
    public static void makeData(){
        TestDataFactory testDataFactory = new TestDataFactory('Setup');
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountRecord = TestData.createAccount(false);
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        insert accountRecord;

        Contact record = TestData.createContact(false, accountRecord.Id);
        record.Phone = '9999999999';
        record.Web_Id__c='72348734';
        record.PromoStandards_Contact__c = True;
        record.PrimaryOtherEmailFlag__c = True;
        record.Top_Producer__c = True;
        record.Responsibility_Type__c = 'CLARIFICATION';
        record.OtherPhone = '';
        record.Other_Email__c = '';
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
    }
    @isTest
    public static void deleteContact_UnitTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [SELECT Id FROM Contact LIMIT 1]; 
        delete record;
        Test.startTest();
            Contact deletedRecord = [SELECT Id FROM Contact WHERE IsDeleted = TRUE AND Id =:record.Id  ALL ROWS];
            DeleteWebsiteContact.sendDeleteContactRequest(deletedRecord.Id);
            DeleteWebsiteContact.generateJSON(deletedRecord.Id);
        Test.stopTest();
    }
    @isTest
    public static void deleteContact_UnitTest2(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [SELECT Id FROM Contact LIMIT 1]; 
        Test.startTest();
            DeleteWebsiteContact.sendDeleteContactRequest(record.Id);
            DeleteWebsiteContact.generateJSON(record.Id);
        Test.stopTest();
    }
}