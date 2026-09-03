/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 01-20-2025
* @last modified by  : Ritesh Kumar
* Ver   Date         Author         Modification
* 1.0   10-13-2022   Ritesh Kumar   
* 1.1   19-10-2023   Arafat         JIRA SF-469 
**/
@isTest
public class CreateContactsTest {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse(); 
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"test@testers.com","EventStatus":"SUCCESS","EventType":"DML","EventStatusMessage":"Successfully Completed","CustomerData":{"sf_Id":"0035300000BK8KAAA1","web_Id":"5c9e20578513d211813ed6e5a43","userName":"test@testers.com","accountNumber":"24254","firstName":"Rob","lastName":"Meier","contactType":"Other","emailId":"test@testers.com","primaryPhone":null,"Mobile":null,"preferanceTypes":[{"preferanceTypeName":"Order Communication","preferanceTypeId":"Order_Communication","preferanceTypeDetails":null,"preferanceTypeDetailsId":null,"preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]}]}]}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMock2 implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"test@testers.com","EventStatus":"SUCCESS","EventType":"DML","EventStatusMessage":"Successfully Completed","CustomerData":{"sf_Id":"null","web_Id":"5c9e20578513d211813ed6e5a43","userName":"test@testers.com","accountNumber":"24254","firstName":"Rob","lastName":"Meier","contactType":"Other","emailId":"test@testers.com.full","primaryPhone":null,"Mobile":null,"accountPreferences":[{"emailId":"test@testers.com.full"}],"preferanceTypes":[{"preferanceTypeName":"Order Communication","preferanceTypeId":"Order_Communication","preferanceTypeDetails":null,"preferanceTypeDetailsId":null,"preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]}]}]}}}');
            // res.setBody('{}');
            res.setStatusCode(400);
            return res;
        }
    }

    @isTest
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        insert accountRecord;
        
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
        insert contactRecord;
        
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
        con.AccountId  = accountRecord.Id;
        insert con; 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://kooziegroup--full.my.salesforce.com/services/apexrest/CreateContacts';
        request.httpMethod = 'POST';
        String requestBody = ContactUtill.contactRequest(con.Id, 'Contact', 'DML').getAsString();
		request.requestBody = Blob.valueof(requestBody.replace('sf_Id', 'sfId')); 
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
            CreateContacts.getContactRequest(); 
        Test.stopTest();
    }

    @isTest
    public static void testScenario2(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = '243434';
        insert accountRecord;

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
        con.Email = 'test@testers.com.full';
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
        con.AccountId  = accountRecord.Id;
        insert con;



        Test.setMock(HttpCalloutMock.class, new RestMock2());
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://kooziegroup--full.my.salesforce.com/services/apexrest/CreateContacts';
        request.httpMethod = 'POST';
        String requestBody = ContactUtill.contactRequest('', 'Contact', 'DML').getAsString();
		request.requestBody = Blob.valueof(requestBody.replace('sf_Id', '')); 
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
            CreateContacts.getContactRequest(); 
        Test.stopTest();
    }
    
}