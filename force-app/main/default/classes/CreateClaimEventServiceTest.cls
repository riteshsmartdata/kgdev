@isTest
private class CreateClaimEventServiceTest {
    
    
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
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
    }
    
    // Helper method to create sample Account and EBS Order records for testing
    private static Account createSampleAccount(String accountNumber) {
        Account account = new Account(
            Name = 'Test Account',
            Customer_Account_Number__c = accountNumber
        );
        insert account;
        return account;
    }
    
    private static EBS_Order__c createSampleEBSOrder(String salesOrder) {
        EBS_Order__c ebsOrder = new EBS_Order__c(
            EBS_Order_Number__c = salesOrder
        );
        insert ebsOrder;
        return ebsOrder;
    }
    
    
    
    // Test method for the successful creation of a claim
    @isTest
    static void testHandleClaimEventSuccess() {
        // Create test data
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account account = createSampleAccount('123456');
        EBS_Order__c ebsOrder = createSampleEBSOrder('SO123');
        // Prepare the input request JSON string
        String requestBody = '{"EventRequest":{"EventBusinessID":"SO123","EventDateTime":"2024-10-30T15:36:13","EventObject":"CLAIMS","EventSourceSystem":"Website","SFClaimData":{"AccountNo":"123456","SalesOrder":"SO123","Subject":"Sample Claim Subject","WebsiteDescription":"Test Description","Comment":"Test Comments","ContactID":"null","WebClaim":true,"ResolutionNote":"Test Resolution Note","attachments":[{"filename":"67615d3173452e319b0c14f1.pdf","fileType":".pdf","fileurl":"https://uat-blobstorage.kooziegroup.com/kgorderpdf/67615d3173452e319b0c14f1.pdf"},{"filename":"Zorch_Product_Template_04Jul20245216.pdf","fileType":".pdf","fileurl":"https://uat-blobstorage.kooziegroup.com/kgzorchfiles/Zorch_Product_Template_04Jul20245216.pdf"}]}}}';
        
        // Set up the mock REST request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateCaseClaims';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method under test
        ClaimResponse response = CreateClaimEventService.handleClaimEvent(); 
      
        Test.stopTest();
    }
    
    // Test method for a failed claim creation due to invalid AccountNo
    @isTest
    static void testHandleClaimEventAccountNotFound() {
        // Prepare the input request JSON string with an invalid AccountNo
        String requestBody = '{"EventRequest": {' +
                                '"EventObject": "ClaimCreated",' +
                                '"EventDateTime": "2024-12-09T12:00:00Z",' +
                                '"EventSourceSystem": "Web",' +
                                '"EventBusinessID": "Event123",' +
                                '"SFClaimData": {' +
                                    '"AccountNo": "12g3456",' + // Invalid AccountNo
                                    '"SalesOrder": "SO123",' +
                                    '"Subject": "Sample Claim Subject",' +
                                    '"WebsiteDescription": "Sample Description",' +
                                    '"Comment": "Test Comment",' +
                                    '"ContactID": "0036A00000AAABB",' +
                                    '"WebClaim": true,' +
                                    '"ResolutionNote": "Sample Resolution Note"' +
                                '}}}';
        
        // Set up the mock REST request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateCaseClaims';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
         Test.setMock(HttpCalloutMock.class, new RestMock());
        // Call the method under test
        ClaimResponse response = CreateClaimEventService.handleClaimEvent();
        
        // Validate the response for an error due to AccountNotFound
        System.assertEquals('ERROR', response.EventResponse.EventStatus);
        System.assert(response.EventResponse.EventStatusMessage.contains('Account not found for AccountNo'));
        
        Test.stopTest();
    }
    
    // Test method for a failed claim creation due to invalid SalesOrder
    @isTest
    static void testHandleClaimEventSalesOrderNotFound() {
        // Create a valid account
         Test.setMock(HttpCalloutMock.class, new RestMock());
        Account account = createSampleAccount('123456');
        
        // Prepare the input request JSON string with an invalid SalesOrder
        String requestBody = '{"EventRequest": {' +
                                '"EventObject": "ClaimCreated",' +
                                '"EventDateTime": "2024-12-09T12:00:00Z",' +
                                '"EventSourceSystem": "Web",' +
                                '"EventBusinessID": "Event123",' +
                                '"SFClaimData": {' +
                                    '"AccountNo": "123456",' +
                                    '"SalesOrder": "INVALID_SALES_ORDER",' + // Invalid SalesOrder
                                    '"Subject": "Sample Claim Subject",' +
                                    '"WebsiteDescription": "Sample Description",' +
                                    '"Comment": "Test Comment",' +
                                    '"ContactID": "0036A00000AAABB",' +
                                    '"WebClaim": true,' +
                                    '"ResolutionNote": "Sample Resolution Note"' +
                                '}}}';
        
        // Set up the mock REST request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateCaseClaims';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method under test
        ClaimResponse response = CreateClaimEventService.handleClaimEvent();
        
        // Validate the response for an error due to SalesOrderNotFound
        System.assertEquals('ERROR', response.EventResponse.EventStatus);
        System.assert(response.EventResponse.EventStatusMessage.contains('EBS Order not found for SalesOrder'));
        
        Test.stopTest();
    }
    
    // Test method for invalid JSON format
    @isTest
    static void testHandleClaimEventInvalidJson() {
        // Prepare an invalid JSON string
        String requestBody = '{"EventRequest": {' +
                                '"EventObject": "ClaimCreated",' +
                                '"EventDateTime": "2024-12-09T12:00:00Z",' +
                                '"EventSourceSystem": "Web",' +
                                '"EventBusinessID": "Event123"'; // Missing closing braces
                                
        // Set up the mock REST request and response
        Test.startTest();
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/CreateCaseClaims';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method under test
        ClaimResponse response = CreateClaimEventService.handleClaimEvent();
        
        // Validate the response for an error due to invalid JSON
        System.assertEquals('ERROR', response.EventResponse.EventStatus);
        System.assert(response.EventResponse.EventStatusMessage.contains('Invalid JSON input'));
        
        Test.stopTest();
    }
}