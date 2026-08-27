/*
* @description       :  Test class for Last30ThDaySpecSampleEBSOrders_Batch
* @author            :  Vivekanand Kedar
* @group             :  DAMCO
* @created on        :  20/08/2025
* @last modified on  :
* @last modified by  : 
*/

@isTest
private class Last30ThDaySpecSample_Batch_Test {

    // Mock class for simulating successful HTTP callout
    private class IdentifySpecSampleEBSOrders_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @testSetup
    static void setupTestData() {

        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());
        
        // Create Account
        Account acc = new Account(Name = 'Test Customer Account');
        insert acc;

        // Create Contact
        Contact con = new Contact(
            LastName = 'Test Contact',
            Email = 'test.contact@test.com',
            Phone = '8877996655',
            AccountId = acc.Id
        );
        insert con;

        // SPEC SAMPLE order (created 30 days ago)
        EBS_Order__c sampleOrder = new EBS_Order__c(
            PO_Contact__c = con.Id,
            Account_Name__c = acc.Id,
            Order_Header_Status__c = 'Closed',
            Order_Header_Total__c = 100
        );
        insert sampleOrder;

        Test.setCreatedDate(sampleOrder.Id, DateTime.now().addDays(-30));

        // SPEC SAMPLE line
        // Add Product_Marketing_ID__c to both sample + normal order line
        EBS_Order_Line__c sampleOrderLine = new EBS_Order_Line__c(
            Order__c = sampleOrder.Id,
            Product_Name__c = 'PM123',
            Quantity__c = 5,
            Line_Type__c = 'SPEC SAMPLE',
            Line_Status__c = 'CLOSED',
            Sales_Agreement__c = null
        );
        insert sampleOrderLine;
        
        EBS_Order_Line__c normalOrderLine3 = new EBS_Order_Line__c(
            Order__c = sampleOrder.Id,
            Product_Name__c = 'PM123',
            Quantity__c = 5,
            Line_Type__c = 'Regular Line',
            Line_Status__c = 'new'
        );
        insert normalOrderLine3;

        // NON-SAMPLE order (within last 30 days)
        EBS_Order__c normalOrder = new EBS_Order__c(
            PO_Contact__c = con.Id,
            Account_Name__c = acc.Id,
            Order_Header_Status__c = 'Closed',
            Order_Header_Total__c = 500
        );
        insert normalOrder;

        Test.setCreatedDate(normalOrder.Id, DateTime.now().addDays(-5));

        EBS_Order_Line__c normalOrderLine = new EBS_Order_Line__c(
            Order__c = normalOrder.Id,
            Product_Name__c = 'PM123',
            Quantity__c = 5,
            Line_Type__c = 'Regular Line',
            Line_Status__c = 'CLOSED'
        );
        insert normalOrderLine;
        
        EBS_Order_Line__c normalOrderLine2 = new EBS_Order_Line__c(
            Order__c = normalOrder.Id,
            Product_Name__c = 'PM123',
            Quantity__c = 5,
            Line_Type__c = 'Regular Line',
            Line_Status__c = 'new'
        );
        insert normalOrderLine2;
    }

    @isTest
    static void testBatchExecution_MatchingOrders() {

        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());

        Test.startTest();
        Id batchId = Database.executeBatch(new Last30ThDaySpecSampleEBSOrders_Batch(), 1);
        Test.stopTest();

        // Assert that sample order got updated
        EBS_Order__c updatedSample = [
            SELECT Id, Exclude_From_30_Days_Spec_Sample__c, 
                   Exclude_From_60_Days_Spec_Sample__c, 
                   Order_From_Spec_Sample__c
            FROM EBS_Order__c
            WHERE Id IN (SELECT Order__c FROM EBS_Order_Line__c WHERE Line_Type__c LIKE '%SPEC SAMPLE%')
            LIMIT 1
        ];

        System.assertEquals(true, updatedSample.Exclude_From_30_Days_Spec_Sample__c,
            'Sample order should be excluded from 30 days');
        System.assertEquals(true, updatedSample.Exclude_From_60_Days_Spec_Sample__c,
            'Sample order should be excluded from 90 days');
        System.assertNotEquals(null, updatedSample.Order_From_Spec_Sample__c,
            'Sample order should link to matched regular order');
    }

    @isTest
    static void testBatchExecution_NoMatchingOrders() {
        // Delete all regular orders so only sample order remains
        delete [SELECT Id FROM EBS_Order__c 
                WHERE Id IN (SELECT Order__c FROM EBS_Order_Line__c WHERE Line_Type__c = 'Regular Line')];

        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());

        Test.startTest();
        Database.executeBatch(new Last30ThDaySpecSampleEBSOrders_Batch(), 1);
        Test.stopTest();

        // Sample order should NOT be updated
     /*   EBS_Order__c sampleOrder = [
            SELECT Exclude_From_30_Days_Spec_Sample__c, 
                   Exclude_From_90_Days_Spec_Sample__c, 
                   Order_From_Spec_Sample__c
            FROM EBS_Order__c
            WHERE Id IN (SELECT Order__c FROM EBS_Order_Line__c WHERE Line_Type__c LIKE '%SPEC SAMPLE%')
            LIMIT 1
        ];
        System.assertEquals(false, sampleOrder.Exclude_From_30_Days_Spec_Sample__c,
            'Sample order should not be flagged without matching order');
        System.assertEquals(false, sampleOrder.Exclude_From_90_Days_Spec_Sample__c,
            'Sample order should not be flagged without matching order');
        System.assertEquals(null, sampleOrder.Order_From_Spec_Sample__c,
            'Sample order should not link to any order without match');*/
    }

    @isTest
    static void testBatchExecution_InvalidOrderStatus() {
        // Update sample order status to OPEN
        EBS_Order__c sampleOrder = [
            SELECT Id FROM EBS_Order__c
            WHERE Id IN (SELECT Order__c FROM EBS_Order_Line__c WHERE Line_Type__c LIKE '%SPEC SAMPLE%')
            LIMIT 1
        ];
        sampleOrder.Order_Header_Status__c = 'OPEN';
        update sampleOrder;

        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());

        Test.startTest();
        Database.executeBatch(new Last30ThDaySpecSampleEBSOrders_Batch(), 1);
        Test.stopTest();

        // Assert sample order not updated
        sampleOrder = [
            SELECT Exclude_From_30_Days_Spec_Sample__c, 
                   Exclude_From_60_Days_Spec_Sample__c, 
                   Order_From_Spec_Sample__c
            FROM EBS_Order__c
            WHERE Id = :sampleOrder.Id
        ];
        System.assertEquals(false, sampleOrder.Exclude_From_30_Days_Spec_Sample__c,
            'Sample order should not be flagged when status is not CLOSED');
    }

    @isTest
    static void testSchedulable() {

        Test.setMock(HttpCalloutMock.class, new IdentifySpecSampleEBSOrders_Mock());

        Test.startTest();
        String cronExp = '0 0 12 * * ?';
        String jobId = System.schedule('Test_Schedulable_Batch', cronExp, new Last30ThDaySpecSampleEBSOrders_Batch());
        Test.stopTest();
        System.assertNotEquals(null, jobId, 'Scheduled job Id should not be null');
    }
}