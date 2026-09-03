/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 08-09-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-09-2023   Ritesh Kumar   Initial Version
**/

@isTest
public class ContactRoleHandlerTest {
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
    @TestSetup
    private static void makeData(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
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
        con.Email = 'Test0@testing.com.full';
        con.RecordTypeId = conRecTypId;
        con.Acc_PO_Contact__c = true;
        con.Acc_Order_Acknowledgement__c = true;
        con.Acc_Shipping_Contact__c = true;
        insert con;
    }
    @isTest
    public static void handelRoleTest() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Contact> lstContact = [SELECT Id,Email FROM Contact WHERE Email = 'Test0@testing.com.full' LIMIT 1];
        List<Contact> lstUpdateContact = new List<Contact>();
        for(Contact con : lstContact){
            con.Acc_PO_Contact__c = false;
            con.Acc_Order_Acknowledgement__c = false;
            con.Acc_Shipping_Contact__c = false;
            lstUpdateContact.add(con);
        }
        update lstUpdateContact;
    }
}