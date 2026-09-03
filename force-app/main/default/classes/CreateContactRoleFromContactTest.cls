/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 12-07-2022
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class CreateContactRoleFromContactTest {
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
    public static testmethod void CreateContactRoleAccPoContactIsTrue() {
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
        
        Contact_Roles__c cr3 = new Contact_Roles__c();
        cr3.Contact_Role_Name__c = 'ACC SHIPPING CONTACT';
        cr3.Account__c = acc.Id;
        cr3.Contact__c = con.Id;
        Insert cr3;  

        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
        CreateContactRoleFromContact.CreateContactRole(new List<Contact>{con});
        Test.stopTest();
    }

    public static testmethod void CreateContactRoleAccOrderAcknoledgeIsTrue() {
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
        con.Acc_PO_Contact__c = false;
        con.Acc_Order_Acknowledgement__c = true;
        con.Acc_Shipping_Contact__c = false;
        Insert con; 

        Contact_Roles__c cr1 = new Contact_Roles__c();
        cr1.Contact_Role_Name__c = 'ACC PO CONTACT';
        cr1.Account__c = acc.Id;
        cr1.Contact__c = con.Id;
        Insert cr1;
        
        Contact_Roles__c cr3 = new Contact_Roles__c();
        cr3.Contact_Role_Name__c = 'ACC SHIPPING CONTACT';
        cr3.Account__c = acc.Id;
        cr3.Contact__c = con.Id;
        Insert cr3;  

        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
        CreateContactRoleFromContact.CreateContactRole(new List<Contact>{con});
        Test.stopTest();
    }

    public static testmethod void CreateContactRoleAccShippingIsTrue() {
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
        con.Acc_PO_Contact__c = false;
        con.Acc_Order_Acknowledgement__c = false;
        con.Acc_Shipping_Contact__c = true;
        Insert con; 

        Contact_Roles__c cr1 = new Contact_Roles__c();
        cr1.Contact_Role_Name__c = 'ACC PO CONTACT';
        cr1.Account__c = acc.Id;
        cr1.Contact__c = con.Id;
        Insert cr1;
        
        Contact_Roles__c cr2 = new Contact_Roles__c();
        cr2.Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT';
        cr2.Account__c = acc.Id;
        cr2.Contact__c = con.Id;
        Insert cr2;   

        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
        CreateContactRoleFromContact.CreateContactRole(new List<Contact>{con});
        Test.stopTest();
    }
}