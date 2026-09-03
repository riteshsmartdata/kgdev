@isTest
private class OpenContactCasesControllerTest {

    @testSetup
    static void setupData() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Create test account and contact
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, Email='test@gmail.com', Phone= '656445445');
        insert con;
        
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact_Email__c = 'contact1@ebsorder.com'; 
        eo.Customer_Account_Number__c = '1234567'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L1';
        eo.Quote_Number__c = 'QR-144031';
        eo.EBS_Order_Number__c = '27903373661';
        insert eo;

        // Create the "current" case (will be passed as recordId)
        Case mainCase = new Case(
            Subject = 'Main Case',
            Status = 'New',
            AccountId = acc.Id,
            ContactId = con.Id,
            EBS_Order__c = eo.Id
        );
        insert mainCase;

        // Add more open cases under same account and contact
        List<Case> otherCases = new List<Case>();
        for (Integer i = 0; i < 3; i++) {
            otherCases.add(new Case(
                Subject = 'Open Case ' + i,
                Status = 'In Progress',
                AccountId = acc.Id,
                ContactId = con.Id,
                Case_Reason_Type__c = 'General',
                PO_Number__c = 'PO-' + i,
                 EBS_Order__c = eo.Id
            ));
        }
        insert otherCases;

        // Case with different account (should not be returned)
        Account otherAcc = new Account(Name = 'Other Account');
        insert otherAcc;

        Case diffCase = new Case(
            Subject = 'Other Account Case',
            Status = 'New',
            AccountId = otherAcc.Id,
            ContactId = con.Id,
            EBS_Order__c = eo.Id
        );
        insert diffCase;
    }

    @isTest
    static void testGetOpenCasesWithValidAccount() {
        // Get the current case
        Case mainCase = [SELECT Id FROM Case WHERE Subject = 'Main Case' LIMIT 1];

        Test.startTest();
        List<Case> result = OpenContactCasesController.getOpenCases(mainCase.Id);
        Test.stopTest();

        System.assertEquals(4, result.size(), 'Should return 3 open cases with same AccountId and ContactId');
    }

    @isTest
    static void testGetOpenCasesWithNoAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact con = new Contact(FirstName = 'NoAccount', LastName = 'Contact', Email='test2@gmail.com', Phone= '6564454455');
        insert con;
        EBS_Order__c eo = [SELECT Id FROM EBS_Order__c LIMIT 1];
        

        Case noAccCase = new Case(
            Subject = 'No Account Case',
            Status = 'New',
            EBS_Order__c = eo.Id
        );
        Test.startTest();
        insert noAccCase;
        List<Case> result = OpenContactCasesController.getOpenCases(noAccCase.Id);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty list when AccountId is null');
    }
}