/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 10-13-2022
* @last modified by  : Ritesh Kumar
**/
@isTest
public class GrandNodeContactSyncTest {
   
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"sagar.hadkar@gmail.com","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","CustomerData":{"SFId":"0035300000AfrYEAAZ","WebId":"633c038706681158863d1cd7","Email":"sagar.hadkar@gmail.com"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
     private class ErrorMoke implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"sagar.hadkar@gmail.com","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","CustomerData":{"SFId":"0035300000AfrYEAAZ","WebId":"633c038706681158863d1cd7","Email":"sagar.hadkar@gmail.com"}}}');
            res.setStatusCode(202);
            return res;
        }
    }
    
  
    
    @isTest
    public static void grandNodeContactSyncTest_UnitTestA(){
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
        contactRecord.FirstName = 'Test First Name';
        contactRecord.Email = 'test@test.com';
        contactRecord.MobilePhone = '8754122356';
        contactRecord.AccountId  = accountRecord.Id;
        contactRecord.Acc_PO_Contact__c = true;
        contactRecord.Acc_Order_Acknowledgement__c = true;
        contactRecord.Acc_Shipping_Contact__c = true;
        contactRecord.Acc_Proof_Confirmation__c = true;
        contactRecord.Acc_Clarification_Confirmation__c= true;
        Database.insert(new List<Contact> {contactRecord}, false) ;
        
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
        Test.startTest();  
        GrandNodeContactSync.contactSync(JSON.serialize(con), con.Id); 
        Test.stopTest();
        
    }
    
    
     @isTest
    public static void contactSync_UnitTest(){
        
        Test.setMock(HttpCalloutMock.class, new ErrorMoke());
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse(); 
        request.httpMethod = 'POST';
        response.statusCode = 202; 
        RestContext.request = request;
        RestContext.response = response;
       
        Test.startTest();
        GrandNodeContactSync.contactSync('Error : {Error:{ "data":"Testing error"}} ;; {"Error":"Error Test"} ;; 202', '003XXXXXX123');
        Test.stopTest();
        
    }
}