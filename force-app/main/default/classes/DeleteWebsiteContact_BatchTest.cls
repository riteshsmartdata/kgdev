/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-25-2023   Ritesh Kumar   Initial Version
**/
@isTest
public class DeleteWebsiteContact_BatchTest {
     
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
    public static void deleteRoleContactTest1(){
 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.Customer_Account_Number__c = 'test123';
        Database.Insert(accountRecord); 

        Contact record = new Contact();
        record.Phone = '9999999999';
        record.Responsibility_Type__c = 'CLARIFICATION';
        record.LastName = 'Graham';
        record.Email = 'test@testers.com';
        record.FirstName = 'Buller';
        record.Contact_Status__c = 'Active'; 
        record.AccountId  = accountRecord.Id; 
        Database.Insert(record); 

        Contact_Roles__c cr = new Contact_Roles__c(); 
        cr.Contact__c = record.Id;
        cr.Contact_Role_Name__c = 'PO CONTACT';
        cr.Contact__c = record.Id;
        cr.Account__c = accountRecord.Id;

        Insert cr;

        Test.startTest(); 
        Database.delete(record); 
        DeleteWebsiteContact_Batch dcbo = new DeleteWebsiteContact_Batch();
        database.executeBatch(dcbo,1);
        Test.stopTest();
        
    } 


    
}