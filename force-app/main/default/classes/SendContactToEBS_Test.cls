/*
* @description       : Test Class for SendContactToEBS,EBSConatctCallout,EBSContactRequest
* @author            : Anubhav Saxena
* @group             : DAMCO TEAM
* @created on        : 29-03-2024
* @last modified on  :
* @last modified by  : Anubhav Saxena
*/
@isTest
public with sharing class SendContactToEBS_Test {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"EventResponse":{"EnterpriseEventID":"415336316","EventBusinessID":"1234567890","EventStatus":"SUCCESS","EventErrorCode":null,"EventStatusMessage":"SUCCESS","MustRetryFlag":false,"CustomerContacts":{"CustomerAccountNumber":"745318","CustomerContact":[{"ContactID":"2630237","ContactFirstName":"AP","ContactLastName":"AP","ContactStatus":"A","JobTitle":" ","ContactCreateDate":"2022-07-28T16:27:39.000-05:00","ContactLastUpdateDate":"2024-03-20T04:42:41.000-05:00","ResponsibilityType":"INVOICE EMAIL","PrimaryResponsibilityFlag":"Y","ContactAddress":{"ContactAddresses":[{"AddressID":"7591877","AddressLine1":"10201 W OKLAHOMA AVE,,,","AddressLine2":" ","AddressLine3":" ","AddressLine4":" ","County":" ","City":"GREENFIELD","State":"WI","Country":"US","PostalCode":"53227","Status":" "}]},"Communications":{"CommunicationArray":[{"CommunicationID":"2022074","CommunicationMethod":"EMAIL","CommunicationInfo":"mary@pressworksprinting.com.full44","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"true"},{"CommunicationID":"2022075","CommunicationMethod":"PHONE","CommunicationInfo":"414-329-3540","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"false"}]}}]}}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private static Id getCrmContactRtId() {
    return Schema.SObjectType.Contact
        .getRecordTypeInfosByName()
        .get('CRM Contact')
        .getRecordTypeId();
}
    @isTest
    private static void websiteSync_afterInsert() {
        
        Account acc = TestDataFactory.createAccount(
            'Website Acc','WEB001','Customers',TRUE
        );
        
        Contact c = new Contact(
            FirstName = 'Web',
            LastName = 'User',
            AccountId = acc.Id,
            RecordTypeId = getCrmContactRtId(),
            Email = 'web@test.com'
        );
        
        Test.startTest();
        insert c;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
    }
    @isTest
    private static void websiteSync_afterUpdate() {
        
        Account acc = TestDataFactory.createAccount(
            'Website Acc 2','WEB002','Customers',TRUE
        );
        
        Contact c = new Contact(
            FirstName = 'Web',
            LastName = 'User',
            AccountId = acc.Id,
            RecordTypeId = getCrmContactRtId(),
            Email = 'web@test.com'
        );
        insert c;
        
        Test.startTest();
        c.Email = 'webchanged@test.com'; // detectable diff
        update c;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
    }
    @isTest
    private static void websiteSync_noDiff() {
        
        Account acc = TestDataFactory.createAccount(
            'Website Acc 3','WEB003','Customers',TRUE
        );
        
        Contact c = new Contact(
            FirstName = 'Web',
            LastName = 'User',
            AccountId = acc.Id,
            RecordTypeId = getCrmContactRtId(),
            Email = 'same@test.com'
        );
        insert c;
        
        Test.startTest();
        update c; // no field change
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.stopTest();
    }
@isTest
private static void sendContact_beforeAfterDelete() {

    Account acc = TestDataFactory.createAccount(
        'Delete Test Acc','DEL001','Customers',TRUE
    );

    // NOT a Finance Contact
    Contact c = new Contact(
        FirstName = 'Del',
        LastName = 'User',
        AccountId = acc.Id,
        RecordTypeId = Schema.SObjectType.Contact
            .getRecordTypeInfosByName()
            .get('CRM Contact')
            .getRecordTypeId(),
        Email = 'delete@test.com'
    );
    insert c;

    // Extra safety (optional but good)
    KoozieUtility.isRecursion = false;

    Test.startTest();
    delete c;
    Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.stopTest();
}
@isTest
private static void sendContact_directDeleteMethodCoverage() {

    // Prepare dummy trigger context lists
    List<Contact> newList = new List<Contact>();
    List<Contact> oldList = new List<Contact>();

    // Create handler instance
    SendContactToEBS handler = new SendContactToEBS('SendContactToEBS');

    Test.startTest();
    handler.beforeDelete();
    handler.afterDelete();
	Test.setMock(HttpCalloutMock.class, new RestMock());
    Test.stopTest();
}


    
    @TestSetup
    static void setup() {
      	TestDataFactory.loadAppSetting(); 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountInfo  = TestDataFactory.createAccount('Test Account','0123645','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('AP', 'AP', accountInfo.Id, 'Finance Contact', TRUE); 
    }  
    
    @isTest
    private static void sendContactTestAfterInsert(){
        Account accountInfo  = TestDataFactory.createAccount('Test Account','01236415','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('AP', 'AP', accountInfo.Id, 'Finance Contact', FALSE);
        contactInfo.Email = 'mary@pressworksprinting.com.full44';
        contactInfo.other_Email__c = 'mary@pressworksprinting.com.full44';
        contactInfo.Phone = '414-329-3540';
        contactInfo.OtherPhone = '414-329-3540';
        contactInfo.Contact_Status__c = 'Inactive';
        contactInfo.FAX = '414-329-3540'; 
        contactInfo.Contact_ID__c = '12312312';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Insert contactInfo;
        System.debug('=====  Contact_ID__c====='+contactInfo.Contact_ID__c);
        
        Test.stopTest();
    }
    private static void sendContactTestAfterInsert_NoContactId(){
        Account accountInfo  = TestDataFactory.createAccount('Test Account','01236415','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('AP', 'AP', accountInfo.Id, 'Finance Contact', FALSE);
        contactInfo.Email = 'mary@pressworksprinting.com.full44';
        contactInfo.other_Email__c = 'mary@pressworksprinting.com.full44';
        contactInfo.Phone = '414-329-3540';
        contactInfo.OtherPhone = '414-329-3540';
        contactInfo.Contact_Status__c = 'Inactive';
        contactInfo.FAX = '414-329-3540'; 
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Insert contactInfo;
        
        Test.stopTest();
    }
    
    @isTest
    private static void sendContactTestAfterUpdate(){
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        
        record.Email = 'mary@pressworksprinting.com.full44';
        record.other_Email__c = 'mary@pressworksprinting.com.full44';
        record.Phone = '414-329-3540';
        record.OtherPhone = '414-329-3540';
        record.FAX = '414-329-3540';
        record.Contact_Status__c = 'Active';
        Update record;
        System.debug('=====  Contact_ID__c====='+record.Contact_ID__c);
        
        Test.stopTest();
    }
    @isTest
    private static void sendContactTestAfterUpdate_Other_Email(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        record.other_Email__c = 'marychange@pressworksprinting.com.full45';
        record.Phone = '414-329-3540';
        record.OtherPhone = '414-329-3540';
        record.FAX = '414-329-3540';
        record.Contact_Status__c = 'Active';
        Update record;
        System.debug('=====  Contact_ID__c====='+record.Contact_ID__c);
        
        Test.stopTest();
    }
    @isTest
    private static void sendContactTestAfterUpdate_Phone(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        record.Phone = '414-222-3540';
        Update record;
        System.debug('=====  Contact_ID__c====='+record.Contact_ID__c);
        
        Test.stopTest();
    }
    @isTest
    private static void sendContactTestAfterUpdate_fax(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        record.fax = '414-222-3540';
        Update record;
        System.debug('=====  Contact_ID__c====='+record.Contact_ID__c);
        
        Test.stopTest();
    }
    @isTest
    private static void sendContactTestAfterUpdate_Other_Phone(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        record.OtherPhone = '414-999-3540';
        Update record;
        Test.stopTest();
    }
    @isTest
    private static void sendContactTestAfterUpdate_Status(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact  
            LIMIT 1
        ];
        record.Contact_Status__c = 'Active';
        Update record;
        
        Test.stopTest();
    }
}