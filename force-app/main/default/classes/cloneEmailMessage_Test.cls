@isTest
public class cloneEmailMessage_Test {
    @isTest
    public static void EmailTestClarification() {
        
        test.startTest();
        SwitchTrigger__c cs = new SwitchTrigger__c();
        cs.Name='EmailLinkTrigger';
        cs.Deactivate__c = false;
        //cs.Other fiels values
        insert cs;
        Case css = new Case();
        css.RecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'Closed';
        css.Origin = 'ASI Rating';
        insert css;
        EmailMessage  em = new EmailMessage () ;
        em.ParentID  = css.id;
        insert em;
        Email_Link__c el = new Email_Link__c() ;
        el.Case__c  = css.id;
        insert el;
        List<id> emailCaseIds = new list<id>();
        emailCaseIds.add(css.id);
        cloneEmailMessage.EmailMessageClone(emailCaseIds);
        test.stopTest();
    }
}