@isTest
public class AccountSampleOrdersControllerTest {
    @isTest
    static void testGetAccountOrders() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Create test EBS Orders
        EBS_Order__c order1 = new EBS_Order__c(
            EBS_Order_Number__c = '12345', 
            Effective_Date__c = System.today(), 
            Order_Header_Total__c = 100.0, 
            Order_Header_Charges__c = 10.0, 
            Order_Header_Status__c = 'Completed', 
            Customer_PO__c = 'PO12345', 
            Incl_in_Samples_Journey__c = true, 
            Date_Ordered__c = System.today(), 
            Order_Type__c = 'Sample Order', 
            Account_Name__c = testAccount.Id
        );
        insert order1;

        // Create test EBS Order Lines
        EBS_Order_Line__c orderLine1 = new EBS_Order_Line__c(
            External_Product_Name__c = 'Product 1', 
            Order__c = order1.Id
        );
        insert orderLine1;

        Test.startTest();
        
        // Call the method
        List<AccountSampleOrdersController.OrderWrapper> result = AccountSampleOrdersController.getAccountOrders(testAccount.Id);
        
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(1, result.size(), 'Expected 1 order wrapper');
        AccountSampleOrdersController.OrderWrapper wrapper = result[0];
        System.assertEquals('12345', wrapper.EBSOrderNumber, 'Expected order number to match');
        System.assertEquals('Product 1', wrapper.ExternalProductName, 'Expected product name to match');
        System.assertEquals(order1.Effective_Date__c, wrapper.EffectiveDate, 'Expected effective date to match');
        System.assertEquals(100.0, wrapper.OrderHeaderTotal, 'Expected order header total to match');
        System.assertEquals('Completed', wrapper.OrderHeaderStatus, 'Expected order header status to match');
        System.assertEquals('PO12345', wrapper.CustomerPO, 'Expected customer PO to match');
        System.assertEquals(true, wrapper.Incl_in_Samples_Journey, 'Expected inclusion in samples journey to match');
        System.assertEquals(order1.Id, wrapper.Id, 'Expected ID to match');
    }
}