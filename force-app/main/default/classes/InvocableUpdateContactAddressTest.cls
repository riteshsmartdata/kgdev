@isTest
public class InvocableUpdateContactAddressTest {
    @isTest
    static void testInvokeBatch() {
        // Create test data
        List<Account> testAccounts = new List<Account>();
        testAccounts.add(new Account(Name = 'Test Account ' ));
        insert testAccounts;
        
        List<String> accountIds = new List<String>();
        for (Account acc : testAccounts) {
            accountIds.add(acc.Id);
        }
        
        List<Contact> testContact = new List<Contact>();
        testContact.add(new Contact(LastName = 'Test Contact ', Email = 'test@gmail.com', AccountId=  testAccounts[0].Id, Remote_Contact__c = false ));
        insert testContact;
        
        List<String> contactIds = new List<String>();
        for (Contact cnn : testContact) {
            contactIds.add(cnn.Id);
        }
        // Set up a mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        
        // Call the invocable method
        Test.startTest();
        InvocableUpdateContactAddress.invokeBatch(accountIds);
        //InvocableUpdateContactAddress.invokeBatch(contactIds);
        Test.stopTest();
        
        
    }
    // MockHttpResponseGenerator - Mock implementation of HttpCalloutMock
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Generate and return a mock HTTPResponse here.
            // You can simulate both success and failure responses to test your code thoroughly.
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success": true}');
            return res;
        }
    }
    
}