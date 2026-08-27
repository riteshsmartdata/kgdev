/**
 * @description       : 
 * @author            : Mohammad Arfat Ali
 * @group             : 
 * @last modified on  : 07-27-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   07-26-2023   Mohammad Arafat Ali   Initial Version
**/

@isTest
public without sharing class Scout_GetTranscriptVariables_Test {
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
public static void getTranscriptVariable() {

    Profile p = [Select Id from Profile WHERE Name='System Administrator'];
    User u = new User(Alias = 'Test', email='standardus123123er@testorg.com',EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,
            timezonesidkey='america/los_angeles',username='standardus123123er@testorg.com');

    insert u;        

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


    List<LiveChatTranscript> liveChatList = new List<LiveChatTranscript>();
    LiveChatTranscript chat1 = new LiveChatTranscript();
    chat1.CaseId = css.Id;
    chat1.OwnerId = u.Id;
    chat1.LiveChatVisitorId = lcv.id;
    chat1.Status = 'InProgress';
    insert chat1;

    Scout_GetTranscriptVariables.TranscriptInput tsi = new Scout_GetTranscriptVariables.TranscriptInput();
    tsi.routableID = chat1.Id;

    // Call the method to be tested
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.startTest();
    Scout_GetTranscriptVariables.getUserName(new List<Scout_GetTranscriptVariables.TranscriptInput>{tsi});
    Test.stopTest();
    } 
}