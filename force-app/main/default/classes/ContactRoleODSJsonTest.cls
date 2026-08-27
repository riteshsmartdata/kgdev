/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 12-03-2024
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   12-03-2024   Ritesh Kumar   JIRA SF-986
**/

@isTest
public class ContactRoleODSJsonTest {
    
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
    
    @isTest
    public static void testJSON(){
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.Acc_PO_Contact_Email__c = 'arafata@damco.com';
        acc.Customer_Account_Number__c = '123456';
        acc.Customer_PO_Number__c = '12345';
        acc.RecordTypeId = accRecTypId;
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact 0';
        con.AccountId = acc.Id;
        con.Email = 'Test0@testing.com';
        con.RecordTypeId = conRecTypId;
        con.Acc_PO_Contact__c = true;
        con.Acc_Order_Acknowledgement__c = false;
        con.Acc_Shipping_Contact__c = false;
        Insert con; 
        
         Contact_Roles__c cr2 = new Contact_Roles__c();
        cr2.Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT';
        cr2.Account__c = acc.Id;
        cr2.Contact__c = con.Id;
        Insert cr2; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact_And_Contact_Role_Settings__mdt apiSetting = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');
        Apex_Errors__c errorRecord = ContactRoleODSJson.syncContactRoleODS(cr2,apiSetting);
        Test.stopTest();
       
       
        
        
    }
}