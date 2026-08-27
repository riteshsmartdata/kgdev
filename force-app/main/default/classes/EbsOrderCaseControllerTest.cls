@isTest
private class EbsOrderCaseControllerTest {
    @testSetup
    static void setupData() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Claims' LIMIT 1];
        
        Account acc = new Account(Name = 'Test Account', Customer_Account_Number__c = '12345');
        insert acc;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create mock data for the test cases
        List<Case> caseList = new List<Case>();
        
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact_Email__c = 'contact1@ebsorder.com'; 
        eo.Customer_Account_Number__c = '1234567'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L1';
        eo.Quote_Number__c = 'QR-144031';
        eo.EBS_Order_Number__c = '27903373661';
        insert eo;
        
        // Create a case that will be queried
        Case case1 = new Case(
            Subject = 'Test Case 1',
            Status = 'New',
            Priority = 'High',
            EBS_Order__c = eo.Id,
            RecordTypeId = rt.Id,
            Resolution_Note__c = 'test'
        );
        caseList.add(case1);
        
        // Create related cases with the same EBS_Order__c
        Case case2 = new Case(
            Subject = 'Related Case 1',
            Status = 'Working',
            Priority = 'Medium',
            EBS_Order__c = eo.Id,
            RecordTypeId = rt.Id,
            Resolution_Note__c = 'test'
        );
        caseList.add(case2);
        
        Case case3 = new Case(
            Subject = 'Related Case 2',
            Status = 'Closed',
            Priority = 'Low',
            EBS_Order__c = eo.Id,
            RecordTypeId = rt.Id,
            Resolution_Note__c = 'test'
        );
        caseList.add(case3);
        
        // Insert the test cases
        insert caseList;
    }
    
    @isTest
    static void testGetCasesForEbsOrder() {
        // Fetch a case to use its Id for the method call
        Case testCase = [SELECT Id, EBS_Order__c FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Call the method and verify the returned results
        Test.startTest();
        List<Case> relatedCases = EbsOrderCaseController.getCasesForEbsOrder(testCase.Id);
        Test.stopTest();
        
        // Verify that the related cases were returned
        System.assertEquals(2, relatedCases.size(), 'Expected to find 2 related cases');
        
        // Verify specific details of the returned cases
        Set<String> expectedSubjects = new Set<String>{'Test Case 1', 'Related Case 1', 'Related Case 2'};
            for (Case c : relatedCases) {
                System.assert(expectedSubjects.contains(c.Subject), 'Unexpected case returned: ' + c.Subject);
            }
    }
    
    @isTest
    static void testGetCasesForEbsOrderWithException() {
        // Call the method with an invalid ID to simulate an exception
        Test.startTest();
        List<Case> relatedCases = EbsOrderCaseController.getCasesForEbsOrder(null);
        Test.stopTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Verify that no cases are returned due to the exception
        System.assertEquals(0, relatedCases.Size(), 'Expected no cases due to exception handling');
    }
}