@IsTest
public class UpdateContactOwnerTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void testScheduler(){
        Test.startTest();
        system.schedule('Test status Check', '0 0 23 * * ?', new UpdateContactOwnerScheduler());
        Test.stopTest();
    }
    
    @testsetup
    static void setup() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        String uniqueSuffix = String.valueOf(DateTime.now().getTime());
        
        // Create active users
        User activeUser1 = new User(
            FirstName = 'Active', 
            LastName = 'User1', 
            Username = 'activeuser1+' + uniqueSuffix + '@example.com',
            Email = 'activeuser1+' + uniqueSuffix + '@example.com',
            Alias = 'act1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser1;
        
        User activeUser2 = new User(
            FirstName = 'Active', 
            LastName = 'User2', 
            Username = 'activeuser2+' + uniqueSuffix + '@example.com',
            Email = 'activeuser2+' + uniqueSuffix + '@example.com',
            Alias = 'act2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser2;
        
        // Create inactive users
        User inactiveUser = new User(
            FirstName = 'Inactive', 
            LastName = 'User', 
            Username = 'inactiveuser+' + uniqueSuffix + '@example.com',
            Email = 'inactiveuser+' + uniqueSuffix + '@example.com',
            Alias = 'inact',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ManagerId = activeUser2.Id,
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser;
        
        // Create inactive users
        User inactiveUser2 = new User(
            FirstName = 'Inactive2', 
            LastName = 'User5', 
            Username = 'inactiveuser2+' + uniqueSuffix + '@example.com',
            Email = 'inactiveuser2+' + uniqueSuffix + '@example.com',
            Alias = 'inact',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            ManagerId = inactiveUser.Id,
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser2;
        
        // Create accounts
        Account account1 = new Account(Name = 'Account 1', Primary_Team_Member2__c = inactiveUser.Id);
        insert account1;
        
        Account account2 = new Account(Name = 'Account 2', Primary_Team_Member2__c = inactiveUser2.Id);
        insert account2;
        
        Account account3 = new Account(Name = 'Account 3', Primary_Team_Member2__c = activeUser2.Id);
        insert account3;
        
        Account account4 = new Account(Name = 'Account 4');
        insert account4;
        
        // Create contacts owned by inactive user
        Contact contact1 = new Contact(FirstName = 'Contact', LastName = 'One', AccountId = account1.Id, OwnerId = inactiveUser.Id, Email = 'contact1@test.com');
        Contact contact2 = new Contact(FirstName = 'Contact', LastName = 'Two', AccountId = account2.Id, OwnerId = inactiveUser.Id, Email = 'contact2@test.com');
        Contact contact3 = new Contact(FirstName = 'Contact', LastName = 'three', AccountId = account3.Id, OwnerId = inactiveUser.Id, Email = 'contact3@test.com');
        Contact contact4 = new Contact(FirstName = 'Contact', LastName = 'three', AccountId = account4.Id, OwnerId = inactiveUser.Id, Email = 'contact3@test.com');         
        insert new List<Contact>{ contact1, contact2, contact3, contact4 };
            
  }
  
    @isTest
    static void testUpdateContactOwnerBatch() { 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        UpdateContactOwner batch = new UpdateContactOwner();
        Database.executeBatch(batch);
        Test.stopTest();
        
        User inactiveUser = [SELECT Id, LastName FROM User WHERE LastName = 'User' LIMIT 1];
        
        Contact updatedContact1 = [SELECT OwnerId FROM Contact WHERE LastName = 'One' LIMIT 1];
        Contact updatedContact2 = [SELECT OwnerId FROM Contact WHERE LastName = 'Two' LIMIT 1];
        
        System.assertNotEquals('Inactive user should no longer be the owner', inactiveUser.Id, updatedContact1.OwnerId);
        System.assertNotEquals('Inactive user should no longer be the owner', inactiveUser.Id, updatedContact2.OwnerId);      
        
    }
}