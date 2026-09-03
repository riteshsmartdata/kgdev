/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Ritesh Kumar
 * Ver   Date         Author         Modification
 * 1.0   09-19-2023   Ritesh Kumar   JIRA SF-SF-782
 * 1.1   19-10-2023   Ritesh Kumar   JIRA SF-469
**/
@isTest
public class ContactUtillTest {
    @TestSetup
    static void makeData(){
        List<Contact> lstInsertContact = new List<Contact>();
        Id financeRecordTypeId = KoozieUtility.getRecordTypeId('Contact', 'Finance Contact');
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;

        AppInfo__c ce_web = new AppInfo__c();
        ce_web.Name = 'WebClient';
        ce_web.User__c = 'webclient';
        ce_web.Password__c = 'eh8q4ya4bvnx5';
        ce_web.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce_web;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Account Record Creation
        Account accountRecord = TestData.createAccount(false);
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        accountRecord.BillingStreet = 'Test';
        accountRecord.BillingState = 'Test';
        accountRecord.BillingCity = 'Test';
        accountRecord.BillingCountry = 'US';
        accountRecord.BillingPostalCode = '110011';
        accountRecord.ShippingStreet = 'Test';
        accountRecord.ShippingState = 'Test';
        accountRecord.ShippingCity = 'Test';
        accountRecord.ShippingCountry = 'US';
        accountRecord.ShippingPostalCode = '110011';
        insert accountRecord;
        // Contact Record Creation
        Contact contactRecord = TestData.createContact(false, accountRecord.Id);
        contactRecord.LastName = 'Test Last Name';
        contactRecord.FirstName = 'Test First Name';
        contactRecord.Email = 'test@test.com.full';
        contactRecord.Salutation  = 'Mr';
        contactRecord.Acc_Clarification_Confirmation__c = true;
        contactRecord.Acc_Order_Acknowledgement__c = true; 
        contactRecord.Acc_Shipping_Contact__c = true;
        lstInsertContact.add(contactRecord);

        Contact cont = TestData.createContact(false,accountRecord.Id);
        cont.LastName = 'Last Name';
        cont.FirstName = 'First Name';
        cont.Email = 'othertest@test.com.full';
        cont.Salutation  = 'Mr';
        // cont.PO_Confirmation__c = 'Both';
        // cont.Shipment_Confirmation__c = 'Both';
        // cont.Proof_Confirmation__c = 'Both';
        // cont.When_Status_changes__c = 'Both';
        // cont.Clarification_Confirmation__c = 'Email';
        cont.Acc_PO_Contact__c = true;
        cont.Acc_Proof_Confirmation__c = true;
        cont.Web_Id__c = '23475627345';
        cont.Contact_Type__c = 'Field Sales';
        cont.Acc_Clarification_Confirmation__c = true;
        cont.MobilePhone = '8708060525';
        cont.User_Name__c = 'Test User';
        cont.RecordTypeId = financeRecordTypeId;
        cont.Acc_Order_Acknowledgement__c = true; 
        cont.Acc_Shipping_Contact__c = true;
        lstInsertContact.add(cont);

        Contact cont2 = new Contact();
        cont2.FirstName = 'testContactTest';
        cont2.LastName = 'TestContact';
		cont2.email = 'TestContact@test.com.full';
        cont2.Phone = '8708060525';
        cont2.MobilePhone = '8708060525'; 
        cont2.Web_Id__c='8374827354';
        cont2.User_Name__c = 'Test User';
        cont2.Acc_PO_Contact__c = false;
        cont2.Acc_Order_Acknowledgement__c = false; 
        cont2.Acc_Shipping_Contact__c = false;
        cont2.Acc_Proof_Confirmation__c=false;
        cont2.Acc_Clarification_Confirmation__c=false;
        lstInsertContact.add(cont2);
        insert lstInsertContact;
    }
    @isTest    
    private static void contactResponse_UntiTest(){
        Contact contactRecord = [SELECT Id FROM Contact WHERE Email = 'test@test.com.full' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE Email = 'othertest@test.com.full' LIMIT 1];
        List<Contact> con = KoozieUtility.getAllFieldValues('Contact', cont.Id); 
        List<Contact> conRec =  KoozieUtility.getAllFieldValues('Contact', contactRecord.Id);
        Account accountRecord = [SELECT Id,Customer_Account_Number__c FROM Account LIMIT 1];
        Test.startTest();
            ContactUtill.contactRequest(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.contactResponse(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.contactResponseForm(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.checkContact(conRec.get(0).Email,  accountRecord.Customer_Account_Number__c);
            ContactUtill.getFieldDifference(conRec.get(0), con.get(0));
        Test.stopTest();
    }
    @isTest
    private static void contactResponse_UntiTest2(){
        Contact contactRecord = [SELECT Id FROM Contact WHERE FirstName = 'testContactTest' LIMIT 1];
        Contact cont = [SELECT Id FROM Contact WHERE Email = 'othertest@test.com.full' LIMIT 1];
        List<Contact> con = KoozieUtility.getAllFieldValues('Contact', cont.Id); 
        List<Contact> conRec =  KoozieUtility.getAllFieldValues('Contact', contactRecord.Id);
        Account accountRecord = [SELECT Id,Customer_Account_Number__c FROM Account LIMIT 1];
        Test.startTest();
            ContactUtill.contactRequest(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.contactResponse(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.contactResponseForm(conRec.get(0).Id, 'Contact', 'DML');
            ContactUtill.checkContact(conRec.get(0).Email,  accountRecord.Customer_Account_Number__c);
            ContactUtill.getFieldDifference(conRec.get(0), con.get(0));
        Test.stopTest();
    }
    
}