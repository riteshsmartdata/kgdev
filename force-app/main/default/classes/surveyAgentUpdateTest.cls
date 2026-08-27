@istest
public class surveyAgentUpdateTest {
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        List<Account> lstAccInsert = new List<Account>();
        AppInfo__c appinfo = new AppInfo__c();
        appinfo.Name = 'WebClient';
        appinfo.user__c='test User';
        appinfo.password__c='12345';
        appinfo.endpoint__c='www.test.com';
        Account acc  = TestData.createAccount(false);
        acc.Name = 'Test';
        acc.Phone = '4194181444';
        lstAccInsert.add(acc);
        Account acc1 = TestData.createAccount(false);
        acc1.Name = 'Test';
        acc1.Phone = '8708006525';
        lstAccInsert.add(acc1);
        insert lstAccInsert;
    }
    @isTest
    private static void surveyUpdateContactTest1() {
        Test.setMock(HttpCalloutMock.Class, new MockHTTPResponseGenerator());
        Account lstAcc = [SELECT Id,Phone FROM Account WHERE Phone = '4194181444' LIMIT 1];
        Contact contact = TestData.createContact(false, lstAcc.Id);
        contact.lastname='Johnson'; 
        contact.email='jj@jj.com';
        contact.Other_Email__c = 'j@j.com';
        contact.phone = lstAcc.Phone;  
        contact.otherPhone = '407-444-1212';
        contact.FAX = '407-777-4848';
        insert contact;
        User testUser = [SELECT Id,Agent_ID__c,Name, isActive FROM User Where Agent_ID__c!=null AND isActive = true LIMIT 1];
        Test.StartTest();
        Custom_Survey__c survey = new Custom_Survey__c();
        survey.ANI__c = lstAcc.Phone;
        survey.Agent_ID__c = testUser.Agent_ID__c;
        insert Survey;
        Test.StopTest();
    }
    @isTest
    private static void surveyUpdateContactTest2() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        List<Custom_Survey__c> lstCustomSurvey = new List<Custom_Survey__c>();
        Account lstAcc = [SELECT Id,Phone FROM Account WHERE Phone = '8708006525' LIMIT 1];
        User testUser = [SELECT Id,Agent_ID__c,Name, isActive FROM User Where Agent_ID__c!=null AND isActive = true LIMIT 1];
        User testUser2 = [SELECT Id,Agent_ID__c,Name, isActive FROM User Where Agent_ID__c!=null AND isActive = false LIMIT 1];
        Test.StartTest();
        Custom_Survey__c survey = new Custom_Survey__c();
        survey.ANI__c = lstAcc.Phone;
        survey.Agent_ID__c = testUser.Agent_ID__c;
        lstCustomSurvey.add(survey);
        Custom_Survey__c survey1 = new Custom_Survey__c();
        survey1.ANI__c = lstAcc.Phone;
        survey1.Agent_ID__c = testUser2.Agent_ID__c;
        lstCustomSurvey.add(survey1);
        insert lstCustomSurvey;
        Test.StopTest();
    }
}