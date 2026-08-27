/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : Ritesh Kumar
**/
@isTest
public class GenerateContactJSONDataTest {
    
    @testSetUp
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
        Account newAccount = TestData.createAccount(false);
        newAccount.Name = 'Test Account';
        newAccount.Industry = 'Agriculture';
        newAccount.Territory__c = 'Test Terrioroty';
        newAccount.Status__c = 'Active';
        newAccount.Customer_Account_Number__c = '8708060525';
        insert newAccount;
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('Error : {Error:{ "data":"Testing error"}} ;; {"Error":"Error Test"}, 202\', \'003XXXXXX123');
            res.setStatusCode(202);
            return res;
        }
    }
    
    @isTest
    public static void GenerateContactJSON(){
        Contact con = new Contact();
        con.Phone = '9999999999';
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION'; 
        con.OtherPhone = '';
        con.Other_Email__c = '';
        con.EmailID__c = '';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = '';
        con.Verified__c = True;
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '';
        con.LastName = 'Graham';
        con.Fax = '';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = ''; 
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent'; 
        con.MobilePhone = '99999999999'; 
        con.Address_Status__c = '99999999999'; 
        con.LastModifiedDate = System.today();
        con.Title = 'Mr'; 
        con.CreatedDate = System.Today();
        con.OtherPhoneID__c = '';
        con.PhoneID__c = '';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = 'Mr'; 
        con.Source__c = 'Web User';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        con.Source_ID__c = '12323';
        insert con;
       Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();
            GenerateContactJSONData.insertOneContactJSON(con);
            GenerateContactJSONData.sendSingleContactInformation(GenerateContactJSONData.insertOneContactJSON(con), 'INSERT', con.Id);
            GenerateContactJSONData.generateJSONForSingleContactInsert(GenerateContactJSONData.insertOneContactJSON(con), 'INSERT', con.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void GenerateContactJSON2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Account> accountRecord = [SELECT Id FROM Account LIMIT 1];
        
        List<User> testUser = [SELECT Id,Name FROM User Where Name = 'Integration User'];
        Set<Id> setOfContactIds = new Set<Id>();
        
        Contact con = new Contact();
        con.Merged_Contact_ID__c = 'adshfgafgasd';
        con.Phone = '91-8708060525';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        con.PromoStandards_Contact__c = True;
        con.PrimaryOtherEmailFlag__c = True;
        con.Top_Producer__c = True;
        con.Responsibility_Type__c = 'CLARIFICATION'; 
        con.AccountId =accountRecord.get(0).Id; 
        con.OtherPhone = '7845124578';
        con.Other_Email__c = 'test@test.com';
        con.EmailID__c = '234234';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = '32423423';
        con.Verified__c = True;
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '23423423';
        con.LastName = 'Graham';
        con.Fax = '234234';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = 'type';  
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent';  
        con.MobilePhone = '99999999999'; 
        con.Address_Status__c = '99999999999'; 
        con.LastModifiedDate = System.today();
        con.Title = 'Mr'; 
        con.CreatedDate = System.Today();
        con.OtherPhoneID__c = '234234';
        con.PhoneID__c = '234234';
        con.HasOptedOutOfEmail = True;
        con.FirstName = 'Buller';
        con.Do_Not_Mail__c = True;
        con.Suffix = 'Mr'; 
        con.Source__c = 'Web User';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        con.OwnerId = testUser.get(0).Id;
        insert con;
        System.debug('Contact Territory__c TC::: '+ con.Territory__c);
        

        Set<String> fields = new Set<String>();
        fields.add('Phone');
        fields.add('LastName');
        fields.add('Contact_Status__c');
        fields.add('PhoneID__c');
        fields.add('Suffix');
        fields.add('Salutation');
        fields.add('FirstName');
        fields.add('OtherPhoneID__c');
        fields.add('Do_Not_Mail__c');
        fields.add('FirstName');
        fields.add('Email');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('CreatedDate');
        fields.add('Title');
        fields.add('Contact_Status__c');
        fields.add('Contact_Type__c');
        fields.add('Address_Type__c'); 
        fields.add('Top_Producer__c');
        fields.add('Responsibility_Type__c');
        fields.add('Account_Industry__c');
        fields.add('PrimaryEmailFlag__c');
        fields.add('MiddleName');
        fields.add('MailingPostalCode');
        fields.add('MailingStreet');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('Clean_Phone_Number__c');
        fields.add('RecordTypeId');
        fields.add('Id'); 
        fields.add('Clean_Phone_Number__c');
        fields.add('Contact_ID__c');
        fields.add('CreatedById');
        fields.add('Merged_Contact_ID__c');
        fields.add('LastModifiedById');
        fields.add('Contact_Account_Status__c');
        fields.add('Account_Number__c');
        fields.add('IsDeleted');
        fields.add('Territory__c');
        fields.add('Address_Status__c');
        fields.add('Source_ID__c');
        fields.add('OwnerId');
        fields.add('HasOptedOutOfEmail');
        fields.add('AccountId');
        fields.add('Source__c');
        List<Contact> contactRecord = KoozieUtility.getAllFieldValues('Contact', con.Id); // Get all the contact Fields so the formula fields are not null.

        Test.startTest();
            GenerateContactJSONData.insertOneContactJSON(contactRecord.get(0));
            GenerateContactJSONData.sendSingleContactInformation(GenerateContactJSONData.updateOneContactJSON(contactRecord.get(0), fields), 'UPDATE',contactRecord.get(0).Id);
            GenerateContactJSONData.generateJSONForSingleContactInsert(GenerateContactJSONData.updateOneContactJSON(contactRecord.get(0), fields), 'UPDATE',contactRecord.get(0).Id);
        Test.stopTest();
    }

    @isTest
    public static void GenerateContactJSON3(){
        
        Set<Id> setOfContactIds = new Set<Id>();
        
        Contact con = new Contact();
        con.Merged_Contact_ID__c = null;
        con.Phone = '9999999999';
        con.Responsibility_Type__c = 'CLARIFICATION';
        con.OtherPhone = '7845124578';
        con.Other_Email__c = 'test@test.com';
        con.EmailID__c = '234234';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = '32423423';
        con.Verified__c = True;
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '23423423';
        con.LastName = 'Graham';
        con.Fax = '234234';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = 'type';  
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent';  
        con.MobilePhone = '99999999999'; 
        con.Address_Status__c = '99999999999';  
        con.MiddleName = 'J';
        con.LastName = 'Graham';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        con.Email = 'test@testers.com';
        con.MobilePhone = '99999999999';
        con.FirstName = 'Buller';
        con.PrimaryPhoneFlag__c=true;
        con.LastModifiedDate = System.today();
        con.CreatedDate = System.today().addDays(-1);
        insert con;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Set<String> fields = new Set<String>();
        fields.add('Phone');
        fields.add('PromoStandards_Contact__c');
        fields.add('PrimaryOtherEmailFlag__c');
        fields.add('Top_Producer__c');
        fields.add('Account_Industry__c');
        fields.add('Other_Email__c');
        fields.add('OtherPhone');
        fields.add('PrimaryEmailFlag__c');
        fields.add('EmailID__c');
        fields.add('Date_Verified__c');
        fields.add('FaxID__c');
        fields.add('Verified__c');
        fields.add('MiddleName');
        fields.add('PrimaryFaxFlag__c');
        fields.add('MailingPostalCode');
        fields.add('MailingCity');
        fields.add('MailingCountry');
        fields.add('MailingState');
        fields.add('MailingStreet');
        fields.add('Other_Email_ID__c');
        fields.add('Account_Number__c');
        fields.add('LastName');
        fields.add('Contact_Status__c');
        fields.add('PhoneID__c');
        fields.add('Suffix');
        fields.add('Salutation');
        fields.add('FirstName');
        fields.add('OtherPhoneID__c');
        fields.add('MobilePhone');
        fields.add('Fax');
        fields.add('Email');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('Responsibility_Type__c');
        fields.add('Source__c');
        fields.add('PrimaryPhoneFlag__c');
        fields.add('LastModifiedDate');
        fields.add('CreatedDate');
        fields.add('Merged_Contact_ID__c');

        Test.startTest();
            GenerateContactJSONData.insertOneContactJSON(con);
            GenerateContactJSONData.sendSingleContactInformation(GenerateContactJSONData.updateOneContactJSON(con, fields), 'UPDATE',con.Id);
            GenerateContactJSONData.generateJSONForSingleContactInsert(GenerateContactJSONData.updateOneContactJSON(con, fields), 'UPDATE',con.Id);
        Test.stopTest();
    }

    @isTest
    private static void testScenario(){
        Set<Id> setOfContactIds = new Set<Id>();
        
        Contact con = new Contact();
        con.Title=null;
        con.Address_Status__c =null;
        con.Other_Email__c=null;
        con.FaxID__c=null;
        con.EmailID__c = null;
        con.MiddleName = null;
        con.MailingPostalCode = null;
        con.MailingCity = null;
        con.MailingCountry = null;
        con.MailingState = null;
        con.MailingStreet = null;
        con.Other_Email_ID__c = null;
        con.Fax = null;
        con.Address_Type__c = null;  
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent';  
        con.MobilePhone = null; 
        con.MiddleName = null;
        con.LastName = 'Graham';
        con.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        con.Email = 'test@testers.com.full';
        con.MobilePhone = null;
        con.FirstName = 'Buller';
        insert con;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Set<String> fields = new Set<String>();
        fields.add('AccountId');
        fields.add('Phone');
        fields.add('PromoStandards_Contact__c');
        fields.add('PrimaryOtherEmailFlag__c');
        fields.add('Top_Producer__c');
        fields.add('Account_Industry__c');
        fields.add('Other_Email__c');
        fields.add('OtherPhone');
        fields.add('PrimaryEmailFlag__c');
        fields.add('EmailID__c');
        fields.add('Date_Verified__c');
        fields.add('FaxID__c');
        fields.add('Verified__c');
        fields.add('MiddleName');
        fields.add('PrimaryFaxFlag__c');
        fields.add('MailingPostalCode');
        fields.add('MailingCity');
        fields.add('MailingCountry');
        fields.add('MailingState');
        fields.add('MailingStreet');
        fields.add('Other_Email_ID__c');
        fields.add('Account_Number__c');
        fields.add('LastName');
        fields.add('Contact_Status__c');
        fields.add('PhoneID__c');
        fields.add('Suffix');
        fields.add('Salutation');
        fields.add('FirstName');
        fields.add('OtherPhoneID__c');
        fields.add('MobilePhone');
        fields.add('Fax');
        fields.add('Email');
        fields.add('PrimaryOtherPhoneFlag__c');
        fields.add('Responsibility_Type__c');
        fields.add('Address_Status__c');
        fields.add('Title');
        fields.add('Source__c');
        fields.add('PrimaryPhoneFlag__c');
        fields.add('LastModifiedDate');
        
        Test.startTest();
            GenerateContactJSONData.insertOneContactJSON(con);
            GenerateContactJSONData.sendSingleContactInformation(GenerateContactJSONData.updateOneContactJSON(con, fields), 'UPDATE',con.Id);
            GenerateContactJSONData.generateJSONForSingleContactInsert(GenerateContactJSONData.updateOneContactJSON(con, fields), 'UPDATE',con.Id);
        Test.stopTest();
    }
}