@isTest
public class ContactMergeHelperTest {

    @testSetup
    static void setupTestData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create test Contacts
        Contact testContact1 = new Contact(FirstName = 'Test', LastName = 'Contact1', Email = 'test321@test.com');
        Contact testContact2 = new Contact(FirstName = 'Test', LastName = 'Contact2', Email = 'test54321@test.com');
        insert new List<Contact>{testContact1, testContact2};
        
        // Create Contact Roles for these Contacts (duplicates for Contact 1)
        Contact_Roles__c contactRole1 = new Contact_Roles__c(Contact__c = testContact1.Id, Contact_Role_Name__c = ' PO CONTACT', CreatedDate = Date.today().addDays(-10));
        Contact_Roles__c contactRole2 = new Contact_Roles__c(Contact__c = testContact1.Id, Contact_Role_Name__c = ' PO CONTACT', CreatedDate = Date.today().addDays(-5));
        Contact_Roles__c contactRole3 = new Contact_Roles__c(Contact__c = testContact2.Id, Contact_Role_Name__c = 'ORDER CONFIRM CONTACT', CreatedDate = Date.today().addDays(-2));
        
        insert new List<Contact_Roles__c>{contactRole1, contactRole2, contactRole3};
    }
    
    @isTest
    static void testHandleContactPostMerge() {
        // Query for the test contacts
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        // Prepare the master and the record to be merged
        Contact masterContact = contacts[1];
        Contact mergeContact = contacts[0];
        
        // Perform the merge
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Database.merge(masterContact, mergeContact);
        Test.stopTest();
        
        // Verify that duplicate Contact Roles for the merged Contact have been deleted
        List<Contact_Roles__c> remainingRoles = [SELECT Id FROM Contact_Roles__c];
        System.assertEquals(2, remainingRoles.size(), 'There should be 2 Contact Roles remaining after merge cleanup.');
    }
    
    @isTest
    static void testHandlePostDeleteCleanup() {
        // Query for the test contacts and delete them
        List<Contact> contactsToDelete = [SELECT Id FROM Contact LIMIT 2];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        delete contactsToDelete;
        ContactMergeHelper.handlePostDeleteCleanup(contactsToDelete);
        Test.stopTest();
        
        // Verify that Contact Roles related to deleted Contacts have been processed
        List<Contact_Roles__c> remainingRolesAfterDelete = [SELECT Id FROM Contact_Roles__c WHERE Contact__c IN :contactsToDelete];
        System.assertEquals(0, remainingRolesAfterDelete.size(), 'There should be no Contact Roles related to deleted Contacts.');
    }
    
    @isTest
    static void testHandleEmptyContactRoles() {
        // Call the method with an empty list
        List<Contact_Roles__c> emptyList = new List<Contact_Roles__c>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ContactRolesHandler.handleContactRoleDuplicates(emptyList);
        Test.stopTest();
        
        // Ensure no errors and no DML is performed
        System.assertEquals(0, emptyList.size(), 'No action should be taken on an empty list of Contact Roles.');
    }
}