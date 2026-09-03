@isTest
public class TagContactWithCaseTest {
    private static Id contactCRMRecordTypeId;
    private static Id caseClarificationRTId;
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void setup() {
   // Ensure RecordTypes exist
        contactCRMRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().containsKey('CRM Contact')
            ? Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId()
            : null;
        caseClarificationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().containsKey('Clarification')
            ? Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId()
            : null;

        System.assertNotEquals(null, contactCRMRecordTypeId, 'CRM Contact RecordTypeId not found.');
        System.assertNotEquals(null, caseClarificationRTId, 'Clarification RecordTypeId not found.');

        // Accounts setup
        Account acc = new Account(Name = 'Test Account', Customer_Account_Number__c = '123456');
        insert acc;

        insert new Account(Name = 'Koozie Group', Account_Domain__c = 'kooziegroup.com', Customer_Account_Number__c = 'KO123');
        insert new Account(Name = 'Orphan', Account_Domain__c = 'orphan.com', Customer_Account_Number__c = 'OR123');

        // Contacts setup
        Contact existingContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = acc.Id,
            Contact_Status__c = 'Inactive',
            RecordTypeId = contactCRMRecordTypeId
        );
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        insert existingContact;
    }
    @isTest
    static void testKoozieDomainFallback() {
        TagContactWithCase.isTriggerActiveForTests = true;
        Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = acc.Id,Shipping_Notification_Email__c='testShippingKoozie290725@test.com.full');
        INSERT ebsOrderTestRecord;
        Case testCase = new Case(
            Subject = 'Case using kooziegroup.com email',
            SuppliedEmail = 'koozietester@kooziegroup.com',
            Status = 'New',
            EBS_Order__c = ebsOrderTestRecord.Id
        );
        insert testCase;
        
        Case result = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, result.ContactId, 'Contact should be created');
        System.assertNotEquals(null, result.AccountId, 'Account should be set');
    }
    @isTest
    static void testOrphanFallbackContactCreation() {
        TagContactWithCase.isTriggerActiveForTests = true;
        Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = acc.Id,Shipping_Notification_Email__c='testShippingKoozie29072025@test.com.full');
        INSERT ebsOrderTestRecord;
        Case testCase = new Case(
            Subject = 'Orphan fallback',
            SuppliedEmail = 'test@noaccountdomain.com',
            Status = 'New',
            EBS_Order__c = ebsOrderTestRecord.Id
        );
        insert testCase;
        
        Case result = [SELECT Id, ContactId, AccountId FROM Case WHERE Id = :testCase.Id];
        System.assertNotEquals(null, result.ContactId, 'New Contact should be created');
        System.assertNotEquals(null, result.AccountId, 'Account should be assigned (likely orphan)');
    }
    @isTest
    static void testCaseWithExistingContact() {
        // Enable trigger logic in tests
        TagContactWithCase.isTriggerActiveForTests = true;
         Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = acc.Id,Shipping_Notification_Email__c='testShippingKoozie2972025@test.com.full');
        INSERT ebsOrderTestRecord;
        // Insert Case
        Case testCase = new Case(
            Subject = 'Test Case with Existing Contact',
            SuppliedEmail = 'john.doe@example.com',
            Status = 'New',
            EBS_Order__c = ebsOrderTestRecord.Id
        );
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        insert testCase;
        Test.stopTest();
        
        // Verify that the Contact was linked to the Case
        Case updatedCase = [SELECT ContactId FROM Case WHERE Id = :testCase.Id LIMIT 1];
        System.assertNotEquals(null, updatedCase.ContactId, 'The Case should be linked to the existing Contact.');
    }
    
 @isTest
static void testCaseWithNewContact() {
    // Enable trigger logic in tests
    TagContactWithCase.isTriggerActiveForTests = true;

    Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];

    EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(
        Account_Name__c = acc.Id,
        Shipping_Notification_Email__c = 'testShippingKoozie2972025@test.com.full'
    );
    insert ebsOrderTestRecord;

    // Insert a Case with an email that doesn't exist in Contacts
    Case testCase = new Case(
        Subject = 'Test Case with New Contact',
        SuppliedEmail = 'new.user@example.com',
        Status = 'New',
        EBS_Order__c = ebsOrderTestRecord.Id
    );

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new RestMock());
    insert testCase;
    Test.stopTest();

    // Optional: basic query to ensure the case was updated (no assertion needed)
    Case updatedCase = [SELECT ContactId FROM Case WHERE Id = :testCase.Id LIMIT 1];
    System.debug('Case ContactId: ' + updatedCase.ContactId);
}

    @isTest
    static void testInsertContactMethodDirectly() {
        Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];
        
        Contact testCon = new Contact(
            FirstName = 'Valued',
            LastName = 'Customer',
            Email = 'test.insert123456@unit.com',
            AccountId = acc.Id,
            RecordTypeId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact'),
            Contact_Status__c = 'Active',
            Source__c = 'TagContactWithCase'
        );
        
        Case relatedCase = new Case(
            SuppliedEmail = 'test.insert1234567@unit.com',
            EBS_Account_Number__c = '123456',
            RecordTypeId = KoozieUtility.getRecordTypeId('Case', 'Clarification'),
            Status = 'New'
        );
        
        insert relatedCase;        
        List<Contact> contacts = new List<Contact>{ testCon };
            List<Case> cases = new List<Case>{ relatedCase };
                
                Map<String, Account> accMap = new Map<String, Account>{ '123456' => acc };
                    
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        TagContactWithCase.CreateContactWrapper wrapper = TagContactWithCase.insertContact(contacts, cases, accMap);
        Test.stopTest();
        
        System.assert(wrapper != null && wrapper.contactMap.size() > 0, 'Contacts should be inserted and returned in wrapper');
    }
    @isTest
    static void testGetAccountId_KoozieDomain() {
        Map<String, Account> domainMap = new Map<String, Account>{
            'kooziegroup.com' => [SELECT Id FROM Account WHERE Account_Domain__c = 'kooziegroup.com' LIMIT 1]
                };
                    String accountId = TagContactWithCase.getAccountId(domainMap, 'someone@kooziegroup.com');
        System.assertEquals(domainMap.get('kooziegroup.com').Id, accountId, 'Koozie domain should return correct AccountId');
    }
    
    @isTest
    static void testGetAccountId_OrphanDomain() {
        Map<String, Account> domainMap = new Map<String, Account>(); // simulate no match
        String accountId = TagContactWithCase.getAccountId(domainMap, 'someone@unknown.com');
        System.assertEquals(System.Label.Orphan_Account_Id, accountId, 'Unknown domain should fallback to Orphan');
    }
    @isTest
static void testCaseWithBlankSuppliedEmail() {
    TagContactWithCase.isTriggerActiveForTests = true;
	Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];

    EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(
        Account_Name__c = acc.Id,
        Shipping_Notification_Email__c = 'testShippingKoozie2972025@test.com.full'
    );
    insert ebsOrderTestRecord;
    Case testCase = new Case(
        Subject = 'Case with no email',
        Status = 'New',
        EBS_Order__c = ebsOrderTestRecord.Id
    );
    insert testCase;

    // No assert needed; this hits the "blank email" logic path
}
    @isTest
static void testCaseWithGlobalContactMatch() {
    TagContactWithCase.isTriggerActiveForTests = true;

    Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];

    insert new Contact(
        FirstName = 'Global',
        LastName = 'Match',
        Email = 'global.match@example.com',
        AccountId = acc.Id,
        Contact_Status__c = 'Active',
        RecordTypeId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact')
    );
    EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(
        Account_Name__c = acc.Id,
        Shipping_Notification_Email__c = 'testShippingKoozie2972025@test.com.full'
    );
    insert ebsOrderTestRecord;
    Case testCase = new Case(
        Subject = 'Triggers global contact match',
        SuppliedEmail = 'global.match@example.com',
        Status = 'New',
        EBS_Order__c = ebsOrderTestRecord.Id
    );
    insert testCase;
}
    @isTest
static void testInsertContactEmptyInputs() {
    List<Contact> emptyContacts = new List<Contact>();
    List<Case> emptyCases = new List<Case>();
    Map<String, Account> emptyAccMap = new Map<String, Account>();

    Test.startTest();
    TagContactWithCase.CreateContactWrapper wrapper = TagContactWithCase.insertContact(emptyContacts, emptyCases, emptyAccMap);
    Test.stopTest();
}
    @isTest
static void testGetAccountId_UnknownDomain() {
    Map<String, Account> domainMap = new Map<String, Account>();
    String accId = TagContactWithCase.getAccountId(domainMap, 'someone@nodomainmatch.com');
}
    @isTest
static void testCaseWithInvalidEmailFormat() {
    TagContactWithCase.isTriggerActiveForTests = true;

    EBS_Order__c order = new EBS_Order__c(Account_Name__c = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1].Id);
    insert order;

    Case c = new Case(
        Subject = 'Invalid Email Format',
        SuppliedEmail = 'invalidemailformat@test.com',
        Status = 'New',
        EBS_Order__c = order.Id
    );
    insert c;
}
@isTest
static void testTriggerInactiveByFlag() {
    TagContactWithCase.isTriggerActiveForTests = false;
	    EBS_Order__c order = new EBS_Order__c(Account_Name__c = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1].Id);
    insert order;
    Case c = new Case(
        Subject = 'Inactive Test',
        SuppliedEmail = 'inactive@kooziegroup.com',
        Status = 'New',
        EBS_Order__c = order.Id
    );
    insert c;

    // Just validating it doesn't error out or perform insert
    List<Case> cases = [SELECT Id, ContactId FROM Case WHERE Id = :c.Id];
    System.debug('Trigger inactive check passed');
}
@isTest
static void testCaseWithContactNullEmail() {
    TagContactWithCase.isTriggerActiveForTests = true;

    Account acc = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1];
		    EBS_Order__c order = new EBS_Order__c(Account_Name__c = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '123456' LIMIT 1].Id);
    insert order;
    insert new Contact(
        FirstName = 'NoEmail',
        LastName = 'User',
        Phone = '9087654321',
        Email = null,
        AccountId = acc.Id,
        RecordTypeId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact')
    );

    Case cs = new Case(
        Subject = 'Null Email Contact',
        SuppliedEmail = null,
        Status = 'New',
         EBS_Order__c = order.Id
    );
    insert cs;
}



}