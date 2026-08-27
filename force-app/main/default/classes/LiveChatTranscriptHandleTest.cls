/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author                Modification
 * 1.0   07-06-2023   Mohammad Arafat Ali   Initial Version
**/
@isTest
public class LiveChatTranscriptHandleTest {
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
    public static void testUpdateCaseOwner() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Profile p = [Select Id from Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'Test', email='standardus123123er@testorg.com',EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
                timezonesidkey='america/los_angeles',username='standardus123123er@testorg.com');
        insert u;        
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '828312';
        insert acc;
        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        con.FirstName = 'Test First Name';
        con.Email = 'test@test.com.full';
        con.AccountId  = acc.Id;
        insert con;
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.AccountId = acc.Id;
        css.ContactId = con.Id;
        insert css;
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        List<LiveChatTranscript> liveChatList = new List<LiveChatTranscript>();
        LiveChatTranscript chat1 = new LiveChatTranscript();
        chat1.CaseId = css.Id;
        chat1.OwnerId = u.Id;
        chat1.LiveChatVisitorId = lcv.id;
        chat1.Status = 'InProgress';
        liveChatList.add(chat1);
        insert chat1;
        ConversationContextEntry cen = new ConversationContextEntry();
        cen.ParentId = chat1.Id;
        cen.CustomDetailContextKey = 'Email';
        cen.CustomDetailContextValue = 'test@test.com.full';
        insert cen; 
        Test.startTest();
            LiveChatTranscriptHandel.UpdateCaseOwner(liveChatList);
        Test.stopTest();
    }
}