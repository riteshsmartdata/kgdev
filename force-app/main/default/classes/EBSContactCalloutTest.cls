/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/

@IsTest
public with sharing class EBSContactCalloutTest {

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

    @TestSetup
    static void setup() {
        TestDataFactory.loadAppSetting();
    }

    @IsTest
    private static void sendContactData_TEST(){
        Account accountInfo  = TestDataFactory.createAccount('Test Account','0123645','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('AP', 'AP', accountInfo.Id, 'Finance Contact', TRUE);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        EBSContactCallout.sendContactData(contactInfo.Id,'CREATE');

        Test.stopTest();
        

    }

}