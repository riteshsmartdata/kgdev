@isTest
public class testEmailToCase {

    @testSetup
    static void setup() {
        TestDataFactory.loadAppSetting();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create test data: Accounts
        Account acct1 = new Account(Name='Test Account', Status__c='Active', Customer_Account_Number__c='12345');
        Account acct2 = new Account(Name='Inactive Account', Status__c='Inactive', Customer_Account_Number__c='67890');
        insert new List<Account>{acct1, acct2};

        // Create Contacts with unique email addresses to prevent triggering the duplicate rule
        Contact cont1 = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'unique_johndoe@example.com', 
                                    Responsibility_Type__c = 'SALES_SERVICE', AccountId = acct1.Id);
        Contact cont2 = new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'unique_janedoe@example.com', 
                                    Responsibility_Type__c = 'SUPPORT', AccountId = acct2.Id);
        insert new List<Contact>{cont1, cont2};

        // Create Responsibility_Type__c record for the Contact
        Responsibility_Type__c rt1 = new Responsibility_Type__c(Email__c = cont1.Email, Contact__c = cont1.Id, Account__c = acct1.Id);
        insert rt1;

        // Create Cases with unique SuppliedEmail values to match the updated contacts
        Case case1 = new Case(SuppliedEmail='unique_johndoe@example.com', EBS_Account_Number__c=acct1.Customer_Account_Number__c, 
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId());
        Case case2 = new Case(SuppliedEmail='unique_janedoe@example.com', EBS_Account_Number__c=acct2.Customer_Account_Number__c, 
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId());
        insert new List<Case>{case1, case2};
    }

    @isTest
    static void testEmailToCaseContact() {
        // Query case records
        List<Case> caseList = [SELECT Id, SuppliedEmail, EBS_Account_Number__c, RecordType.Name FROM Case];

        // Call emailToCaseContact method
        Map<String, List<Contact>> contactMap = emailToCaseContact.emailToCaseContact(caseList);
        
        // Assert that contacts were retrieved correctly based on email
        System.assert(contactMap.containsKey('unique_johndoe@example.com'), 'Expected email should be in the map');
        System.assertEquals(1, contactMap.get('unique_johndoe@example.com').size(), 'Should only return one matching contact');
        System.assertEquals('unique_johndoe@example.com', contactMap.get('unique_johndoe@example.com')[0].Email, 'Email should match');
    }

    @isTest
    static void testEmailToCaseRT() {
        // Query case records
        List<Case> caseList = [SELECT Id, SuppliedEmail, EBS_Account_Number__c, RecordType.Name FROM Case];

        // Call emailToCaseRT method
        Map<String, List<Responsibility_Type__c>> rtMap = emailToCaseContact.emailToCaseRT(caseList);
        
        // Assert that Responsibility_Type__c records were retrieved correctly
        System.assert(rtMap.containsKey('unique_johndoe@example.com'), 'Expected email should be in the map');
        System.assertEquals(1, rtMap.get('unique_johndoe@example.com').size(), 'Should only return one matching Responsibility_Type__c');
        System.assertEquals('unique_johndoe@example.com', rtMap.get('unique_johndoe@example.com')[0].Email__c, 'Email should match');
    }

}