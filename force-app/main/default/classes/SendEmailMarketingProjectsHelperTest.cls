@isTest
public class SendEmailMarketingProjectsHelperTest {
    @testSetup
    static void setup() {
        Marketing_Projects__c mp = new Marketing_Projects__c();
        mp.Marketing_Project_Name__c = 'Test Marketing Project';
        mp.Submitter_Email__c = 'test.email@example.com';
        insert mp;
        
    }
    
    @isTest
    static void testSendEmail() {
        List<Marketing_Projects__c> marketingProjectsList = [SELECT Id, Submitter_Email__c, Name, Marketing_Project_Name__c FROM Marketing_Projects__c WHERE Submitter_Email__c = 'test.email@example.com' LIMIT 1];
        
        Test.startTest();     
        SendEmailMarketingProjectsHelper.sendEmail(marketingProjectsList); 
        Test.stopTest();
        
        
    }
}