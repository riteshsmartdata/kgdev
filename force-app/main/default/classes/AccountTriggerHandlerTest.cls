/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 01-29-2026
 * @last modified by  : kumar.s@kooziegroup.com
**/
@IsTest
public with sharing class AccountTriggerHandlerTest {
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
    static void test_afterInsert_activeTrigger() {
        
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        // Ensure recursion flag allows execution
        KoozieUtility.isRecursion = true;

        Account acc = TestDataFactory.createAccount(
            'Insert Test',
            'ACC-001',
            'Customers',
            false
        );
        acc.Status__c = 'Active';
        acc.BillingStreet = 'Street 1';
        acc.BillingCity = 'City 1';
        acc.BillingState = 'State 1';
        acc.BillingPostalCode = '11111';
        acc.BillingCountry = 'India';

        Test.startTest();
        insert acc; // fires afterInsert
        Test.stopTest();
    }

    @IsTest
    static void test_afterUpdate_statusChange_and_addressChange() {
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        // Ensure recursion flag allows execution
        KoozieUtility.isRecursion = true;

        // Create Account
        Account acc = TestDataFactory.createAccount(
            'Update Test',
            'ACC-002',
            'Customers',
            true 
        );
        

        // Create related Contact (for address sync safety)
        TestDataFactory.createContact(
            'Last',
            'First',
            acc.Id,
            'CRM Contact',
            true
        );

        // Update to trigger afterUpdate logic
        acc.Status__c = 'Inactive'; // status change branch
        acc.BillingStreet = 'New Street'; // address change branch
        acc.BillingCity = 'New City';

        Test.startTest();
        update acc;

        Test.stopTest();
    }

    @IsTest
    static void test_afterUpdate_recursionFalse_exit() {
        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        // Force recursion guard to exit early
        KoozieUtility.isRecursion = false;

        Account acc = TestDataFactory.createAccount(
            'Recursion Exit Test',
            'ACC-003',
            'Customers',
            true
        );
        acc.Status__c = 'Inactive';

        Test.startTest();
        update acc; // should exit early due to recursion flag
        Test.stopTest();
    }
}