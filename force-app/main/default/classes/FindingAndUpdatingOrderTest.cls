/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Kumar Saurav
 * JIRA TICKET        : SF-478
**/
@isTest
public class FindingAndUpdatingOrderTest {
  private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setStatusCode(200);
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
        con.AccountId  = accountRecord.Id;
        insert con; 
        
        EBS_Order__c order = new EBS_Order__c();
        order.Account_Name__c = accountRecord.Id;
        order.Acc_PO_Contact_To_Email__c = 'test123@testing.com';
        order.Acc_Order_Confirm_Contact_To_Email__c = 'test123@testing.com';
        order.Acc_Shipping_Notif_Contact_To_Email__c = 'test123@testing.com';
        order.Additional_Emails__c = 'test123@testing.com';
        order.Customer_Account_Number__c = '12345678';
        order.EBS_Order_Number__c = '123';
        insert order;
        
         
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://kooziegroup--full.my.salesforce.com/services/apexrest/CreateContacts';
        request.httpMethod = 'POST';
        //String requestBody = OrderJSONGenerator.orderJSON(order.Id).getAsString();
		//request.requestBody = Blob.valueof(requestBody.replace('sf_Id', 'sfId')); 
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        FindingOrderFromCustAccAndOrderNum.findOrder(order.Customer_Account_Number__c,order.EBS_Order_Number__c); 
       OrderJSONGenerator.orderJSON(order);
        updateEBSOrderAddtnEmail.updateOrder(order.Id,order.Additional_Emails__c);
        Test.stopTest();
        
    } 
}