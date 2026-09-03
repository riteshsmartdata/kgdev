/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-13-2023   Ritesh Kumar   Initial Version
**/
@IsTest
public without sharing class ContactSynBatchTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        insert accountRecord;
        
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Test Last Name';
        contactRecord.FirstName = 'Test First Name';
        contactRecord.Email = 'test@test.com';
        contactRecord.MobilePhone = '8754122356';
        contactRecord.AccountId  = accountRecord.Id;
        contactRecord.Acc_PO_Contact__c = true;
        contactRecord.Acc_Order_Acknowledgement__c = true;
        contactRecord.Acc_Shipping_Contact__c = true;
        contactRecord.Acc_Proof_Confirmation__c = true;
        contactRecord.Acc_Clarification_Confirmation__c= true;
        contactRecord.API_Callout_Required__c = true;
        insert contactRecord;
    }
    @IsTest
    static void testMethodName() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
            Id jobId  = Database.executeBatch(new ContactSynBatch(),1);
            system.assertEquals(true,String.isNotBlank(jobId),'batch was not executed!!');
        Test.stopTest();
    }
}