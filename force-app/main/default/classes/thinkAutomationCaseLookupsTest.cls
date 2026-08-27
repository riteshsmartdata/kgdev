/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   01-31-2024   Ritesh Kumar   Initial Version
 * 
 * * Ver   Date         Author         Modification
 * 1.1   02-17-2026   Sandeep Reddy   Initial Version
**/

@IsTest
public with sharing class thinkAutomationCaseLookupsTest {

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
    public static void makeData(){
        Account accountRecord =  TestData.createAccount(FALSE);
        accountRecord.Customer_Account_Number__c = '159753215';
        Insert accountRecord;
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact contactRecord = TestData.createContact(FALSE,accountRecord.Id);
        contactRecord.email = 'cshotel@kooziegroup.com';
        Insert contactRecord;
        
        EBS_Order__c orderRecord = TestData.createEBSOrder(FALSE);
        orderRecord.PO_Contact_Email__c = 'cshotel@kooziegroup.com';
        orderRecord.Customer_Account_Number__c = '159753215';
        orderRecord.EBS_Order_Number__c = '363636565';
        Insert orderRecord;

        EBS_Order_Line__c orderLineRecord = TestData.createEBSOrderLine(false);
        orderLineRecord.Order__c = orderRecord.Id;
        Insert orderLineRecord;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '363636565';
        act.Customer_Category__c = 'Hotel';
        insert act;
    }

    @IsTest
    public static void testThinkAutomation() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        css.EBS_Account_Number__c ='159753215';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        css.SuppliedEmail = 'FirstName@test.com';
        css.Proof_Team__c = 'testt';
        css.Clarification_Team__c = 'testt';
        css.SuppliedEmail = 'test@example.com';
        Css.EBS_Order__c = [SELECT Id FROM EBS_Order__c WHERE EBS_Order_Number__c = '363636565'  LIMIT 1].Id;
        css.EBS_Order_ID__c = '363636565';
        css.ContactId = [SELECT Id FROM Contact LIMIT 1].Id;
        Insert css;
        
        Test.startTest();
        Set<Id> csid = new Set<Id>();
        csid.add(css.Id);
       // thinkAutomationCaseLookups.taCaseLookups( csid, 'Insert', 'Case');
        TACaseLookupsQueueable job = new TACaseLookupsQueueable(csid, 'Insert', 'Case');
        System.enqueueJob(job);

        thinkAutomationCaseLookups.taCaseTeamLookups( csid);
        Test.stopTest(); 
    }
}