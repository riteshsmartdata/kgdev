/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 08-18-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   08-17-2023   Mohammad Arafat Ali   Initial Version
**/
@isTest
public without sharing class DeleteContactRoleODS_Test {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    private class RestMockError implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "ERROR", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(400);
            return res;
        }
    }
    @isTest
    public static void deleteContactRoleTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = 'test123';
        Database.Insert(accountRecord); 
        Contact record = new Contact();
        record.Phone = '9999999999';
        record.Responsibility_Type__c = 'CLARIFICATION';
        record.LastName = 'Graham';
        record.Email = 'test@testers.com';
        record.FirstName = 'Buller';
        record.Contact_Status__c = 'Active'; 
        record.AccountId  = accountRecord.Id; 
        Database.Insert(record);
        Contact_Roles__c contactRoleRecord = new Contact_Roles__c();
        contactRoleRecord.Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT';
        contactRoleRecord.Account__c = accountRecord.Id;
        contactRoleRecord.Contact__c = record.Id;
        Insert contactRoleRecord;  
        Test.startTest(); 
            DeleteContactRoleODS.deleteOdsContactRole(record.Id);
            DeleteContactRoleODS.syncContactRoleThroughBatch(contactRoleRecord.Id);
        Test.stopTest();
    }
    @isTest
    public static void deleteContactRoleTest2(){
        Test.setMock(HttpCalloutMock.class, new RestMockError());
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = 'test123';
        Database.Insert(accountRecord); 
        Contact record = new Contact();
        record.Phone = '9999999999';
        record.Responsibility_Type__c = 'CLARIFICATION';
        record.LastName = 'Graham';
        record.Email = 'test@testers.com';
        record.FirstName = 'Buller';
        record.Contact_Status__c = 'Active'; 
        record.AccountId  = accountRecord.Id; 
        Database.Insert(record);
        Contact_Roles__c contactRoleRecord = new Contact_Roles__c();
        contactRoleRecord.Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT';
        contactRoleRecord.Account__c = accountRecord.Id;
        contactRoleRecord.Contact__c = record.Id;
        Insert contactRoleRecord;  
        Test.startTest(); 
            DeleteContactRoleODS.deleteOdsContactRole(record.Id);
            DeleteContactRoleODS.syncContactRoleThroughBatch(contactRoleRecord.Id);
        Test.stopTest();
    }
}