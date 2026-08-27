/** 
*  @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 10-18-2022
* @last modified by  : Ritesh Kumar
**/
@isTest
public class ContactCallOutHandlerTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"sagar.hadkar@gmail.com","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","CustomerData":{"SFId":"0035300000AfrYEAAZ","WebId":"633c038706681158863d1cd7","Email":"sagar.hadkar@gmail.com"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void contactCallOutHandler_UnitTest(){
        
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
        insert con;
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        Set<String> fieldsSet = new Set<String>();
        fieldsSet.add('Name');
        fieldsSet.add('EMAIL');
        
        Test.startTest();  
        ContactCallOutHandler.contactCallOutSync(JSON.serialize(con), 'INSERT', JSON.serialize(fieldsSet),'');
        ContactCallOutHandler.contactCallOutSync(JSON.serialize(con), 'Update', JSON.serialize(fieldsSet),'Yes');
        ContactCallOutHandler.contactCallOutSync(JSON.serialize(con), 'DML','','No');
        
        Test.stopTest();
        
    }
    
}