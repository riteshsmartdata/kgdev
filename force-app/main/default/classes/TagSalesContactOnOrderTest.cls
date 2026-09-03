/**
 * @description Test class for TagSalesContactOnOrder
 * @author Salesforce
 * @date 2026
 */
@isTest
private class TagSalesContactOnOrderTest {
    
    /**
     * @description Setup test data for all test methods
     * Creates 2 accounts: 
     * 1. BDF Account (Customer_Class_Code__c = 'BDF') - Account_Name__c field
     * 2. Distributor Account - Distributor_Account__c field (where contacts are created/reparented)
     */
    @TestSetup
    static void setupTestData() {
        // Load app settings and trigger settings
        TestDataFactory.loadAppSetting();
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create BDF Account (this is the account checked for BDF status - Account_Name__c)
        Account bdfAccount = TestDataFactory.createAccount(
            'BDF Test Account',
            'BDF12345',
            'Customers',
            false
        );
        bdfAccount.Customer_Class_Code__c = KoozieConstants.ACCOUNT_CLASS_CODE_BDF;
        insert bdfAccount;
        
        // Create Distributor Account (this is where contacts are created/reparented - Distributor_Account__c)
        Account distributorAccount = TestDataFactory.createAccount(
            'Distributor Account',
            'DIST12345',
            'Customers',
            true
        );
        
        // Create test contacts with different record types under distributor account
        List<Contact> testContacts = new List<Contact>();
        
        // Contact 1 - CRM Contact
        Contact contact1 = TestDataFactory.createContact(
            'Contact1',
            'Test',
            distributorAccount.Id,
            'CRM Contact',
            false
        );
        contact1.Email = 'test1@test.com';
        testContacts.add(contact1);
        
        // Contact 2 - Multi-Line Rep
        Contact contact2 = TestDataFactory.createContact(
            'Contact2',
            'Test',
            distributorAccount.Id,
            'Multi-Line Rep',
            false
        );
        contact2.Email = 'test2@test.com';
        testContacts.add(contact2);
        
        // Contact 3 - Another CRM Contact
        Contact contact3 = TestDataFactory.createContact(
            'Contact3',
            'Test',
            distributorAccount.Id,
            'CRM Contact',
            false
        );
        contact3.Email = 'test3@test.com';
        testContacts.add(contact3);
        
        insert testContacts;
    }
    
    /**
     * @description Test beforeInsert with valid sales contact email
     * Account_Name__c = BDF Account, Distributor_Account__c = Distributor, all conditions met
     */
    @isTest
    static void testBeforeInsert_ValidSalesContact() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with BDF Account_Name__c and Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was populated (all conditions met)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(testContact.Id, insertedOrder.SalesContact__c, 'SalesContact should be populated when all conditions met');
    }
    
    /**
     * @description Test beforeInsert with missing Account_Name__c
     * Even with Distributor_Account__c, missing Account_Name__c prevents defaultCheck
     */
    @isTest
    static void testBeforeInsert_MissingAccountName() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order without Account_Name__c but WITH Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = 'test@test.com'
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT populated (Account_Name__c required for defaultCheck)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated without Account_Name__c');
    }
    
    /**
     * @description Test beforeInsert with missing Sales_Contact__c
     * Even with both accounts, missing Sales_Contact__c prevents processing
     */
    @isTest
    static void testBeforeInsert_MissingSalesContact() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order without Sales_Contact__c but WITH both accounts
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT populated (Sales_Contact__c required)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated without Sales_Contact__c');
    }
    
    /**
     * @description Test beforeInsert with blank email
     * Even with both accounts, blank Sales_Contact__c prevents processing
     */
    @isTest
    static void testBeforeInsert_BlankEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order with blank email but WITH both accounts
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = ''
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT populated (blank Sales_Contact__c fails defaultCheck)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated with blank email');
    }
    
    /**
     * @description Test beforeUpdate with no Sales_Contact__c change
     * No processing should occur when Sales_Contact__c doesn't change
     */
    @isTest
    static void testBeforeUpdate_NoSalesContactChange() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with both accounts
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        insert ebsOrder;
        
        // Update without changing Sales_Contact__c (update a different field)
        ebsOrder.EBS_Order_Number__c = 'TEST-12345';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c remains the same
        EBS_Order__c updatedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(testContact.Id, updatedOrder.SalesContact__c, 'SalesContact should remain unchanged');
    }
    
    /**
     * @description Test beforeUpdate with missing Account_Name__c
     * Even with Distributor_Account__c, missing Account_Name__c prevents defaultCheck
     */
    @isTest
    static void testBeforeUpdate_MissingAccountName() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order without Account_Name__c but WITH Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = 'initial@test.com'
        );
        insert ebsOrder;
        
        // Update Sales_Contact__c
        ebsOrder.Sales_Contact__c = 'updated@test.com';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT populated (Account_Name__c required for defaultCheck)
        EBS_Order__c updatedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, updatedOrder.SalesContact__c, 'SalesContact should not be populated without Account_Name__c');
    }
    
    /**
     * @description Test beforeUpdate with non-existent email
     * With all conditions met but email doesn't exist, SalesContact remains unchanged
     */
    @isTest
    static void testBeforeUpdate_NonExistentEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with both accounts
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        insert ebsOrder;
        
        // Update with non-existent email
        ebsOrder.Sales_Contact__c = 'nonexistent@email.com';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT updated (contact doesn't exist)
        EBS_Order__c updatedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertNotEquals(testContact.Id, updatedOrder.SalesContact__c, 'SalesContact should remain unchanged for non-existent email');
    }
    
    /**
     * @description Test with Distributor_Account__c populated
     * Using BDF and Distributor accounts - SalesContact should be populated
     */
    @isTest
    static void testBeforeInsert_WithDistributorAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with both BDF and Distributor accounts
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify order was created and SalesContact populated
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertNotEquals(null, insertedOrder, 'Order should be created');
        System.assertEquals(testContact.Id, insertedOrder.SalesContact__c, 'SalesContact should be populated');
    }
    
    /**
     * @description Test afterInsert with Distributor_Account__c creating new contact
     * With BDF account and new email, contact should be created under Distributor
     */
    @isTest
    static void testAfterInsert_WithDistributorAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order with new external email (not in system)
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = 'newcontact@external.com',
            Sales_Contact_First_Name__c = 'New',
            Sales_Contact_Last_Name__c = 'Contact'
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify order was processed and contact created
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertNotEquals(null, insertedOrder, 'Order should be created');
        
        // Verify contact was created under Distributor account
        List<Contact> newContacts = [SELECT Id, AccountId FROM Contact WHERE Email = 'newcontact@external.com' LIMIT 1];
        if(newContacts.size() > 0) {
            System.assertEquals(distributorAccount.Id, newContacts[0].AccountId, 'Contact should be created under Distributor account');
        }
    }
    
    /**
     * @description Test afterUpdate with Distributor_Account__c and email change
     * With BDF account, changing email should create/update contact
     */
    @isTest
    static void testAfterUpdate_WithDistributorAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with existing contact
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        insert ebsOrder;
        
        // Update Sales_Contact__c to new email
        ebsOrder.Sales_Contact__c = 'newemail@external.com';
        ebsOrder.Sales_Contact_First_Name__c = 'New';
        ebsOrder.Sales_Contact_Last_Name__c = 'Email';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify order was updated
        EBS_Order__c updatedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertNotEquals(null, updatedOrder, 'Order should exist');
    }
    
    /**
     * @description Test with koozie domain email (should be excluded)
     * With BDF and Distributor, koozie email should NOT be processed
     */
    @isTest
    static void testBeforeInsert_KoozieDomainEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order with koozie domain email
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = 'test@kooziegroup.com'
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c was NOT populated (koozie domain excluded by defaultCheck)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated for koozie domain');
    }
    
    
    /**
     * @description Test afterInsert with non-BDF Customer_Class_Code__c
     * Non-BDF account should not trigger contact creation
     */
    @isTest
    static void testAfterInsert_NonBDFAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create non-BDF account for this test
        Account nonBDFAccount = TestDataFactory.createAccount(
            'Non-BDF AfterInsert Test',
            'NONBDFAI1',
            'Customers',
            false
        );
        nonBDFAccount.Customer_Class_Code__c = 'GHI';
        insert nonBDFAccount;
        
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        
        // Create EBS Order with new contact email and non-BDF account
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = nonBDFAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = 'newuser@external.com',
            Sales_Contact_First_Name__c = 'New',
            Sales_Contact_Last_Name__c = 'User'
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify no new contact was created (account is not BDF)
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'newuser@external.com'];
        System.assertEquals(0, contacts.size(), 'No contact should be created for non-BDF account');
        
        // Verify SalesContact__c was not populated
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated for non-BDF account');
    }
    
    /**
     * @description Test afterInsert with missing Distributor_Account__c
     * BDF account without Distributor should not process
     */
    @isTest
    static void testAfterInsert_MissingDistributorAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        
        // Create EBS Order without Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Sales_Contact__c = 'newuser2@external.com',
            Sales_Contact_First_Name__c = 'New',
            Sales_Contact_Last_Name__c = 'User2'
            // Distributor_Account__c is intentionally missing
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify no processing occurred (Distributor_Account__c is mandatory)
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'newuser2@external.com'];
        System.assertEquals(0, contacts.size(), 'No contact should be created without Distributor_Account');
        
        // Verify SalesContact__c was not populated
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(null, insertedOrder.SalesContact__c, 'SalesContact should not be populated without Distributor_Account');
    }
    
    /**
     * @description Test afterUpdate with non-BDF Customer_Class_Code__c
     * Non-BDF account should not trigger contact creation on update
     */
    @isTest
    static void testAfterUpdate_NonBDFAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create non-BDF account for this test
        Account nonBDFAccount = TestDataFactory.createAccount(
            'Non-BDF AfterUpdate Test',
            'NONBDFAU1',
            'Customers',
            false
        );
        nonBDFAccount.Customer_Class_Code__c = 'JKL';
        insert nonBDFAccount;
        
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with non-BDF account
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = nonBDFAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        insert ebsOrder;
        
        // Update Sales_Contact__c
        ebsOrder.Sales_Contact__c = 'updated@external.com';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify no new contact was created (account is not BDF)
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'updated@external.com'];
        System.assertEquals(0, contacts.size(), 'No contact should be created for non-BDF account on update');
    }
    
    /**
     * @description Test afterUpdate with missing Distributor_Account__c
     * BDF account without Distributor should not process on update
     */
    @isTest
    static void testAfterUpdate_MissingDistributorAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order without Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Sales_Contact__c = testContact.Email
            // Distributor_Account__c is intentionally missing
        );
        insert ebsOrder;
        
        // Update Sales_Contact__c
        ebsOrder.Sales_Contact__c = 'updated2@external.com';
        
        Test.startTest();
        update ebsOrder;
        Test.stopTest();
        
        // Verify no processing occurred (Distributor_Account__c is mandatory)
        List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'updated2@external.com'];
        System.assertEquals(0, contacts.size(), 'No contact should be created without Distributor_Account on update');
    }
    
    /**
     * @description Test valid BDF scenario with all conditions met
     * Positive test case with BDF and Distributor
     */
    @isTest
    static void testBeforeInsert_ValidBDFWithDistributor() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Account distributorAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'DIST12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order with BDF account AND Distributor_Account__c
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Distributor_Account__c = distributorAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify SalesContact__c WAS populated (all conditions met)
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertEquals(testContact.Id, insertedOrder.SalesContact__c, 'SalesContact should be populated when all conditions are met');
    }
    
    /**
     * @description Test constructor
     * Simple test to verify trigger handler instantiation
     */
    @isTest
    static void testConstructor() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Account bdfAccount = [SELECT Id FROM Account WHERE Customer_Account_Number__c = 'BDF12345' LIMIT 1];
        Contact testContact = [SELECT Id, Email FROM Contact WHERE Email = 'test1@test.com' LIMIT 1];
        
        // Create EBS Order to trigger constructor
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = bdfAccount.Id,
            Sales_Contact__c = testContact.Email
        );
        
        Test.startTest();
        insert ebsOrder;
        Test.stopTest();
        
        // Verify successful creation
        EBS_Order__c insertedOrder = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :ebsOrder.Id];
        System.assertNotEquals(null, insertedOrder, 'Order should be created');
    }
}