/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 03-20-2024
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   03-15-2024   Ritesh Kumar   Initial Version
**/

@isTest
public class EBSContactResponseJSONTest {
    
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
    
    
    @isTest
    public static void parseJSONString_TEST() {
        
        Account accountInfo  = TestDataFactory.createAccount('Test Account','0123645','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('AP', 'AP', accountInfo.Id, 'Finance Contact', FALSE);
        contactInfo.Email = 'mary@pressworksprinting.com.full44';
        contactInfo.other_Email__c = 'mary@pressworksprinting.com.full44';
        contactInfo.Phone = '414-329-3540';
        contactInfo.OtherPhone = '414-329-3540';
        contactInfo.FAX = '414-329-3540';
        Insert contactInfo;
        
        String jsonInfo = '{"EventResponse":{"EnterpriseEventID":"420288776","EventBusinessID":"1234567890","EventStatus":"SUCCESS","EventErrorCode":null,"EventStatusMessage":"SUCCESS","MustRetryFlag":false,"CustomerContacts":{"CustomerAccountNumber":"745318","CustomerContact":[{"ContactID":"2630237","ContactFirstName":"AP","ContactLastName":"AP","ContactStatus":"A","JobTitle":" ","ContactCreateDate":"2022-07-28T16:27:39.000-05:00","ContactLastUpdateDate":"2024-03-20T04:42:41.000-05:00","ResponsibilityType":"INVOICE EMAIL","PrimaryResponsibilityFlag":"Y","ContactAddress":{"ContactAddresses":[{"AddressID":"7591877","AddressLine1":"10201 W OKLAHOMA AVE,,,","AddressLine2":" ","AddressLine3":" ","AddressLine4":" ","County":" ","City":"GREENFIELD","State":"WI","Country":"US","PostalCode":"53227","Status":" "}]},"Communications":{"CommunicationArray":[{"CommunicationID":"2022074","CommunicationMethod":"EMAIL","CommunicationInfo":"mary@pressworksprinting.com.full44","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"true"},{"CommunicationID":"2022074","CommunicationMethod":"EMAIL","CommunicationInfo":"mary@pressworksprinting.com.full44","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"true"},{"CommunicationID":"2022075","CommunicationMethod":"PHONE","CommunicationInfo":"414-329-3540","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"false"},{"CommunicationID":"2022075","CommunicationMethod":"PHONE","CommunicationInfo":"414-329-3540","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"false"},{"CommunicationID":"2022075","CommunicationMethod":"FAX","CommunicationInfo":"414-329-3540","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"false"}]}}]}}}';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Boolean isError = EBSContactResponseJSON.parseJSONString(jsonInfo, contactInfo.Id);
        System.assertEquals(FALSE , isError );
        Test.stopTest();
        
    }
    
}