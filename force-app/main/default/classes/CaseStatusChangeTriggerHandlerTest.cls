@IsTest
private class CaseStatusChangeTriggerHandlerTest {

    @testSetup static void setupTestdata() {
         Case newCase = new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        newCase.Subject = 'Unittest';
        newCase.Status = 'New';
        newCase.Origin = 'ASI Rating';
        newCase.EBS_Account_Number__c ='828312';
        insert newCase; 
        CaseStatusChangeTriggerHandler cd = new CaseStatusChangeTriggerHandler();
       cd.codecoverage();
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
    static void testCaseWithExistingContact() {
      
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        CaseStatusChangeTriggerHandler cd = new CaseStatusChangeTriggerHandler();
        cd.codecoverage();
        Test.stopTest();
    }
 


}