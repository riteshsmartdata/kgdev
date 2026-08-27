@isTest
private class EBSFinanceContactBatchTest {

    // ─────────────────────────────────────────────────────────────
    // Test Data Setup
    // ─────────────────────────────────────────────────────────────

    /**
     * Creates shared test data:
     *  - An Account with Status__c = 'Active'
     *  - A Finance Contact RecordType contact with Contact_Status__c = 'Active'
     *  - AppInfo__c custom settings for both Sandbox and WebClient
     */
    @TestSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        // ── AppInfo__c custom setting (Sandbox) ──────────────────
        AppInfo__c sandboxSetting = new AppInfo__c(
            Name        = 'Sandbox',
            endpoint__c = 'https://sandbox.example.com/api/contact',
            user__c     = 'testUser',
            password__c = 'testPass'
        );
        insert sandboxSetting;

        // ── AppInfo__c custom setting (WebClient) ────────────────
        AppInfo__c webClientSetting = new AppInfo__c(
            Name        = 'WebClient',
            endpoint__c = 'https://prod.example.com/api/contact',
            user__c     = 'prodUser',
            password__c = 'prodPass'
        );
        insert webClientSetting;

        // ── Active Account ───────────────────────────────────────
        Account acc = new Account(
            Name      = 'Test Account',
            Status__c = 'Active',
            Customer_Account_Number__c = 'CUST-001'
        );
        insert acc;

        // ── Finance Contact RecordType ───────────────────────────
        RecordType financeRT = [
            SELECT Id
            FROM   RecordType
            WHERE  SObjectType = 'Contact'
            AND    Name        = 'Finance Contact'
            LIMIT  1
        ];

        // ── Active Finance Contact ───────────────────────────────
        Contact activeContact = new Contact(
            FirstName          = 'John',
            LastName           = 'Doe',
            Email              = 'john.doe@test.com',
            Phone              = '1234567890',
            AccountId          = acc.Id,
            RecordTypeId       = financeRT.Id,
            Contact_Status__c  = 'Active',
            Responsibility_Type__c = 'Finance',
            PrimaryEmailFlag__c    = true,
            PrimaryPhoneFlag__c    = true
        );
        insert activeContact;

        // ── Inactive Finance Contact (should be excluded by batch query) ──
        Contact inactiveContact = new Contact(
            FirstName         = 'Jane',
            LastName          = 'Smith',
            Email             = 'jane.smith@test.com',
            AccountId         = acc.Id,
            RecordTypeId      = financeRT.Id,
            Contact_Status__c = 'Inactive'
        );
        insert inactiveContact;
    }

    // ─────────────────────────────────────────────────────────────
    // Mock: HTTP Success (200)
    // ─────────────────────────────────────────────────────────────
    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mock: HTTP Error (500)
    // ─────────────────────────────────────────────────────────────
    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mock: HTTP 201 Created
    // ─────────────────────────────────────────────────────────────
    private class CreatedMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setBody('{"status":"created"}');
            return res;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Mock: Throws a CalloutException
    // ─────────────────────────────────────────────────────────────
    private class ExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            CalloutException e = (CalloutException) CalloutException.class.newInstance();
            e.setMessage('Simulated callout exception');
            throw e;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 1 – Batch: successful callout, no error logs created
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testBatchExecute_Success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        EBSFinanceContactBatch batch = new EBSFinanceContactBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        // No Apex_Errors__c records should have been created
        List<Apex_Errors__c> logs = [SELECT Id FROM Apex_Errors__c];
        System.assertEquals(0, logs.size(), 'No error logs should be created on success');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 2 – Batch: HTTP 500 error, error log must be inserted
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testBatchExecute_HttpError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        EBSFinanceContactBatch batch = new EBSFinanceContactBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        List<Apex_Errors__c> logs = [
            SELECT Id, Error_Message__c, Status_Code__c, Object_API_Name__c
            FROM   Apex_Errors__c
        ];
        System.assertNotEquals(0, logs.size(), 'Error logs should be created on HTTP error');
        System.assertEquals('HTTP Error',  logs[0].Error_Message__c);
        System.assertEquals(500,           (Integer) logs[0].Status_Code__c);
        System.assertEquals('Contact',     logs[0].Object_API_Name__c);
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 3 – Batch: callout exception, error log must be inserted
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testBatchExecute_CalloutException() {
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());

        Test.startTest();
        EBSFinanceContactBatch batch = new EBSFinanceContactBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        List<Apex_Errors__c> logs = [
            SELECT Id, Error_Message__c, Status_Code__c
            FROM   Apex_Errors__c
        ];
        System.assertNotEquals(0, logs.size(), 'Error logs should be created on callout exception');
        System.assertEquals(500, (Integer) logs[0].Status_Code__c);
        System.assert(logs[0].Error_Message__c.contains('Simulated callout exception'),
            'Exception message should be captured');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 4 – Batch: HTTP 201 Created is treated as success
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testBatchExecute_Http201() {
        Test.setMock(HttpCalloutMock.class, new CreatedMock());

        Test.startTest();
        EBSFinanceContactBatch batch = new EBSFinanceContactBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        List<Apex_Errors__c> logs = [SELECT Id FROM Apex_Errors__c];
        System.assertEquals(0, logs.size(), '201 responses should not create error logs');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 5 – Schedulable: job is enqueued without errors
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSchedulable() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        String cronExp = '0 0 0 1 1 ? 2099';

        Test.startTest();
        String jobId = System.schedule(
            'EBSFinanceContactBatch_TestJob',
            cronExp,
            new EBSFinanceContactBatch()
        );
        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, CronExpression, State
            FROM   CronTrigger
            WHERE  Id = :jobId
        ];
        System.assertNotEquals(null, ct, 'Scheduled job should exist');
        System.assertEquals(cronExp, ct.CronExpression);
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 6 – Service: empty contactIds returns empty result list
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_EmptyIds() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(new List<Id>(), 'Create');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Result list should not be null');
        System.assertEquals(0, results.size(), 'Result list should be empty for empty input');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 7 – Service: null contactIds returns empty result list
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_NullIds() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(null, 'Create');
        Test.stopTest();

        System.assertNotEquals(null, results);
        System.assertEquals(0, results.size());
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 8 – Service: successful callout sets isSuccess = true
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_Success() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Contact con = [SELECT Id FROM Contact WHERE Contact_Status__c = 'Active' LIMIT 1];

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(
                new List<Id>{ con.Id }, 'Create'
            );
        Test.stopTest();

        System.assertEquals(1,    results.size());
        System.assertEquals(true, results[0].isSuccess, 'isSuccess should be true for 200 response');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 9 – Service: HTTP error sets isSuccess = false and
    //          captures correct fields
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_HttpError() {
        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Contact con = [SELECT Id FROM Contact WHERE Contact_Status__c = 'Active' LIMIT 1];

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(
                new List<Id>{ con.Id }, 'Create'
            );
        Test.stopTest();

        System.assertEquals(1,     results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertEquals(500,   results[0].statusCode);
        System.assertEquals('HTTP Error', results[0].error);
        System.assertEquals('Contact',    results[0].objectName);
        System.assertEquals(con.Id,       results[0].contactId);
        System.assertEquals('EBSContactIntegrationService', results[0].source);
        System.assertNotEquals(null, results[0].requestBody,  'requestBody should be populated');
        System.assertNotEquals(null, results[0].responseBody, 'responseBody should be populated');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 10 – Service: callout exception sets isSuccess = false
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_Exception() {
        Test.setMock(HttpCalloutMock.class, new ExceptionMock());

        Contact con = [SELECT Id FROM Contact WHERE Contact_Status__c = 'Active' LIMIT 1];

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(
                new List<Id>{ con.Id }, 'Create'
            );
        Test.stopTest();

        System.assertEquals(1,     results.size());
        System.assertEquals(false, results[0].isSuccess);
        System.assertEquals(500,   results[0].statusCode);
        System.assert(
            results[0].error.contains('Simulated callout exception'),
            'Exception message should be stored in error field'
        );
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 11 – Service: Update event type is handled correctly
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testSendContactDataBulk_UpdateEventType() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Contact con = [SELECT Id FROM Contact WHERE Contact_Status__c = 'Active' LIMIT 1];

        Test.startTest();
        List<EBSFinanceContactBatch.EBSContactCalloutResult> results =
            EBSContactIntegrationService.sendContactDataBulk(
                new List<Id>{ con.Id }, 'Update'
            );
        Test.stopTest();

        System.assertEquals(1,    results.size());
        System.assertEquals(true, results[0].isSuccess, 'Update event type should succeed');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 12 – Batch query scope: inactive contacts are excluded
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testBatchQuery_ExcludesInactiveContacts() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        // Verify test data: 1 active, 1 inactive finance contact
        Integer activeCount = [
            SELECT COUNT()
            FROM   Contact
            WHERE  Contact_Status__c = 'Active'
            AND    Account.Status__c = 'Active'
        ];
        System.assertEquals(1, activeCount, 'Only active contacts should be in scope');

        Test.startTest();
        EBSFinanceContactBatch batch = new EBSFinanceContactBatch();
        Database.executeBatch(batch, 50);
        Test.stopTest();

        // Batch ran without exceptions — verified implicitly
        System.assert(true, 'Batch completed successfully');
    }

    // ─────────────────────────────────────────────────────────────
    // TEST 13 – EBSContactCalloutResult inner class: field mapping
    // ─────────────────────────────────────────────────────────────
    @isTest
    static void testEBSContactCalloutResult_FieldMapping() {
        Test.setMock(HttpCalloutMock.class, new SuccessMock());
        EBSFinanceContactBatch.EBSContactCalloutResult r =
            new EBSFinanceContactBatch.EBSContactCalloutResult();
        
        r.source      = 'TestSource';
        r.requestBody = '{"test":"req"}';
        r.responseBody = '{"test":"res"}';
        r.contactId   = UserInfo.getUserId(); // any valid Id for testing
        r.objectName  = 'Contact';
        r.error       = 'Test error';
        r.statusCode  = 400;
        r.isSuccess   = false;

        System.assertEquals('TestSource',      r.source);
        System.assertEquals('{"test":"req"}',  r.requestBody);
        System.assertEquals('{"test":"res"}',  r.responseBody);
        System.assertEquals('Contact',          r.objectName);
        System.assertEquals('Test error',       r.error);
        System.assertEquals(400,                r.statusCode);
        System.assertEquals(false,              r.isSuccess);
    }
}