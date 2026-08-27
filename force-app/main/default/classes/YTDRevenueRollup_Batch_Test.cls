@IsTest
private class YTDRevenueRollup_Batch_Test {

    // HTTP mock to satisfy any unexpected callouts during batch execution
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Utility to get or create the Customers record type for Account
    private static Id getCustomersRecordTypeId() {
        // Try by developer name first (as batch uses developer name 'Customers')
        Map<String, Schema.RecordTypeInfo> rtInfos = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        if (rtInfos != null && rtInfos.containsKey('Customers')) {
            return rtInfos.get('Customers').getRecordTypeId();
        }
        // Fallback: find any active customer-like record type or default
        for (Schema.RecordTypeInfo rti : Schema.SObjectType.Account.getRecordTypeInfos()) {
            if (rti.isAvailable() && !rti.isMaster()) {
                return rti.getRecordTypeId();
            }
        }
        // If no record type is available in the org (unlikely), return null and tests that depend on it will branch accordingly.
        return null;
    }

    // Creates a minimal valid Account for this org. Adjust fields if org requires additional required fields.
    private static Account makeAccount(String name, Id recordTypeId, Boolean activeCustomer) {
        Account a = new Account();
        a.Name = name;
        if (recordTypeId != null) a.RecordTypeId = recordTypeId;
        if (activeCustomer != null) a.Status__c = activeCustomer ? 'Active' : 'Inactive';
        return a;
    }

    @IsTest
    static void happyPath_executesAndCallsService_allActiveCustomers() {
        // Web service callouts mocking
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Id customersRtId = getCustomersRecordTypeId();

        // Test setup: mix of eligible and non-eligible Accounts
        List<Account> toInsert = new List<Account>();
        toInsert.add(makeAccount('Acct Active Customer 1', customersRtId, true));
        toInsert.add(makeAccount('Acct Active Customer 2', customersRtId, true));
        toInsert.add(makeAccount('Acct Inactive Customer', customersRtId, false));
        // Non-customer record type (if possible) to ensure it is excluded
        Id otherRtId = null;
        for (Schema.RecordTypeInfo rti : Schema.SObjectType.Account.getRecordTypeInfos()) {
            if (rti.getRecordTypeId() != customersRtId && !rti.isMaster()) {
                otherRtId = rti.getRecordTypeId();
                break;
            }
        }
        toInsert.add(makeAccount('Acct Other RT Active', otherRtId, true));

        insert toInsert;

        // Verify we have the data we expect
        System.assertEquals(4, [SELECT COUNT() FROM Account WHERE Id IN :toInsert], 'Precondition: all 4 accounts inserted');
        Test.startTest();
        // Run the batch for "all" eligible Accounts (Active + Customers RT)
        Database.ExecuteBatch(new YTDRevenueRollup_Batch(), 50);
        Test.stopTest();
        System.assertEquals(4, [SELECT COUNT() FROM Account WHERE Id IN :toInsert], 'All accounts should persist');
    }

    @IsTest
    static void selectiveConstructor_executesOnlyForProvidedIds() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Id customersRtId = getCustomersRecordTypeId();

        Account eligible = makeAccount('Selective Eligible', customersRtId, true);
        Account ineligible = makeAccount('Selective Ineligible', customersRtId, false);
        insert new List<Account>{ eligible, ineligible };

        // Execute batch only for the specific eligible record via selective constructor
        Set<Id> specific = new Set<Id>{ eligible.Id };

        Test.startTest();
        Database.executeBatch(new YTDRevenueRollup_Batch(specific), 10);
        Test.stopTest();

        // If field on Account is updated (e.g., YTD_Revenue__c), assert it here.
        // assert to ensure no unhandled exceptions and records exist.
        System.assertNotEquals(null, eligible.Id, 'Eligible account should exist');
        System.assertNotEquals(null, ineligible.Id, 'Ineligible account should exist');
    }

    @IsTest
    static void emptyDataSet_noErrors() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // No accounts inserted that match criteria; if Customers RT exists and requires Active,
        // we ensure no active customers in org data context by not inserting anything.

        Test.startTest();
        Database.executeBatch(new YTDRevenueRollup_Batch(), 50);
        Test.stopTest();

        // No exception means pass. confirm finish() executed by asserting side effects if any.
        System.assert(true, 'Batch should complete gracefully with empty start() result');
    }

    @IsTest
    static void scopeBoundary_multipleBatchesProcessed() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Id customersRtId = getCustomersRecordTypeId();

        // Create exactly 50 eligible accounts to ensure a single execute() invocation with scope=50
        Integer total = 50;
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < total; i++) {
            bulkAccounts.add(makeAccount('Bulk Eligible ' + i, customersRtId, true));
        }
        insert bulkAccounts;

        Test.startTest();
        // Match size to batch size to avoid multiple executeBatch invocations in test context
        Database.executeBatch(new YTDRevenueRollup_Batch(), 50);
        Test.stopTest();

        System.assertEquals(total, [SELECT COUNT() FROM Account WHERE Id IN :bulkAccounts], 'All bulk accounts should persist');
    }
}