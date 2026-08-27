/**
    * @description       : 
    * @author            : ritesh.kumar@kooziegroup.com
    * @group             : 
    * @last modified on  : 11-29-2024
    * @last modified by  : ritesh.kumar@kooziegroup.com
**/
@IsTest
public class UpdateContactStatusTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    public static void makeData(){
        
        TestDataFactory.loadAppSetting(); 
        Account accountRecord = TestDataFactory.createAccount('Test Domain', '12345025', 'Customers', FALSE);
        accountRecord.Account_Domain__c = 'testdomain.com.full';
        Insert accountRecord;
        
        Contact contactRecord1 = TestDataFactory.createContact('Test', 'Contact',accountRecord.Id , 'CRM Contact', FALSE);
        contactRecord1.Contact_Status__c = 'Active';
        contactRecord1.email = 'test@test1.com.full';
        Insert contactRecord1;

        Contact contactRecord2 = TestDataFactory.createContact('Test', 'Contact',accountRecord.Id , 'CRM Contact', FALSE);
        contactRecord2.Contact_Status__c = 'Active';
        contactRecord2.email = 'test@test2.com.full';
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Insert contactRecord2;
        
        accountRecord.Status__c = 'Inactive';
        Update accountRecord;
        
    }
    
}