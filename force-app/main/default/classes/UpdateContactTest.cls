/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 01-20-2025
* @last modified by  : Ritesh Kumar
* Ver   Date         Author         Modification
* 1.0   10-13-2022   Ritesh Kumar   
* 1.1   10-20-2023   Ritesh Kumar   JIRA SF-469
**/
@isTest
public with sharing class UpdateContactTest {
	
    @testSetup
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox'; 
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void updateContact_UnitTest(){
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        Insert accountRecord;
        
        
        // Contact Record Creation
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
        Insert contactRecord;
        
        Contact con = new Contact();
        con.Phone = '9999999999';
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION';
        con.OtherPhone = '';
        con.Other_Email__c = '';
        con.EmailID__c = '';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = '';
        con.Verified__c = True;
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '';
        con.LastName = 'Graham';
        con.Fax = '';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = '';
        con.Email = 'test@testers.com';
        con.Contact_Type__c = 'Permanent';
        con.MobilePhone = '99999999999';
        con.Address_Status__c = '99999999999';
        con.Title = 'Mr'; 
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = 'Mr';
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        con.Last_Login_Date__c = System.now();
        con.AccountId  = accountRecord.Id;
        insert con;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/UpdateContact/';
        request.httpMethod = 'POST';
        String requestBody = ContactUtill.contactRequest(con.Id, 'Contact', 'DML').getAsString();
		request.requestBody = Blob.valueof(requestBody);
		
        RestContext.request = request;
        RestContext.response = response;
       
        Test.startTest();
        UpdateContact.getContactRequest(); 
        Test.stopTest();
    }
    
    @isTest
    public static void updateContact_SIFD(){
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '24254';
        Insert accountRecord;
                
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/UpdateContact/';
        request.httpMethod = 'POST'; 
        Test.startTest(); 
            String requestBody = '{"EventRequest":{"EventBusinessID":"ashwath.shetty@kooziegroup.com.text","EventDateTime":"2024-05-14T09:28:00","EventObject":"CUSTOMER","EventSourceSystem":"GN","EventType":"DML","CustomerData":{"sf_Id":null,"web_Id":"5f75d4a88ab1ad02nbnb987c0962","userName":"c000090","accountNumber":"24254","firstName":"Ashwathh","lastName":"Shetty","contactType":"Owner;Sales Manager","industryType":"Legal","emailId":"ashwath.shetty@kooziegroup.com.text","primaryPhone":"9819717715","Mobile":"9819717716","marketingLink":"https://cloud.m.kooziegroup.com/preference_center?SubKey=0033p00002gvQVq&Email=ashwath.shetty@kooziegroup.com.text","lastLoginDate":"2024-05-14T09:27:38","preferanceTypes":[{"preferanceTypeName":"Order Communication","preferanceTypeId":"Order_Communication","preferanceTypeDetails":null,"preferanceTypeDetailsId":null,"preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"None","Value":"None","Selected":"true"},{"Text":"Email","Value":"Email","Selected":"false"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"None","Value":"None","Selected":"true"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"None","Value":"None","Selected":"true"},{"Text":"Email","Value":"Email","Selected":"false"}]}]}],"accountPreferences":{"firstName":"Rob","lastName":"Meier","emailId":"sales@greatvaluepromos.com.test","salesforceId":"0033p00002XWuCHAA1","mobileNo":"123456789","Acc_poConfirmation":false,"Acc_orderAcceptance":false,"Acc_shipmentConfirmation":false,"Acc_proofConfirmation":true,"Acc_clarificationConfirmation":true,"selectedMethod":"Email"}}}}';
            request.requestBody = Blob.valueof(requestBody);
            
            RestContext.request = request;
            RestContext.response = response;
        	UpdateContact.getContactRequest();
        Test.stopTest();
    }
    
}