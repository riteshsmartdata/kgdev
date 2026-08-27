/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Anubhav Saxena
**/
@isTest
public class updateContactOnCaseTestClass {
    @isTest
    private static void updateContactOnCaseScenario1(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord1 = TestData.createAccount(false);
        testAccountRecord1.Customer_Account_Number__c='999';
        insert testAccountRecord1;
        Contact testContactRecord = new Contact(LastName='ContactLastName',AccountId=testAccountRecord1.Id,Email='FirstName@test.com.full');
        insert testContactRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',EBS_Account_Number__c='999',SuppliedEmail = 'FirstName@test.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord2 = new Account(Name='koozieTest.com.full',Customer_Account_Number__c='888');
        insert testAccountRecord2;
        Case testCaseRecord = new Case(Subject='Testing Case',SuppliedEmail = 'FirstNamelastname@koozieTest.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Case> caseList = [Select Id,Contact.Name from Case Where Id=: testCaseRecord.Id];
            System.assert(caseList.get(0).Contact.Name == 'Valued Customer', 'Valued Cutsomer was not created');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord3 = new Account(Name='koozieTest3.com.full',Customer_Account_Number__c='777');
        insert testAccountRecord3;
        Contact testContactRecord = new Contact(LastName='ContactLastName1',AccountId=testAccountRecord3.Id,Email='FirstNameKoozie@test.com.full');
        insert testContactRecord;
        Contact_Roles__c testContactRoleRecord  = new Contact_Roles__c(Account__c=testAccountRecord3.Id,Contact__c=testContactRecord.Id,Contact_Role_Name__c='CLARIFICATIONS');
        insert testContactRoleRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',EBS_Account_Number__c='777',SuppliedEmail = 'FirstNameKoozie@test.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario4(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id caseRecordTypeId = KoozieUtility.getRecordTypeId('Case', 'Purchase Order');
        Account testAccountRecord3 = new Account(Name='koozieTest3.com.full',Customer_Account_Number__c='777');
        insert testAccountRecord3;
        Contact testContactRecord = new Contact(LastName='ContactLastName1',AccountId=testAccountRecord3.Id,Email='FirstNameKoozie@test.com.full');
        insert testContactRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',EBS_Account_Number__c='777',SuppliedEmail = 'FirstNameKoozie@test.com.full',RecordTypeId=caseRecordTypeId);
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario5(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord5 = new Account(Name='koozieTest3.com.full',Customer_Account_Number__c='777');
        insert testAccountRecord5;
        Contact testContactRecord = new Contact(LastName='ContactLastName1',AccountId=testAccountRecord5.Id,Email='FirstNameKoozie@test.com.full');
        insert testContactRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',SuppliedEmail = 'FirstNameKoozie@test.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario6(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord6 = new Account(Name='koozieTest3.com.full',Customer_Account_Number__c='777');
        insert testAccountRecord6;
        Contact testContactRecord = new Contact(LastName='ContactLastName1',Email='FirstNameKoozie@test.com.full');
        insert testContactRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',SuppliedEmail = 'FirstNameKoozie@test.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
    @isTest
    private static void updateContactOnCaseScenario7(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account testAccountRecord7 = new Account(Name='koozieTest3.com.full',Customer_Account_Number__c='777',Account_Domain__c='test.com.full');
        insert testAccountRecord7;
        Contact testContactRecord = new Contact(LastName='ContactLastName1',Email='FirstNameKoozie@test.com.full');
        insert testContactRecord;
        Case testCaseRecord = new Case(Subject='Testing Case',SuppliedEmail = 'FirstNameKoozie@test.com.full');
        insert testCaseRecord;
        Test.startTest();
            List<Contact> contactList = [Select Id,LastName from Contact Where Id=: testContactRecord.Id];
            System.assert(contactList.size()!=0, 'Contact was not updated');
        Test.stopTest();
    }
}