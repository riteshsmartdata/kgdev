@IsTest
private class GetclaimwebserviceTest {
    
    @TestSetup
    static void setupData() {
        // Create an Account for the test
        Account acc = new Account(Name = 'Test Account', Customer_Account_Number__c = '12345');
        insert acc;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact_Email__c = 'contact1@ebsorder.com'; 
        eo.Customer_Account_Number__c = '12345'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L1';
        eo.Quote_Number__c = 'QR-144031';
        eo.EBS_Order_Number__c = '27903373661';
        insert eo;
        
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Claims' LIMIT 1];
        
        // Create a Case record (Claim) with the necessary fields
        Case case1 = new Case(
            AccountId = acc.Id,
            RecordTypeId = rt.Id,
            PO_Number__c = 'PO12345',
            EBS_Order__c = eo.Id,
            Subject = 'Test Claim',
            Description = 'Test Description',
            Status = 'New',
            Comments = 'Test Comments'
        );
        insert case1;
    }
    
    @IsTest
    static void testHandleClaimRetrievalSuccess() { 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Prepare mock request data
        String requestBody = '{"EventRequest":{"EventBusinessID":"500637745","EventDateTime":"2024-11-25T14:26:49","EventObject":"Case","EventSourceSystem":"Website","RequestRecords":{"RequestRecord":[{"KeyName":"SalesOrder","KeyValue":"27903373661"},{"KeyName":"CustomerAccountNumber","KeyValue":"12345"},{"KeyName":"PaginationIndexNumber","KeyValue":"1"},{"KeyName":"RecordCount","KeyValue":"25"},{"KeyName":"ClaimStartDate","KeyValue":"null"},{"KeyName":"ClaimEndDateRange","KeyValue":"null"}]}}}';
        
        // Simulate a REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;        
        // Call the method
        Test.startTest();
        Getclaimwebservice.handleClaimRetrieval();
        Test.stopTest();
        
        // Validate the response
        String responseBody = res.responseBody.toString();
        System.assertEquals(200, res.statusCode);
        System.assert(responseBody.contains('"EventStatus":"SUCCESS"'), 'Expected success status in response');
    }
    
    @IsTest
    static void testHandleClaimRetrievalNoRecords() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Prepare mock request data with a non-existent ClaimID
        String requestBody = '{"EventRequest":{"EventBusinessID":"500637745","EventDateTime":"2024-11-25T14:26:49","EventObject":"Case","EventSourceSystem":"Website","RequestRecords":{"RequestRecord":[{"KeyName":"SalesOrder","KeyValue":"216596"},{"KeyName":"CustomerAccountNumber","KeyValue":"123648465"},{"KeyName":"PaginationIndexNumber","KeyValue":"1"},{"KeyName":"RecordCount","KeyValue":"25"},{"KeyName":"ClaimStartDate","KeyValue":"null"},{"KeyName":"ClaimEndDateRange","KeyValue":"null"}]}}}';
        
        // Simulate a REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        Getclaimwebservice.handleClaimRetrieval();
        Test.stopTest();
        
        // Validate the response
        String responseBody = res.responseBody.toString();
        System.assertEquals(200, res.statusCode);
        System.assert(responseBody.contains('"EventStatus":"SUCCESS"'), 'Expected success status even with no records');
        System.assert(responseBody.contains('"EventStatusMessage":"No records found."'), 'Expected no records message');
    }
    
    @IsTest
    static void testHandleClaimRetrievalError() {
        // Prepare mock request data with missing key fields to trigger an error
        String requestBody = '{}';
        
        // Simulate a REST request
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the method
        Test.startTest();
        Getclaimwebservice.handleClaimRetrieval();
        Test.stopTest();
        
        // Validate the response
        String responseBody = res.responseBody.toString();
        System.assertEquals(500, res.statusCode);
        System.assert(responseBody.contains('"EventStatus":"FAILURE"'), 'Expected failure status in response');
    }
}