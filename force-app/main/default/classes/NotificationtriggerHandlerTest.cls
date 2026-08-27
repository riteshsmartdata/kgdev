/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 12-20-2022
 * @last modified by  : Mohammad Arafat Ali
**/
@istest
public without sharing class NotificationtriggerHandlerTest {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    public static testMethod void replaceFields() {
        List<EBS_Order__c> ebsList = new List<EBS_Order__c>();

        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();

        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.Acc_PO_Contact_Email__c = 'arafata@damco.com';
        acc.Customer_Account_Number__c = '123456';
        acc.Customer_PO_Number__c = '12345';
        acc.Customer_Category__c  = 'CHURCH'; 
        acc.RecordTypeId = accRecTypId;
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Email = 'Test@testing.com';
        con.RecordTypeId = conRecTypId;
        con.Acc_PO_Contact__c = True;
        insert con;

        EBS_Order__c ebsOrder = new EBS_Order__c();
        ebsOrder.Account_Name__c = acc.Id; 
        ebsOrder.PO_Contact_Email__c = 'arafata@damco.com'; 
        ebsOrder.Customer_Account_Number__c = '123456'; 
        ebsOrder.EBS_Order_Number__c = '1234'; 
        Insert ebsOrder;
        
        Notification__c notif = new Notification__c(); 
        notif.EBS_Order__c = ebsOrder.Id;  
        //notif.Template_Name_Formula__c = ebsOrder.Template_Name_Formula__c;
        Insert notif;

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        System.debug('==== ebsOrder.Template_Name_Formula__c ===='+ebsOrder.Template_Name_Formula__c);
        NotificationTriggerHandler.replaceField(new List<EBS_Order__c>{ebsOrder});
        Test.stopTest();
        NotificationTriggerHandler.codeCoverage();
    }  
}