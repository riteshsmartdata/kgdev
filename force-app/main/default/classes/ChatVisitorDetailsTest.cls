/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public class ChatVisitorDetailsTest {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void testGetConversationContextEntry() {
        // Create test data

        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '828312';
        Insert acc;

        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        con.FirstName = 'Test First Name';
        con.Email = 'test@test.com';
        con.AccountId  = acc.Id;
        Insert con;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.AccountId = acc.Id;
        css.ContactId = con.Id;
        insert css;

        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.AccountID = acc.id;
        lct.CaseId = css.Id;
        lct.LiveChatVisitorId = lcv.Id;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        ChatVisitorDetails.getConversationContextEntry(string.ValueOf(lct.Id));
        Test.stopTest();
    }
}