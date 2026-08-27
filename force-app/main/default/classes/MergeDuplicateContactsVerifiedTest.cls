@isTest
private class MergeDuplicateContactsVerifiedTest {
    
    @testsetup 
    static void testMergeDuplicateContactsVerified() { 
        set<string> accIds = new set<string>(); 
        Set<ID> accId = new Set<Id>();
        
        List<contact> contList = new List<contact>();   
        List<contact> contList1 = new List<contact>();  
        
        Account testAccount = new Account(Name = 'Test Account1');
        insert testAccount;
        accIds.add(testAccount.id);
        
        Account testAccount2 = new Account(Name = 'Test Account12');
        insert testAccount2; 
        Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId(); 
        
        Contact testContact1 = new Contact(
            FirstName = 'Whites',
            LastName = 'Blacks',
            Email = 'Whites@example.com',
            AccountId = testAccount.Id,
            verified__c = true,
            Phone='5675678980',
            Mobile__c=true,
            MobilePhone='5675678980',
            RecordTypeId=recTypeId,
            Date_Verified__c = system.today()
        );
        contList.add(testContact1);
        
        Contact testContact2 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'Whites@example.com',
            AccountId = testAccount.Id,
            verified__c = true,
            Phone= '5675678980',
            Mobile__c=true,
            MobilePhone='5675678980',
            RecordTypeId=recTypeId,
            Date_Verified__c = system.today()
        );
        contList.add(testContact2);
        
        Contact testContact12 = new Contact(
            FirstName = 'Whites',
            LastName = 'Blacks',
            Email = 'Whites@example.com',
            AccountId = testAccount.Id,
            verified__c =true,
            Phone='5675670900',
            Mobile__c=true,
            MobilePhone='5675670900',
            RecordTypeId=recTypeId,
            Date_Verified__c = system.today()
        );
        contList.add(testContact12);
        
        Contact testContact3 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'Whiteys@example.com',
            AccountId = testAccount2.Id,
            verified__c = true,
            Phone='5675670900',
            Mobile__c=true,
            MobilePhone='5675670900',
            RecordTypeId=recTypeId,
            Date_Verified__c = system.today()
        );
        contList.add(testContact3);
        
        Contact testContact4 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'Whiteys@example.com',
            AccountId = testAccount2.Id,
            verified__c = true,
            Phone= '5675670900',
            Mobile__c=true,
            MobilePhone='5675670900',
            RecordTypeId=recTypeId,
            Date_Verified__c = system.today()
        );
        contList.add(testContact4);
        
        // Create test accounts
        Account testAccount_1 = new Account(Name = 'Test Account1');
        insert testAccount_1;
        accId.add(testAccount_1.Id);
        Account testAccount_2 = new Account(Name = 'Test Account2');
        insert testAccount_2; 
        accId.add( testAccount_2.Id);  
        
        // Create duplicate contacts for Test Account 1
        Contact masterContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            AccountId = testAccount_1.Id,
            verified__c = true,
            Mobile__c = true,
            MobilePhone = '1234567890',
            RecordTypeId = recTypeId
        );
        contList1.add(masterContact1);
        
        Contact duplicateContact1 = new Contact(
            FirstName = 'Jane',
            LastName = 'Doe',
            Email = 'john.doe@example.com', // Same email as masterContact1
            AccountId = testAccount_1.Id,
            verified__c = true,
            Mobile__c = true,
            MobilePhone = '9876543210', // Different phone number
            RecordTypeId = recTypeId
        );
        contList1.add(duplicateContact1);
        // Create duplicate contacts for Test Account 2
        Contact masterContact2 = new Contact(
            FirstName = 'Alice',
            LastName = 'Smith',
            Email = 'alice.smith@example.com',
            AccountId = testAccount_2.Id,
            verified__c = true,
            Mobile__c = true,
            MobilePhone = '5678901234',
            RecordTypeId = recTypeId
        );
        contList1.add(masterContact2);
        
        Contact duplicateContact2 = new Contact(
            FirstName = 'Bob',
            LastName = 'Smith',
            Email = 'alice.smith@example.com', // Same email as masterContact2
            AccountId = testAccount_2.Id,
            verified__c = true,
            Mobile__c = true,
            MobilePhone = '4321098765', // Different phone number
            RecordTypeId = recTypeId
        );
        contList1.add(duplicateContact2);
        
        //to bypass the duplicate rules in test method
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;		
        Database.SaveResult[] sr = Database.insert(contList, dml);
        Database.SaveResult[] sr1 = Database.insert(contList1, dml);
        system.debug('contList-->'+ contList);
        
        // Set up a mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        MergeDuplicateContactsVerified batchClassInstance = new MergeDuplicateContactsVerified();
        batchClassInstance.mergeRecordsWithMaster(testContact4, new List<Contact>{testContact3, testContact2});
        
        for (Id acId : accId) {
            accIds.add(acId); // Convert Id to String
        }
        
        // Execute the batch
        Test.startTest();
        MergeDuplicateContactsVerifiedOffset batchClass = new MergeDuplicateContactsVerifiedOffset(accIds);
        Database.executeBatch(batchClass);
        batchClass.mergeRecordsWithMaster(testContact4, new List<Contact>{testContact3, testContact2});
        Test.stopTest();
        
    }
    
    @isTest
    public static void duplicateContactTest(){    
        
        Test.startTest();
        MergeDuplicateContactsVerified batchClass = new MergeDuplicateContactsVerified();
        Database.executeBatch(batchClass, 150); 
        Test.stopTest();
        
        Account acc=[Select id from Account where name='Test Account1' limit 1];
        Contact cont=[Select id from Contact where accountid=:acc.Id limit 1];
        List<Contact> mergedContacts = [SELECT Id, AccountId, Email, Phone, MobilePhone FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(cont.Id, mergedContacts[0].Id, 'The master record should be the one that remains');  
        
    }
    @isTest
    public static void duplicateContactTest1(){
        set<string> accIds = new set<string>();
        Account[] acc1=[Select id from Account where name='Test Account1' limit 1];
        accIds.add(acc1[0].id);
        
        Test.startTest();
        MergeDuplicateContactsVerifiedOffset batchClass = new MergeDuplicateContactsVerifiedOffset(accIds);
        Database.executeBatch(batchClass, 150);
        Test.stopTest();
        
        Account[] acc=[Select id from Account where name='Test Account12' limit 1];
        Contact cont=[Select id from Contact where accountid=:acc[0].Id limit 1];
        
        List<Contact> mergedContacts = [SELECT Id, AccountId, Email, Phone, MobilePhone FROM Contact WHERE AccountId = :acc[0].Id];
        System.assertEquals(cont.Id, mergedContacts[0].Id, 'The master record should be the one that remains');
        
    } 
}