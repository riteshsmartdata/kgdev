@isTest
public class EmailMessageCleanupBatchTest {
    @TestSetup
    static void makeData(){
        SwitchTrigger__c cs = new SwitchTrigger__c();
        cs.Name='EmailLinkTrigger';
        cs.Deactivate__c = false;
        insert cs;
    }
    @isTest
    private static void testScheduler(){
        Test.startTest();
            System.schedule('Test status Check', '0 0 23 * * ?', new EmailMessageCleanupBatchScheduler());
        Test.stopTest();
    } 
    @isTest 
    public static void testEmailMessageCleanupBatch() {
        
        EBS_Order__c ebsOrderRecord = TestData.createEBSOrder(false);
        ebsOrderRecord.Order_Header_Status__c = 'Closed';
        ebsOrderRecord.CreatedDate = Date.today().addDays(-70);
        ebsOrderRecord.LastModifiedDate = Date.today().addDays(-70);
        insert ebsOrderRecord;
        System.debug('::::: '+ebsOrderRecord);
        List<EmailMessage> emList = new List<EmailMessage>();
        Date dateCreated = Date.today();
        EmailMessage em = new EmailMessage();
        em.Subject = 'Test Email ';
        em.TextBody = 'Test Email Body ';
        em.ToAddress = 'test@test.com';
        em.CreatedDate = dateCreated;
        em.BccAddress = 'testbccddress@gmail.com';
        em.Case_ThreadID_FK__c = 'Test Thread ID';
        em.CcAddress = 'testccaddress@gmail.com';
        em.EBS_Account_ID__c = 'Test EBS Account';
        em.EBS_Contact_ID__c = 'Test EBS Contact';
        em.FromAddress = 'customerservice@kooziegroup.com';
        em.FromName = 'Test Name';
        em.HtmlBody = 'Test HTML Body';
        em.Headers = 'Test Header';
        em.IsExternallyVisible = True;
        em.Incoming = True;
        em.IsPrivateDraft = True;
        em.Message_ID__c = 'Test Message';
        em.RelatedToId = ebsOrderRecord.Id;
        emList.add(em);
        insert emList;
        System.debug(':::::::: '+emList);
        Test.startTest();
            Database.executeBatch(new EmailMessageCleanupBatch());
        Test.stopTest();
    }
}