/**
* @description       : 
* @author            : ritesh.kumar@kooziegroup.com
* @group             : 
* @last modified on  : 10-01-2024
* @last modified by  : ritesh.kumar@kooziegroup.com
**/
@IsTest
public class OrderMessagingTest {
    
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
        Account accountRecord = TestDataFactory.createAccount('Test Account', '1234501', 'Customers', TRUE); 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact contactRecord = TestDataFactory.createContact('Test', 'Contact',accountRecord.Id , 'CRM Contact', FALSE);
        contactRecord.Contact_Status__c = 'Inactive';
        contactRecord.email = 'test@test1.com.full';
        contactRecord.MobilePhone = '+917042010115';
        Insert contactRecord;
        
        EBS_Order__c order = new EBS_Order__c();
        order.Account_Name__c = accountRecord.Id;
        order.PO_Contact__c = contactRecord.Id;
        order.PO_Contact_Email__c = 'test@test1.com.full'; 
        order.Customer_Account_Number__c = '1234501'; 
        order.Order_Type__c = 'Standard';
        order.Customer_PO__c = 'PK11001436L';
        order.EBS_Order_Number__c = '279033736';
        insert order;
        
        Test.startTest();  
        OrderMessaging.getMessagingSessionId(order.Id);
        OrderMessaging.getRecentMessagingSession(order.Id);
        Test.stopTest();
    }
    
}