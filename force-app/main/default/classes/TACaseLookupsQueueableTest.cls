@IsTest
private class TACaseLookupsQueueableTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"rob.meier@kooziegroup.com.test", "EventStatus": "SUCCESS", "EventStatusMessage": "Successfully Completed", "CustomerData": { "SFId": "0035300000AgKZNAA3", "web_Id": "5c9e20578513d813ed6e5a43", "emailId": "rob.meier@kooziegroup.com.test" }}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    public static void makeData(){
        Account accountRecord =  TestData.createAccount(FALSE);
        accountRecord.Customer_Account_Number__c = '159753215';
        Insert accountRecord;

        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact contactRecord = TestData.createContact(FALSE,accountRecord.Id);
        contactRecord.email = 'FirstName@test.com';
        Insert contactRecord;

        EBS_Order__c orderRecord = TestData.createEBSOrder(FALSE);
        orderRecord.PO_Contact_Email__c = 'FirstName@test.com.full';
        orderRecord.Customer_Account_Number__c = '159753215';
        orderRecord.EBS_Order_Number__c = '363636565';
        Insert orderRecord;
        
        EBS_Order_Line__c orderLineRecord = TestData.createEBSOrderLine(false);
        orderLineRecord.Order__c = orderRecord.Id;
        Insert orderLineRecord;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Hotel';
        act.Account_Team__c = 'Team-A';
        insert act;
    }
    
    @IsTest
    static void testQueueableExecution() {

        // Fetch test data
        Account acc = [
            SELECT Id, Customer_Account_Number__c
            FROM Account
            LIMIT 1
        ];

        Contact con = [
            SELECT Id, Email
            FROM Contact
            LIMIT 1
        ];

        EBS_Order__c orderRec = [
            SELECT Id, EBS_Order_Number__c
            FROM EBS_Order__c
            LIMIT 1
        ];

        // Case record
        Case cs = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email',
            SuppliedEmail = con.Email,
            EBS_Account_Number__c = acc.Customer_Account_Number__c,
            EBS_Order_ID__c = orderRec.EBS_Order_Number__c,
            Clarification_Team__c = 'Team-A',
            Proof_Team__c = 'Team-A'
        );
        insert cs;

        // Prepare Queueable input
        Set<Id> caseIds = new Set<Id>{ cs.Id };

        Test.startTest();
            TACaseLookupsQueueable job =
                new TACaseLookupsQueueable(caseIds, 'Insert', 'AnyType');
            System.enqueueJob(job);
        Test.stopTest();

        // Verify updates
        Case updatedCase = [
            SELECT AccountId,
                   ContactId,
                   EBS_Order__c,
                   Clarification_Team_Link__c,
                   Proof_Team_Link__c
            FROM Case
            WHERE Id = :cs.Id
        ];

        System.assertNotEquals(
            null,
            updatedCase.AccountId,
            'Account should be linked'
        );

        System.assertNotEquals(
            null,
            updatedCase.ContactId,
            'Contact should be linked'
        );

        System.assertNotEquals(
            null,
            updatedCase.EBS_Order__c,
            'Order should be linked'
        );
    }

    @IsTest
    static void testEmptyCaseSet() { 

        Test.startTest();
            TACaseLookupsQueueable job =
                new TACaseLookupsQueueable(
                    new Set<Id>(),
                    'Insert',
                    'AnyType'
                );
            System.enqueueJob(job);
        Test.stopTest();

        // No exception = pass
        System.assert(true, 'Queueable handled empty input safely');
    }
}