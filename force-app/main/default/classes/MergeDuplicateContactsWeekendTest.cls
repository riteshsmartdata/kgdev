@IsTest
public class MergeDuplicateContactsWeekendTest {
    
    // Mock class for simulating successful HTTP callout
    private class IdentifySpecSampleEBSOrders_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testDuplicateContactMerge_success() {
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        // -------------------------------------------------
        // TEST SETUP
        // -------------------------------------------------
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;

        Id crmContactRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('CRM_Contact')
            .getRecordTypeId();

        String dupEmail = 'duplicate@test.com';

        List<Contact> contacts = new List<Contact>();

        // Master candidate (best)
        contacts.add(new Contact(
            FirstName = 'Master',
            LastName = 'Contact',
            Email = dupEmail,
            AccountId = acc.Id,
            RecordTypeId = crmContactRtId,
            Web_Id__c = 'WEB123',
            Verified__c = true,
            Contact_Status__c = 'Active'
        ));

        // Losers
        contacts.add(new Contact(
            FirstName = 'Loser1',
            LastName = 'Contact',
            Email = dupEmail,
            AccountId = acc.Id,
            RecordTypeId = crmContactRtId,
            Verified__c = false,
            Contact_Status__c = 'Inactive'
        ));

        contacts.add(new Contact(
            FirstName = 'Loser2',
            LastName = 'Contact',
            Email = dupEmail,
            AccountId = acc.Id,
            RecordTypeId = crmContactRtId,
            Verified__c = false,
            Contact_Status__c = 'Inactive'
        ));

        contacts.add(new Contact(
            FirstName = 'Loser3',
            LastName = 'Contact',
            Email = dupEmail,
            AccountId = acc.Id,
            RecordTypeId = crmContactRtId,
            Verified__c = false,
            Contact_Status__c = 'Inactive'
        ));

        insert contacts;

        Test.startTest();

        // -------------------------------------------------
        // EXECUTE BATCH
        // -------------------------------------------------
        Database.executeBatch(
            new MergeDuplicateContactsWeekend(),
            1
        );

        Test.stopTest();

        // -------------------------------------------------
        // ASSERT RESULT
        // -------------------------------------------------
        List<Contact> remaining = [
            SELECT Id, Email, AccountId
            FROM Contact
            WHERE Email = :dupEmail
            AND AccountId = :acc.Id
        ];

        // Only ONE contact should remain after merge
        System.assertEquals(
            1,
            remaining.size(),
            'Only one Contact should remain after merge'
        );
    }

    @IsTest
    static void testStart_noDuplicates_safeExit() {
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        Account acc = new Account(Name = 'Single Contact Account');
        insert acc;

        Id crmContactRtId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get('CRM_Contact')
            .getRecordTypeId();

        insert new Contact(
            FirstName = 'Single',
            LastName = 'Contact',
            Email = 'single@test.com',
            AccountId = acc.Id,
            RecordTypeId = crmContactRtId
        );

        Test.startTest();
        Database.executeBatch(new MergeDuplicateContactsWeekend(), 1);
        Test.stopTest();

        // No exception = pass
        System.assert(true);
    }

    @IsTest
    static void testInvalidKeyProtection() {
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        // Directly invoke execute logic coverage
        MergeDuplicateContactsWeekend batch =
            new MergeDuplicateContactsWeekend();

        List<String> scope = new List<String>{
            'badkey',
            'email||null',
            'email||invalidId'
        };

        Test.startTest();
        batch.execute(null, scope);
        Test.stopTest();

        System.assert(true);
    }
}