/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-09-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-08-2024   Ritesh Kumar   Initial Version
**/

@IsTest
public class CreateContactHistoryEmailTest {

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
    static void testSendEmail() {
        
        SwitchTrigger__c ST=  new SwitchTrigger__c();
        ST.Name = 'EmailLinkTrigger';
        Insert ST;

        Account accountRecord =  TestData.createAccount(FALSE);
        accountRecord.Customer_Account_Number__c = '159753215';
        Insert accountRecord;

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact contactRecord = TestData.createContact(FALSE,accountRecord.Id);
        contactRecord.email = 'FirstName@test.com.full';
        contactRecord.Order_Acknowledgement__c = 'Email';
        contactRecord.Shipment_Confirmation__c = 'Email';
        contactRecord.PO_Confirmation__c = 'Email';
        Insert contactRecord;

        Case caseRecord = TestData.createCase(FALSE, 'Clarification');
        caseRecord.SuppliedEmail = 'FirstName@test.com.full';
       	caseRecord.status = 'Status';
        Insert caseRecord;

        Test.startTest();
            EmailMessage mail = new EmailMessage();
            mail.RelatedToId = caseRecord.Id;
            mail.Subject = 'Test Mail';
            mail.TextBody ='from testing';
        	mail.Status = '3';
            mail.FromAddress = 'test@kooziegroup.com';
            mail.ToAddress = 'test@test.com';
            Insert mail;
            mail.Status = '3';
            Update mail;
        	ContactHistory__c [] contactHistory = [SELECT Id, Name,Type__c FROM ContactHistory__c WHERE Case__c =: caseRecord.Id AND Type__c = 'Email'];
        	EmailMessage []  EmailMessages =  [SELECT Id, Name FROM EmailMessage ];
        	System.debug('====== contactHistory ====='+ contactHistory);
        	System.debug('====== EmailMessages ====='+ EmailMessages);
        	//Assert.areEqual(EmailMessages.size(),contactHistory.size());
        	
        	//Update mail;
        Test.StopTest();
    }
    
}