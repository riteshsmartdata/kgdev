/*
* @description       : Test Class for emailMessageTriggerHandler
* @author            :  
* @group             : 
* @last modified on  : 29-05-2026
* @last modified by  : Agentforce
*/
@isTest
public class emailMessageTriggerHandler_TestClass {
    
    @testSetup
    public static void caseData() {
        // Create SwitchTrigger custom setting
        SwitchTrigger__c switchTrigger = new SwitchTrigger__c(
            Name = 'EmailLinkTrigger',
            Deactivate__c = false
        );
        insert switchTrigger;
        
        // Create test cases with different record types and statuses
        List<Case> listInsertCase = new List<Case>();
        
        // Clarification record type - Merged status
        Case cs = new Case(
            Subject = 'Parent Test Case',
            Status = 'Merged',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId()
        );
        listInsertCase.add(cs);
        
        // Case record type - Merged status
        Case testcs = new Case(
            Subject = 'Test Case Scenario',
            Status = 'Merged',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId()
        );
        listInsertCase.add(testcs);
        
        // Case record type - New status
        Case testcs1 = new Case(
            Subject = 'Test Case Scenario 2',
            Status = 'New',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId()
        );
        listInsertCase.add(testcs1);
        
        // Clarification record type - New status
        Case testcs2 = new Case(
            Subject = 'Test Case Scenario 3',
            Status = 'New',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId()
        );
        listInsertCase.add(testcs2);
        
        // Case record type - Closed status for reopen testing
        Case testcs3 = new Case(
            Subject = 'Test Case Scenario 4',
            Status = 'New',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId()
        );
        listInsertCase.add(testcs3);
        
        insert listInsertCase;
    }
    
    // Test emailLinkCaseAssignment - Clarification case with status 3
    @isTest
    private static void testEmailMessageTriggerHandler1() {
        List<Case> parentCaseList = [
            SELECT Id, CaseNumber, Merged_Parent_Case__c, Status
            FROM Case
            WHERE Subject = 'Parent Test Case'
            LIMIT 1
        ];
        parentCaseList.get(0).Status = 'Merged';
        parentCaseList.get(0).Merged_Parent_Case__c = parentCaseList.get(0).CaseNumber;
        UPDATE parentCaseList;

        Test.startTest();
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '3';
        emailMessage1.fromName = 'Test Name';
        emailMessage1.subject = 'This is the Subject!';
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>';
        emailMessage1.ParentId = parentCaseList.get(0).id;
        emailMessage1.CreatedDate = System.now();
        insert emailMessage1;
        Test.stopTest();
    }
    
    // Test emailLinkCaseAssignment - Case record type with Closed status
    @isTest
    private static void testEmailMessageTriggerHandler2() {
        List<Case> parentCaseList = [
            SELECT Id, CaseNumber, Merged_Parent_Case__c, Status
            FROM Case
            WHERE Subject = 'Test Case Scenario'
            LIMIT 1
        ];
        parentCaseList.get(0).Status = 'Closed';
        parentCaseList.get(0).Merged_Parent_Case__c = parentCaseList.get(0).CaseNumber;
        parentCaseList.get(0).Case_Reason_Type__c = 'Chat';
        parentCaseList.get(0).Reason_Closed__c = 'Closing for Test Class';
        update parentCaseList;
        
        Test.startTest();
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '2';
        emailMessage1.fromName = 'Test Name';
        emailMessage1.subject = 'This is the Subject!';
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>';
        emailMessage1.ParentId = parentCaseList.get(0).id;
        emailMessage1.CreatedDate = System.now();
        insert emailMessage1;
        Test.stopTest();
    }
    
    // Test emailLinkCaseAssignment - Case with New status
    @isTest
    private static void testEmailMessageTriggerHandler3() {
        List<Case> parentCaseList = [
            SELECT Id, CaseNumber, Merged_Parent_Case__c, Status
            FROM Case
            WHERE Subject = 'Test Case Scenario 2'
            LIMIT 1
        ];
        parentCaseList.get(0).Merged_Parent_Case__c = parentCaseList.get(0).CaseNumber;
        update parentCaseList;
        
        Test.startTest();
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '4';
        emailMessage1.fromName = 'Test Name';
        emailMessage1.subject = 'This is the Subject!';
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>';
        emailMessage1.ParentId = parentCaseList.get(0).id;
        emailMessage1.CreatedDate = System.now();
        insert emailMessage1;
        Test.stopTest();
    }
    
    // Test emailLinkCaseAssignment - Clarification case with New status
    @isTest
    private static void testEmailMessageTriggerHandler4() {
        List<Case> parentCaseList = [
            SELECT Id, CaseNumber, Merged_Parent_Case__c, Status
            FROM Case
            WHERE Subject = 'Test Case Scenario 3'
            LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage emailMessage1 = new EmailMessage();
        emailMessage1.status = '4';
        emailMessage1.fromName = 'Test Name';
        emailMessage1.subject = 'This is the Subject!';
        emailMessage1.htmlBody = '<html><body><b>Hello</b></body></html>';
        emailMessage1.ParentId = parentCaseList.get(0).id;
        emailMessage1.CreatedDate = System.now();
        insert emailMessage1;
        Test.stopTest();
    }
    
    // Test Koozie Inbound Email Classification
    @isTest
    private static void testKoozieInboundEmailClassification() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage inboundEmail = new EmailMessage();
        inboundEmail.ParentId = caseList.get(0).Id;
        inboundEmail.status = '3';
        inboundEmail.Incoming = true;
        inboundEmail.FromAddress = 'external@example.com';
        inboundEmail.ToAddress = 'info@kooziegroup.com';
        inboundEmail.subject = 'Inbound Email Test';
        inboundEmail.htmlBody = 'This is an inbound email';
        insert inboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :inboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
    
    // Test Koozie Outbound Email Classification
    @isTest
    private static void testKoozieOutboundEmailClassification() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage outboundEmail = new EmailMessage();
        outboundEmail.ParentId = caseList.get(0).Id;
        outboundEmail.status = '3';
        outboundEmail.Incoming = false;
        outboundEmail.FromAddress = 'sales@kooziegroup.com';
        outboundEmail.ToAddress = 'customer@example.com';
        outboundEmail.subject = 'Outbound Email Test';
        outboundEmail.htmlBody = 'This is an outbound email';
        insert outboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Outbound__c
            FROM EmailMessage
            WHERE Id = :outboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Outbound__c, 'Should be marked as Koozie Outbound');
    }
    
    // Test BIC Graphic Domain
    @isTest
    private static void testBicGraphicDomainInbound() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage inboundEmail = new EmailMessage();
        inboundEmail.ParentId = caseList.get(0).Id;
        inboundEmail.status = '3';
        inboundEmail.Incoming = true;
        inboundEmail.FromAddress = 'customer@example.com';
        inboundEmail.ToAddress = 'support@bicgraphic.com';
        inboundEmail.subject = 'BIC Graphic Inbound Test';
        inboundEmail.htmlBody = 'Email to BIC Graphic';
        insert inboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :inboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
    
    // Test Calendar CS Email
    @isTest
    private static void testCalendarCSEmail() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage inboundEmail = new EmailMessage();
        inboundEmail.ParentId = caseList.get(0).Id;
        inboundEmail.status = '3';
        inboundEmail.Incoming = true;
        inboundEmail.FromAddress = 'external@example.com';
        inboundEmail.ToAddress = 'csinfo@calendarcs.com';
        inboundEmail.subject = 'Calendar CS Email Test';
        inboundEmail.htmlBody = 'Email to Calendar CS';
        insert inboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :inboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
    
    // Test Internal to Internal Email (should not be classified)
    @isTest
    private static void testInternalToInternalEmail() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage internalEmail = new EmailMessage();
        internalEmail.ParentId = caseList.get(0).Id;
        internalEmail.status = '3';
        internalEmail.Incoming = true;
        internalEmail.FromAddress = 'employee1@kooziegroup.com';
        internalEmail.ToAddress = 'employee2@kooziegroup.com';
        internalEmail.subject = 'Internal Email Test';
        internalEmail.htmlBody = 'Internal communication';
        insert internalEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c, Koozie_Outbound__c
            FROM EmailMessage
            WHERE Id = :internalEmail.Id
        ];
        System.assertNotEquals(true, insertedEmail.Koozie_Inbound__c, 'Should not be marked as inbound');
        System.assertNotEquals(true, insertedEmail.Koozie_Outbound__c, 'Should not be marked as outbound');
    }
    
    // Test Email with Multiple Recipients (semicolon separated)
    @isTest
    private static void testMultipleRecipientsWithSemicolon() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage inboundEmail = new EmailMessage();
        inboundEmail.ParentId = caseList.get(0).Id;
        inboundEmail.status = '3';
        inboundEmail.Incoming = true;
        inboundEmail.FromAddress = 'customer@example.com';
        inboundEmail.ToAddress = 'info@kooziegroup.com;support@example.com';
        inboundEmail.subject = 'Multiple Recipients Test';
        inboundEmail.htmlBody = 'Email with multiple recipients';
        insert inboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :inboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
    
    // Test Email with Display Name Format
    @isTest
    private static void testEmailWithDisplayName() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage inboundEmail = new EmailMessage();
        inboundEmail.ParentId = caseList.get(0).Id;
        inboundEmail.status = '3';
        inboundEmail.Incoming = true;
        inboundEmail.FromAddress = 'customer@example.com';
        inboundEmail.ToAddress = 'support@kooziegroup.com';
        inboundEmail.subject = 'Display Name Format Test';
        inboundEmail.htmlBody = 'Email with display names';
        insert inboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :inboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
    
    // Test Outbound Email with Non-Internal Recipient
    @isTest
    private static void testOutboundEmailNonInternal() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage outboundEmail = new EmailMessage();
        outboundEmail.ParentId = caseList.get(0).Id;
        outboundEmail.status = '3';
        outboundEmail.Incoming = false;
        outboundEmail.FromAddress = 'sales@bicgraphic.com';
        outboundEmail.ToAddress = 'customer@example.com';
        outboundEmail.subject = 'Outbound Non-Internal Test';
        outboundEmail.htmlBody = 'Outbound email to customer';
        insert outboundEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Outbound__c
            FROM EmailMessage
            WHERE Id = :outboundEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Outbound__c, 'Should be marked as Koozie Outbound');
    }
    
    // Test Email Without ParentId
    @isTest
    private static void testEmailWithoutParentId() {
        Test.startTest();
        EmailMessage emailNoParent = new EmailMessage();
        emailNoParent.status = '3';
        emailNoParent.Incoming = true;
        emailNoParent.FromAddress = 'customer@example.com';
        emailNoParent.ToAddress = 'info@kooziegroup.com';
        emailNoParent.subject = 'Email Without Parent Test';
        emailNoParent.htmlBody = 'Email without case parent';
        insert emailNoParent;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, ParentId
            FROM EmailMessage
            WHERE Id = :emailNoParent.Id
        ];
        System.assertEquals(null, insertedEmail.ParentId, 'Should not have parent');
    }
    
    // Test Email with Empty Address Fields
    @isTest
    private static void testEmailWithEmptyAddresses() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage emailEmpty = new EmailMessage();
        emailEmpty.ParentId = caseList.get(0).Id;
        emailEmpty.status = '3';
        emailEmpty.Incoming = true;
        emailEmpty.subject = 'Empty Address Test';
        emailEmpty.htmlBody = 'Email with empty addresses';
        insert emailEmpty;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c, Koozie_Outbound__c
            FROM EmailMessage
            WHERE Id = :emailEmpty.Id
        ];
        System.assertNotEquals(true, insertedEmail.Koozie_Inbound__c, 'Should not be marked as inbound');
    }
    
    // Test Email Already Marked as Koozie Inbound
    @isTest
    private static void testEmailAlreadyMarkedInbound() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage alreadyMarked = new EmailMessage();
        alreadyMarked.ParentId = caseList.get(0).Id;
        alreadyMarked.status = '3';
        alreadyMarked.Incoming = true;
        alreadyMarked.FromAddress = 'customer@example.com';
        alreadyMarked.ToAddress = 'info@kooziegroup.com';
        alreadyMarked.Koozie_Inbound__c = true;
        alreadyMarked.subject = 'Already Marked Test';
        alreadyMarked.htmlBody = 'Already marked as inbound';
        insert alreadyMarked;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :alreadyMarked.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should remain marked as Koozie Inbound');
    }
    
    // Test Bulk Email Insert
    @isTest
    private static void testBulkEmailInsert() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        List<EmailMessage> bulkEmails = new List<EmailMessage>();
        
        for (Integer i = 0; i < 10; i++) {
            EmailMessage em = new EmailMessage();
            em.ParentId = caseList.get(0).Id;
            em.status = '3';
            em.Incoming = (Math.mod(i, 2) == 0);
            em.FromAddress = (Math.mod(i, 2) == 0) ? 'customer' + i + '@example.com' : 'sales@kooziegroup.com';
            em.ToAddress = (Math.mod(i, 2) == 0) ? 'info@kooziegroup.com' : 'customer' + i + '@example.com';
            em.subject = 'Bulk Email Test ' + i;
            em.htmlBody = 'Bulk email content ' + i;
            bulkEmails.add(em);
        }
        
        Test.startTest();
        insert bulkEmails;
        Test.stopTest();
        
        List<EmailMessage> insertedEmails = [
            SELECT Id, Koozie_Inbound__c, Koozie_Outbound__c
            FROM EmailMessage
            WHERE Id IN :bulkEmails
        ];
        System.assertEquals(10, insertedEmails.size(), 'Should have 10 emails');
    }
    
    // Test emailLinkCaseAssignment with Status 5
    @isTest
    private static void testEmailLinkWithStatus5() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 3' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage emailMessage = new EmailMessage();
        emailMessage.status = '5';
        emailMessage.fromName = 'Test Name';
        emailMessage.subject = 'Status 5 Test';
        emailMessage.htmlBody = '<html><body>Status 5</body></html>';
        emailMessage.ParentId = caseList.get(0).id;
        insert emailMessage;
        Test.stopTest();
    }
    
    // Test Mixed Internal/External Recipients
    @isTest
    private static void testMixedRecipients() {
        List<Case> caseList = [
            SELECT Id FROM Case WHERE Subject = 'Test Case Scenario 4' LIMIT 1
        ];
        
        Test.startTest();
        EmailMessage mixedEmail = new EmailMessage();
        mixedEmail.ParentId = caseList.get(0).Id;
        mixedEmail.status = '3';
        mixedEmail.Incoming = true;
        mixedEmail.FromAddress = 'customer@example.com';
        mixedEmail.ToAddress = 'info@kooziegroup.com,external@example.com';
        mixedEmail.subject = 'Mixed Recipients Test';
        mixedEmail.htmlBody = 'Mixed internal and external recipients';
        insert mixedEmail;
        Test.stopTest();
        
        EmailMessage insertedEmail = [
            SELECT Id, Koozie_Inbound__c
            FROM EmailMessage
            WHERE Id = :mixedEmail.Id
        ];
        System.assertEquals(true, insertedEmail.Koozie_Inbound__c, 'Should be marked as Koozie Inbound');
    }
}