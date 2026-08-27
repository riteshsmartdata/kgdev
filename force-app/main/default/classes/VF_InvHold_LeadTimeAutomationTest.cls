/**
 * @description Comprehensive test class for VF_InvHold_LeadTimeAutomation
 * @author Agentforce
 * @date 2026-06-05
 * @coverage Target: 90%+
 */
@isTest
private class VF_InvHold_LeadTimeAutomationTest {
    
    /**
     * @description Creates a test EBS Order
     * @return Id of created order
     */
    private static Id createEBSOrder() {
        EBS_Order__c order = new EBS_Order__c();
        insert order;
        return order.Id;
    }
    
    /**
     * @description Creates EBS Order Lines with specified status
     * @param orderId The parent order Id
     * @param status The TOV_Line_Status__c value
     * @param count Number of records to create
     * @return List of created order lines
     */
    private static List<EBS_Order_Line__c> createEBSOrderLines(
        Id orderId, 
        String status, 
        Integer count
    ) {
        List<EBS_Order_Line__c> orderLines = new List<EBS_Order_Line__c>();
        
        for (Integer i = 0; i < count; i++) {
            orderLines.add(new EBS_Order_Line__c(
                Order__c = orderId,
                TOV_Line_Status__c = status,
                Quantity__c = 10 + i,
                External_Product_Name__c = 'Test Product ' + i,
                Scheduled_Ship_Date__c = Date.today().addDays(i),
                Ship_Method__c = 'Ground',
                Product_Number__c = 'PROD-' + String.valueOf(1000 + i),
                Estimated_Arrival_Date__c = Date.today().addDays(7 + i),
                Product_Color__c = 'Blue'
            ));
        }
        
        insert orderLines;
        return orderLines;
    }
    
    /**
     * @description Test getEBSOrderLines with In Production status lines
     * Verifies that only In Production lines are returned
     */
    @isTest
    static void testGetEBSOrderLines_InProductionStatus() {
        // Arrange
        Id testOrderId = createEBSOrder();
        Integer inProductionLineCount = 5;
        List<EBS_Order_Line__c> inProductionLines = createEBSOrderLines(
            testOrderId, 
            'In Production', 
            inProductionLineCount
        );
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            inProductionLineCount, 
            result.size(), 
            'Should return all In Production status lines'
        );
        
        // Verify fields are populated (Order__c not queried by controller)
        for (EBS_Order_Line__c line : result) {
            System.assertNotEquals(null, line.Quantity__c, 'Quantity should be populated');
            System.assertNotEquals(null, line.External_Product_Name__c, 'Product name should be populated');
            System.assertNotEquals(null, line.Product_Number__c, 'Product number should be populated');
        }
    }
    
    /**
     * @description Test getEBSOrderLines with mixed statuses
     * Verifies that only In Production lines are returned, others excluded
     */
    @isTest
    static void testGetEBSOrderLines_MixedStatuses() {
        // Arrange
        Id testOrderId = createEBSOrder();
        
        // Create lines with different statuses
        List<EBS_Order_Line__c> inProductionLines = createEBSOrderLines(
            testOrderId, 
            'In Production', 
            3
        );
        List<EBS_Order_Line__c> completeLines = createEBSOrderLines(
            testOrderId, 
            'COMPLETE', 
            2
        );
        List<EBS_Order_Line__c> pendingLines = createEBSOrderLines(
            testOrderId, 
            'PENDING', 
            2
        );
        List<EBS_Order_Line__c> cancelledLines = createEBSOrderLines(
            testOrderId, 
            'CANCELLED', 
            2
        );
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            3, 
            result.size(), 
            'Should return only In Production status lines, excluding other statuses'
        );
        
        // Verify no other status lines in result
        Set<Id> resultIds = new Set<Id>();
        for (EBS_Order_Line__c line : result) {
            resultIds.add(line.Id);
        }
        
        for (EBS_Order_Line__c completeLine : completeLines) {
            System.assert(
                !resultIds.contains(completeLine.Id), 
                'COMPLETE lines should not be included'
            );
        }
        
        for (EBS_Order_Line__c pendingLine : pendingLines) {
            System.assert(
                !resultIds.contains(pendingLine.Id), 
                'PENDING lines should not be included'
            );
        }
        
        for (EBS_Order_Line__c cancelledLine : cancelledLines) {
            System.assert(
                !resultIds.contains(cancelledLine.Id), 
                'CANCELLED lines should not be included'
            );
        }
    }
    
    /**
     * @description Test getEBSOrderLines with no In Production lines
     * Verifies empty list is returned when no In Production lines exist
     */
    @isTest
    static void testGetEBSOrderLines_NoInProductionLines() {
        // Arrange
        Id testOrderId = createEBSOrder();
        
        // Create only non-In Production lines
        List<EBS_Order_Line__c> completeLines = createEBSOrderLines(
            testOrderId, 
            'COMPLETE', 
            3
        );
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            0, 
            result.size(), 
            'Should return empty list when no In Production lines exist'
        );
        System.assertNotEquals(
            null, 
            result, 
            'Result should not be null, but an empty list'
        );
    }
    
    /**
     * @description Test getEBSOrderLines with no order lines at all
     * Verifies empty list is returned for order with no lines
     */
    @isTest
    static void testGetEBSOrderLines_NoOrderLines() {
        // Arrange
        Id testOrderId = createEBSOrder();
        // No order lines created
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            0, 
            result.size(), 
            'Should return empty list when no order lines exist'
        );
        System.assertNotEquals(
            null, 
            result, 
            'Result should not be null, but an empty list'
        );
    }
    
    /**
     * @description Test getEBSOrderLines with null orderId
     * Verifies behavior when orderId is not set
     */
    @isTest
    static void testGetEBSOrderLines_NullOrderId() {
        // Arrange
        // orderId not set (remains null)
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = null;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            0, 
            result.size(), 
            'Should return empty list when orderId is null'
        );
    }
    
    /**
     * @description Test orderId property getter and setter
     * Verifies static property can be set and retrieved
     */
    @isTest
    static void testOrderIdProperty() {
        // Arrange
        Id testOrderId = createEBSOrder();
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        Id retrievedId = VF_InvHold_LeadTimeAutomation.orderId;
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            testOrderId, 
            retrievedId, 
            'OrderId property should store and return the correct value'
        );
    }
    
    /**
     * @description Test getEBSOrderLines with multiple orders
     * Verifies that only lines from the specified order are returned
     */
    @isTest
    static void testGetEBSOrderLines_MultipleOrders() {
        // Arrange
        Id testOrderId1 = createEBSOrder();
        Id testOrderId2 = createEBSOrder();
        
        // Create lines for both orders
        List<EBS_Order_Line__c> order1Lines = createEBSOrderLines(
            testOrderId1, 
            'In Production', 
            3
        );
        List<EBS_Order_Line__c> order2Lines = createEBSOrderLines(
            testOrderId2, 
            'In Production', 
            4
        );
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId1;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            3, 
            result.size(), 
            'Should return only lines from the specified order'
        );
        
        // Result count verified above - Order__c field not queried by controller
    }
    
    /**
     * @description Bulk test with 251+ records
     * Verifies the controller handles large data volumes efficiently
     */
    @isTest
    static void testGetEBSOrderLines_BulkRecords() {
        // Arrange
        Id testOrderId = createEBSOrder();
        Integer bulkCount = 251;
        
        // Create bulk In Production lines
        List<EBS_Order_Line__c> bulkInProductionLines = createEBSOrderLines(
            testOrderId, 
            'In Production', 
            bulkCount
        );
        
        // Create bulk non-In Production lines to test filtering
        List<EBS_Order_Line__c> bulkCompleteLines = createEBSOrderLines(
            testOrderId, 
            'COMPLETE', 
            100
        );
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            bulkCount, 
            result.size(), 
            'Should return all 251 In Production lines, excluding COMPLETE lines'
        );
        
        // Verify all results have fields populated (Order__c not queried by controller)
        for (EBS_Order_Line__c line : result) {
            System.assertNotEquals(
                null, 
                line.Quantity__c, 
                'Quantity should be populated for all records'
            );
        }
    }
    
    /**
     * @description Test field population in query results
     * Verifies all fields in SELECT clause are accessible
     */
    @isTest
    static void testGetEBSOrderLines_FieldPopulation() {
        // Arrange
        Id testOrderId = createEBSOrder();
        Date testShipDate = Date.today().addDays(5);
        Date testArrivalDate = Date.today().addDays(10);
        
        EBS_Order_Line__c testLine = new EBS_Order_Line__c(
            Order__c = testOrderId,
            TOV_Line_Status__c = 'In Production',
            Quantity__c = 25,
            External_Product_Name__c = 'Premium Widget',
            Scheduled_Ship_Date__c = testShipDate,
            Ship_Method__c = 'Express',
            Product_Number__c = 'WIDGET-9999',
            Estimated_Arrival_Date__c = testArrivalDate,
            Product_Color__c = 'Red'
        );
        insert testLine;
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, result.size(), 'Should return one line');
        
        EBS_Order_Line__c returnedLine = result[0];
        System.assertEquals(25, returnedLine.Quantity__c, 'Quantity should match');
        System.assertEquals('Premium Widget', returnedLine.External_Product_Name__c, 'Product name should match');
        System.assertEquals(testShipDate, returnedLine.Scheduled_Ship_Date__c, 'Ship date should match');
        System.assertEquals('Express', returnedLine.Ship_Method__c, 'Ship method should match');
        System.assertEquals('WIDGET-9999', returnedLine.Product_Number__c, 'Product number should match');
        System.assertEquals(testArrivalDate, returnedLine.Estimated_Arrival_Date__c, 'Arrival date should match');
        System.assertEquals('Red', returnedLine.Product_Color__c, 'Product color should match');
    }
    
    /**
     * @description Test with different status values
     * Verifies only In Production lines are returned, excluding other statuses
     */
    @isTest
    static void testGetEBSOrderLines_DifferentStatusValues() {
        // Arrange
        Id testOrderId = createEBSOrder();
        
        // Create In Production lines (should be returned)
        List<EBS_Order_Line__c> inProductionLines = createEBSOrderLines(
            testOrderId, 
            'In Production', 
            2
        );
        
        // Create lines with completely different status values (should NOT be returned)
        EBS_Order_Line__c shippedLine = new EBS_Order_Line__c(
            Order__c = testOrderId,
            TOV_Line_Status__c = 'Shipped',
            Quantity__c = 5,
            External_Product_Name__c = 'Test Product',
            Product_Number__c = 'PROD-001'
        );
        insert shippedLine;
        
        EBS_Order_Line__c onHoldLine = new EBS_Order_Line__c(
            Order__c = testOrderId,
            TOV_Line_Status__c = 'On Hold',
            Quantity__c = 6,
            External_Product_Name__c = 'Test Product 2',
            Product_Number__c = 'PROD-002'
        );
        insert onHoldLine;
        
        // Act
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId;
        List<EBS_Order_Line__c> result = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        Test.stopTest();
        
        // Assert
        System.assertEquals(
            2, 
            result.size(), 
            'Should return only In Production status lines, excluding Shipped and On Hold'
        );
        
        // Verify the correct lines were returned
        Set<Id> resultIds = new Set<Id>();
        for (EBS_Order_Line__c line : result) {
            resultIds.add(line.Id);
        }
        
        System.assert(!resultIds.contains(shippedLine.Id), 'Shipped line should not be included');
        System.assert(!resultIds.contains(onHoldLine.Id), 'On Hold line should not be included');
    }
    
    /**
     * @description Test getEBSOrderLines with order ID change
     * Verifies that changing orderId returns different results
     */
    @isTest
    static void testGetEBSOrderLines_OrderIdChange() {
        // Arrange
        Id testOrderId1 = createEBSOrder();
        Id testOrderId2 = createEBSOrder();
        
        List<EBS_Order_Line__c> order1Lines = createEBSOrderLines(
            testOrderId1, 
            'In Production', 
            2
        );
        List<EBS_Order_Line__c> order2Lines = createEBSOrderLines(
            testOrderId2, 
            'In Production', 
            5
        );
        
        // Act & Assert - First order
        Test.startTest();
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId1;
        List<EBS_Order_Line__c> result1 = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        
        System.assertEquals(
            2, 
            result1.size(), 
            'Should return 2 lines for first order'
        );
        
        // Change orderId and verify different results
        VF_InvHold_LeadTimeAutomation.orderId = testOrderId2;
        List<EBS_Order_Line__c> result2 = VF_InvHold_LeadTimeAutomation.getEBSOrderLines();
        
        System.assertEquals(
            5, 
            result2.size(), 
            'Should return 5 lines for second order'
        );
        Test.stopTest();
    }
}