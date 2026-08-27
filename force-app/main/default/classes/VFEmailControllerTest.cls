@isTest
private class VFEmailControllerTest {
    
    @isTest
    static void testGetEBSOrderLines() {
        // Create a test EBS_Order record
        EBS_Order__c testEBSOrder = new EBS_Order__c(
            Customer_Name__c = '1111111');
        
        insert testEBSOrder;
        
        // Create test EBS_Order_Line records related to the EBS_Order
        EBS_Order_Line__c testOrderLine1 = new EBS_Order_Line__c(
            Order__c = testEBSOrder.Id,
            Quantity__c = 5,
            External_Product_Name__c = 'Test Product 1',
            Product_Number__c = 'P001',
            TOV_Line_Status__c = 'In Production'
        );
        
        EBS_Order_Line__c testOrderLine2 = new EBS_Order_Line__c(
            Order__c = testEBSOrder.Id,
            Quantity__c = 3,
            External_Product_Name__c = 'Test Product 2',
            Product_Number__c = 'P002',
            TOV_Line_Status__c = 'In Production'
        );
        
        // Insert the test EBS_Order_Line records
        insert new List<EBS_Order_Line__c>{testOrderLine1, testOrderLine2};
            
            // Set the EBS_Order Id in the controller
            VFEmailController.EbsId = testEBSOrder.Id;
        
        // Call the getEBSOrderLines method
        List<EBS_Order_Line__c> result = VFEmailController.getEBSOrderLines();
        
        // Assert that the returned list is not null and has the expected size
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.size());
    }
}