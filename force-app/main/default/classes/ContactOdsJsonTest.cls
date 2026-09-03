@isTest
public class ContactOdsJsonTest {
    @TestSetup
    static void makeData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Account> lstAccount = new List<Account>();
        Account accountRecord = TestData.createAccount(false);
        accountRecord.Name = 'Account Testers';
        accountRecord.Customer_Account_Number__c = '987654321';
        accountRecord.Status__c = 'Active';
        lstAccount.add(accountRecord);
        Account accountRecord1 = TestData.createAccount(false);
        accountRecord1.Name = 'Account 1';
        accountRecord1.Customer_Account_Number__c = '9876521';
        accountRecord1.Status__c = 'Active'; 
        accountRecord1.Industry = 'Education';
        accountRecord1.Territory__c = 'Test Terr';
        lstAccount.add(accountRecord1);
        insert lstAccount;
    }
    @isTest    
    public static void replaceOneJSON_A(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Account Testers' LIMIT 1];
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Testers Last Name';
        contactRecord.FirstName = 'Testers First Name';
        contactRecord.Phone = '8745122356'; 
        contactRecord.MiddleName ='Test';
        contactRecord.Responsibility_Type__c = null;
        contactRecord.AccountId  = accountRecord.Id;
        insert contactRecord; 
        Test.startTest();
            ContactOdsJson.replaceOneJSON(contactRecord);
        Test.stopTest();
    }
    @isTest    
    public static void replaceOneJSON_B(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account accountRecord = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
        Contact contactRecord = new Contact();
        contactRecord.Source__c = '	Web User';
        contactRecord.Address_Type__c = 'test address full';
        contactRecord.FaxID__c = '23746587234';
        contactRecord.Other_Email_ID__c = 'test@test.com.full';
        contactRecord.Verified__c = true;
        contactRecord.LastName = 'Testers Last Name';
        contactRecord.FirstName = 'Testers First Name';
        contactRecord.Email = 'testers@test.com';
        contactRecord.Phone = '9896495451';
        contactRecord.CreatedDate = System.now();
        contactRecord.MobilePhone = '8745122356';
        contactRecord.Contact_Type__c = 'Customer Service Contact'; 
        contactRecord.Responsibility_Type__c = 'SALES_SERVICE';
        contactRecord.MailingPostalCode = '110014';
        contactRecord.MailingCity = 'US';
        contactRecord.MailingCountry = 'US';
        contactRecord.mailingState = 'US';
        contactRecord.MailingStreet = 'Test';
        contactRecord.Fax = '8745122356'; 
        contactRecord.Address_Status__c = 'A';
        contactRecord.Source_ID__c = 'sdfd454sdfe4r';
        contactRecord.Title = 'MR';
        contactRecord.OtherPhoneID__c = '14547';
        contactRecord.OtherPhone = '2145878745';
        contactRecord.AccountId  = accountRecord.Id;
        contactRecord.Other_Email__c = 'test@test.com';
        contactRecord.EmailID__c  = 'sdfgdsfge';
        contactRecord.PhoneID__c  = 'fdgdfgggfgfgf';
        insert contactRecord;  
        List<Contact> con = KoozieUtility.getAllFieldValues('Contact', contactRecord.Id);
        Test.startTest();
            ContactOdsJson.replaceOneJSON(con[0]);
        Test.stopTest();
    }
}