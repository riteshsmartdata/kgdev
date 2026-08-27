/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Kumar Saurav
 * JIRA TICKET        : SF-478
**/
/*@isTest
public without sharing class PopulateAccEmailTest {

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

    public static testMethod void populateAccEmailTest() {
        // Create test data for accounts, contacts, and orders
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            Email = 'test@testing.com'
        );
        insert con;

        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'arafata@damco.com',
            Order_Confirmation_Email__c = 'arafata@damco.com',
            Shipping_Notification_Email__c = 'arafata@damco.com',
            Customer_Account_Number__c = '123456',
            EBS_Order_Number__c = '1234',
            Send_Lead_Time_Notification__c = true,
            PO_Contact__c = con.Id,
            Order_Confirm_Contact__c = con.Id,
            Shipping_Notif_Contact__c = con.Id,
            Additional_Emails__c = 'test123@test.com'
        );
        insert ebsOrder;

        Test.setMock(HttpCalloutMock.class, new RestMock());

        Test.startTest();
        PopulateAccEmails.populateEmail(new List<EBS_Order__c>{ ebsOrder }); 
        Test.stopTest();

        // Assert that Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c, and Acc_Shipping_Notif_Contact_To_Email__c are populated correctly
        ebsOrder = [SELECT Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c, Acc_Shipping_Notif_Contact_To_Email__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals('arafata@damco.com, test123@test.com', ebsOrder.Acc_PO_Contact_To_Email__c);
        System.assertEquals('arafata@damco.com, test123@test.com', ebsOrder.Acc_Order_Confirm_Contact_To_Email__c);
        System.assertEquals('arafata@damco.com, test123@test.com', ebsOrder.Acc_Shipping_Notif_Contact_To_Email__c);
    }
}*/

@isTest
public without sharing class PopulateAccEmailTest {

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
    public static testMethod void populateAccPoContactCcEmailValuesTest() {

        List<EBS_Order__c> ebsList = new List<EBS_Order__c>();
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
        ebsOrder.Send_Lead_Time_Notification__c = true;
        ebsOrder.Acc_PO_Contact_To_Email__c = 'nik@abctestinvalid.com, nik2@abctestinvalid2.com';
        ebsOrder.Lead_Time_Template__c = 'Koozie: Lead Time Automation';
        ebsOrder.PO_Contact__c = con.Id;
        ebsOrder.Additional_Emails__c = 'test123@test.com';
        ebsList.add(ebsOrder); 

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        PopulateAccEmails.populateEmail(ebsList); 
        Test.stopTest();
    }
     public static testMethod void populateAccPoContactCcEmailValuesTest1() {

        List<EBS_Order__c> ebsList = new List<EBS_Order__c>();
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();

        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.Acc_Order_Confirmation_Contact_Email__c = 'arafata@damco.com';
        acc.Customer_Account_Number__c = '123456';
        acc.Customer_PO_Number__c = '12345';
        acc.RecordTypeId = accRecTypId;
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Email = 'Test@testing.com';
        con.RecordTypeId = conRecTypId;
        con.Acc_Order_Acknowledgement__c = True;
        insert con;

        EBS_Order__c ebsOrder = new EBS_Order__c();
        ebsOrder.Account_Name__c = acc.Id; 
        ebsOrder.Order_Confirmation_Email__c = 'arafata@damco.com'; 
        ebsOrder.Customer_Account_Number__c = '123456'; 
        ebsOrder.EBS_Order_Number__c = '1234';
        ebsOrder.Send_Lead_Time_Notification__c = true;
        ebsOrder.Acc_Order_Confirm_Contact_To_Email__c = 'nik@abctestinvalid.com, nik2@abctestinvalid2.com';
        ebsOrder.Lead_Time_Template__c = 'Koozie: Lead Time Automation';
        ebsOrder.Order_Confirm_Contact__c = con.Id;
        ebsOrder.Additional_Emails__c = 'test123@test.com';
        ebsList.add(ebsOrder); 

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        PopulateAccEmails.populateEmail(ebsList); 
        Test.stopTest();
    }
    
   @isTest
    static void testPopulateEmail() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            Email = 'test@example.com',
            RecordType = new RecordType(Name = 'CRM Contact'),
            PO_Confirmation__c = 'Email', // Ensure this is set to 'Active'
            Acc_PO_Contact__c = true // Ensure this is set to true
        );
        insert con;
        
        EBS_Order__c order = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'test@example.com',
            Order_Confirmation_Email__c = 'test@example.com',
            Shipping_Notification_Email__c = 'test@example.com'
        );
        insert order;
        
        Test.startTest();
        // Call the method to be tested
        PopulateAccEmails.populateEmail(new List<EBS_Order__c>{order});
         Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
        
        // Query the order to check if the emails were populated correctly
        EBS_Order__c updatedOrder = [SELECT Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c, Acc_Shipping_Notif_Contact_To_Email__c FROM EBS_Order__c WHERE Id = :order.Id];
        
        // Assert that the emails were populated correctly
        System.assertEquals('test@example.com', updatedOrder.Acc_PO_Contact_To_Email__c);
        System.assertEquals('test@example.com', updatedOrder.Acc_Order_Confirm_Contact_To_Email__c);
        System.assertEquals('test@example.com', updatedOrder.Acc_Shipping_Notif_Contact_To_Email__c);
    }

 @isTest
    static void testPopulateShippingEmail() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            Email = 'test@example.com',
            RecordType = new RecordType(Name = 'CRM Contact'),
            Shipment_Confirmation__c = 'Email', // Ensure this is set to 'Active'
            Acc_Shipping_Contact__c = true // Ensure this is set to true
        );
        insert con;
        
        EBS_Order__c order = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'test@example.com',
            Order_Confirmation_Email__c = 'test@example.com',
            Shipping_Notification_Email__c = 'test@example.com'
        );
        insert order;
        
        Test.startTest();
        // Call the method to be tested
        PopulateAccEmails.populateEmail(new List<EBS_Order__c>{order});
		Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
        
        // Query the order to check if the emails were populated correctly
        EBS_Order__c updatedOrder = [SELECT Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c, Acc_Shipping_Notif_Contact_To_Email__c FROM EBS_Order__c WHERE Id = :order.Id];
        
        // Assert that the emails were populated correctly
        System.assertEquals('test@example.com', updatedOrder.Acc_PO_Contact_To_Email__c);
        System.assertEquals('test@example.com', updatedOrder.Acc_Order_Confirm_Contact_To_Email__c);
        System.assertEquals('test@example.com', updatedOrder.Acc_Shipping_Notif_Contact_To_Email__c);
    }
}