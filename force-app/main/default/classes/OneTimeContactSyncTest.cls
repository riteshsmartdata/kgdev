/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-27-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-27-2023   Ritesh Kumar   Initial Version
**/

@isTest 
public class OneTimeContactSyncTest {
    public class RestMockError implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{  "EventResponse" : {    "EnterpriseEventID" : "185323667",    "EventBusinessID" : "1234567890",    "EventStatus" : "ERROR",    "EventErrorCode" : null,    "EventStatusMessage" : "SUCCESS",    "MustRetryFlag" : false,    "CustomerContacts" : {      "CustomerAccountNumber" : "3456",      "CustomerContact" : [ {        "ContactID" : "1656751",        "ContactFirstName" : "Roger",        "ContactLastName" : "Daltry",        "ContactStatus" : "A",        "JobTitle" : " ",        "ContactCreateDate" : "2020-06-26T18:29:16.000-05:00",        "ContactLastUpdateDate" : "2020-06-26T18:29:16.000-05:00",        "ResponsibilityType" : "SALES_SERVICE",        "ContactAddress" : {          "ContactAddresses" : [ {            "AddressID" : "5065333",            "AddressLine1" : "PO BOX 96042,,,",            "AddressLine2" : " ",            "AddressLine3" : " ",            "AddressLine4" : " ",            "County" : " ",            "City" : "PITTSBURGH",            "State" : "PA",            "Country" : "US",            "PostalCode" : "15226-0042",            "Status" : " "          } ]        },        "Communications" : {          "CommunicationArray" : [ {            "CommunicationID" : "23456789",            "CommunicationMethod" : "EMAIL",            "CommunicationInfo" : "jljsl@jkalf.com",            "QueueRouteNumber" : " ",            "ActiveFlag" : "A",            "PrimaryFlag" : "true"          }, {            "CommunicationID" : "1379945",            "CommunicationMethod" : "PHONE",            "CommunicationInfo" : "5465465",            "QueueRouteNumber" : " ",            "ActiveFlag" : "A",            "PrimaryFlag" : "false"          }, {            "CommunicationID" : "8797987987",            "CommunicationMethod" : "PHONE",            "CommunicationInfo" : "54564654",            "QueueRouteNumber" : " ",            "ActiveFlag" : "A",            "PrimaryFlag" : "false"          }, {            "CommunicationID" : "1379960",            "CommunicationMethod" : "FAX",            "CommunicationInfo" : "546465465",            "QueueRouteNumber" : " ",            "ActiveFlag" : "A",            "PrimaryFlag" : "false"          } ]        }      } ]    }  }}');
            res.setStatusCode(300);
            return res;
        }
    }
    @TestSetup
    static void makeData(){
        AppInfo__c ai = new AppInfo__c();
        ai.Name = 'Sandbox';
        ai.User__c = 'webclient';
        ai.Password__c = 'eh8q4ya4bvnx5';
        ai.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ai;
        Account accountRecord = TestData.createAccount(false);
        accountRecord.Name = 'Account Testing';
        accountRecord.Customer_Account_Number__c = '243434';
        insert accountRecord;
    }
    @isTest    
    public static void ContactSyncWithOdsTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Account Record Creation
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        // Contact Record Creation
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Last Name Testing';
        contactRecord.FirstName = 'First Name Testing';
        contactRecord.Email = 'testing@test.com';
        contactRecord.AccountId  = accountRecord.Id;
        insert contactRecord;
        Test.startTest();
            Database.executeBatch(new OneTimeContactSync(), 1);
        Test.stopTest();
    }
    @isTest
    public static void ContactSyncWithOdsTest2(){
        Test.setMock(HttpCalloutMock.class, new RestMockError());
        Account accountRecord = [SELECT Id FROM Account LIMIT 1];
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Last Name Testing';
        contactRecord.FirstName = 'First Name Testing';
        contactRecord.Email = 'testing@test.com';
        contactRecord.AccountId  = accountRecord.Id;
        insert contactRecord;
        Test.startTest();
            Database.executeBatch(new OneTimeContactSync(), 1);
        Test.stopTest();
    }
}