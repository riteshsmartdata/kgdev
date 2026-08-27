@isTest
public class mergeDupContactsVerifiedOneTimeTest {

    @testsetup 
    static void testMergeDuplicateContactsVerified() {
        List<contact> contList=new List<contact>();        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Account testAccount2 = new Account(Name = 'Test Account2');
        insert testAccount2; 
        
        Contact testContact1 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'White@example.com',
            AccountId = testAccount.Id,
            verified__c = true,
            Phone='',
            Mobile__c=true,
            MobilePhone=''
        );
        contList.add(testContact1);
        
        Contact testContact2 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'White@example.com',
            AccountId = testAccount.Id,
            verified__c = false,
            Phone= '5675678989',
            Mobile__c=true,
            MobilePhone='5675678989'
        );
       contList.add(testContact2);
        
		Contact testContact3 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'Whitey@example.com',
            AccountId = testAccount2.Id,
            verified__c = true,
            Phone='',
            Mobile__c=true,
            MobilePhone=''
        );
        contList.add(testContact3);
        
        Contact testContact4 = new Contact(
            FirstName = 'White',
            LastName = 'Black',
            Email = 'Whitey@example.com',
            AccountId = testAccount2.Id,
            verified__c = false,
            Phone= '5675670909',
            Mobile__c=true,
            MobilePhone='5675670909'
        );
        contList.add(testContact4);        
		//to bypass the duplicate rules in test method
		Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.allowSave = true;
		dml.DuplicateRuleHeader.runAsCurrentUser = true;		
		Database.SaveResult[] sr = Database.insert(contList, dml);
        
        // Set up a mock response for the HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
    }
    
    @isTest
    public static void duplicateContactTest(){
        
        Test.startTest();
        MergeDuplicateContactsVerifiedOneTime batchClass = new MergeDuplicateContactsVerifiedOneTime();
        Database.executeBatch(batchClass, 150);
        Test.stopTest();
        
        Account acc=[Select id from Account where name='Test Account' limit 1];
        Contact cont=[Select id from Contact where accountid=:acc.Id limit 1];
        List<Contact> mergedContacts = [SELECT Id, AccountId, Email, Phone, MobilePhone FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(1, mergedContacts.size(), 'There should only be one contact after merging');
        System.assertEquals(cont.Id, mergedContacts[0].Id, 'The master record should be the one that remains');  
    }
     @isTest
    public static void duplicateContactTest1(){
        set<string> accIds = new set<string>();
        Account[] acc1=[Select id from Account where name='Test Account' limit 1];
        accIds.add(acc1[0].id);
        
        Test.startTest();
        MergeDuplicateContactsOffsetOneTime batchClass = new MergeDuplicateContactsOffsetOneTime(accIds);
        Database.executeBatch(batchClass, 150);
        Test.stopTest();
        
        Account[] acc=[Select id from Account where name='Test Account2' limit 1];
        Contact cont=[Select id from Contact where accountid=:acc[0].Id limit 1];
        
        List<Contact> mergedContacts = [SELECT Id, AccountId, Email, Phone, MobilePhone FROM Contact WHERE AccountId = :acc[0].Id];
        System.assertEquals(1, mergedContacts.size(), 'There should only be one contact after merging');
        System.assertEquals(cont.Id, mergedContacts[0].Id, 'The master record should be the one that remains');
        
    } 
    @isTest(SeeAllData=false)
    public static void noDuplicatesTest() {
        // Create test data with no duplicate contacts and verify the behavior.
        Account testAccount = new Account(Name = 'No Duplicates Account');
        insert testAccount;
        
        Contact testContact1 = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john@example.com',
            AccountId = testAccount.Id,
            verified__c = true,
            Phone = '1234567890'
        );
        insert testContact1;
        
                Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Test.startTest();
      //  MergeDuplicateContactsOffsetOneTime batchClass = new MergeDuplicateContactsOffsetOneTime();
      //S  Database.executeBatch(batchClass, 150);
        Test.stopTest();
        
        // Verify that nothing is merged when there are no contacts.
        Account acc = [SELECT Id FROM Account WHERE Name = 'No Duplicates Account' LIMIT 1];
        List<Contact> mergedContacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(1, mergedContacts.size(), 'No records should have been merged');
    }
    
    
    @isTest
    public static void emptyBatchTest() {
        // Create a scenario where there are no contacts to process and verify the behavior.
        Account testAccount = new Account(Name = 'Empty Batch Account');
        insert testAccount;
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Test.startTest();
        MergeDuplicateContactsVerifiedOneTime batchClass = new MergeDuplicateContactsVerifiedOneTime();
        Database.executeBatch(batchClass, 150);
        Test.stopTest();
        
        // Verify that nothing is merged when there are no contacts.
        Account acc = [SELECT Id FROM Account WHERE Name = 'Empty Batch Account' LIMIT 1];
        List<Contact> mergedContacts = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        System.assertEquals(0, mergedContacts.size(), 'No records should be merged');
    }  
}