@isTest
private with sharing class EBSOrderTriggerUtility_Test {
    private static String accountCustomerRecordTypeId = KoozieUtility.getRecordTypeId('Account','Customers');
    private static String contactCRMRecordTypeId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');
    @TestSetup
    private static void inserTestData(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        TestDataFactory.switchTriggerSetting();
        // Create standard Account and update with BDF to trigger Sales Contact logic
        Account accountTestRecord = TestData.createAccount(false);
        accountTestRecord.RecordTypeId = accountCustomerRecordTypeId;
        insert accountTestRecord;
        accountTestRecord.Customer_Class_Code__c = 'BDF';
        accountTestRecord.AccountNumber = '765793';
        update accountTestRecord;
        
        Account accountTestRecord2 = TestData.createAccount(false);
        accountTestRecord2.RecordTypeId = accountCustomerRecordTypeId;
        insert accountTestRecord2;
        accountTestRecord2.Customer_Class_Code__c = 'BDF';
        update accountTestRecord2;
        
        // Create Distributor Account (used only in logic for sales contact assignment)
        Account distributorAccount = TestData.createAccount(false);
        distributorAccount.RecordTypeId = accountCustomerRecordTypeId;
        insert distributorAccount;
        
        // Create CRM Contacts used for matching
        List<String> testEmails = new List<String>{
            'testOrderKoozie@test.com.full',
                'testShippingKoozie@test.com.full',
                'pocontacttest@koozie.com.full',
                'shippingcontacttest@koozie.com.full',
                'ordercontacttest@koozie.com.full',
                'ordershippingcontacttest@koozie.com.full',
                'salescontacttest@koozie.com.full',
                'pocontact2test@koozie.com.full',  'perfectsales@koozie.com.full','noexistingmatch@koozie.com.full'
                
                };
                    List<Contact> contactList = new List<Contact>();
        for (String email : testEmails) {
            Id accId = email == 'salescontacttest@koozie.com.full' ? distributorAccount.Id : accountTestRecord.Id;
            Boolean isSales = email == 'salescontacttest@koozie.com.full' || email == 'perfectsales@koozie.com.full';
            
            contactList.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = email,
                Contact_Status__c = 'Active',
                AccountId = accId,
                RecordTypeId = contactCRMRecordTypeId,
                Is_Sales_Contact__c = isSales
            ));
        }
        insert contactList;
    }
    @isTest
    private static void insertEBSOrderRecordScenario00(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = accTestRecord.get(0).Id,Order_Confirmation_Email__c='testOrderKoozie@test.com.full');
        INSERT ebsOrderTestRecord;
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null , 'Order contact is not populated');
        Test.stopTest();
    }
    @isTest
    private static void insertEBSOrderRecordScenario01(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = accTestRecord.get(0).Id,Shipping_Notification_Email__c='testShippingKoozie@test.com.full');
        INSERT ebsOrderTestRecord;
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null , 'Shipping contact is not populated');
        
        Test.stopTest();
    }
    @isTest
    private static void insertEBSOrderRecordScenario02(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = new EBS_Order__c(Account_Name__c = accTestRecord.get(0).Id,Order_Confirmation_Email__c='testOrderKoozie@test.com.full',Shipping_Notification_Email__c='testShippingKoozie@test.com.full');
        INSERT ebsOrderTestRecord;
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null , 'Shipping contact is not populated');
        system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order contact is not populated');
        Test.stopTest();
    }    
    @isTest
    private static void insertEBSOrderRecordScenario1(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com.full');
        INSERT ebsOrderTestRecord;
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        System.assertEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are Different');
        System.assertEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are Different');
        Test.stopTest();
    }
    /* @isTest
private static void insertEBSOrderRecordScenario2(){
List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com');
ebsOrderTestRecord.Order_Confirmation_Email__c = 'pocontacttest@koozie.com';
ebsOrderTestRecord.Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com';
ebsOrderTestRecord.Sales_Contact__c = 'pocontacttest@koozie.com';
INSERT ebsOrderTestRecord;

List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
system.assertEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are Different');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are same');

system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
system.assert(ebsOrderRecordList.get(0).SalesContact__c!=null,'Sales Contact was not populated');
Test.stopTest(); 
}
@isTest
private static void insertEBSOrderRecordScenarioSales2(){
List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com');
ebsOrderTestRecord.Order_Confirmation_Email__c = 'pocontacttest@koozie.com';
ebsOrderTestRecord.Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com';
ebsOrderTestRecord.Sales_Contact__c = 'salescontacttest@koozie.com';
INSERT ebsOrderTestRecord;

List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
system.assertEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are Different');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are same');

system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
Test.stopTest(); 
} 
@isTest
private static void insertEBSOrderRecordScenario3(){
List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com');
ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordercontacttest@koozie.com';
ebsOrderTestRecord.Shipping_Notification_Email__c = 'pocontacttest@koozie.com';
ebsOrderTestRecord.Sales_Contact__c = 'pocontacttest@koozie.com';
INSERT ebsOrderTestRecord;

List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
system.assertEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are Different');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are same');

system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
system.assert(ebsOrderRecordList.get(0).SalesContact__c!=null,'Sales Contact was not populated');
Test.stopTest(); 
}
*/
    @isTest
    private static void insertEBSOrderRecordScenarioSales3(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com.full');
        ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordercontacttest@koozie.com.full';
        ebsOrderTestRecord.Shipping_Notification_Email__c = 'pocontacttest@koozie.com.full';
        ebsOrderTestRecord.Sales_Contact__c = 'salescontacttest@koozie.com.full';
        INSERT ebsOrderTestRecord;
        
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assertEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are Different');
        system.assertNotEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are same');
        
        system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
        Test.stopTest(); 
    }
    /*
@isTest
private static void insertEBSOrderRecordScenario4(){
List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com');
ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordershippingcontacttest@koozie.com';
ebsOrderTestRecord.Shipping_Notification_Email__c = 'ordershippingcontacttest@koozie.com';
ebsOrderTestRecord.Sales_Contact__c = 'ordershippingcontacttest@koozie.com';
INSERT ebsOrderTestRecord;

List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
system.assertEquals('ordershippingcontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'Order & Shipping Email are Different');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are same');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Notification Email are same');

system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
system.assert(ebsOrderRecordList.get(0).SalesContact__c!=null,'Sales Contact was not populated');        
Test.stopTest(); 
}*/
    @isTest
    private static void insertEBSOrderRecordScenarioSales4(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com.full');
        ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordershippingcontacttest@koozie.com.full';
        ebsOrderTestRecord.Shipping_Notification_Email__c = 'ordershippingcontacttest@koozie.com.full';
        ebsOrderTestRecord.Sales_Contact__c = 'salescontacttest@koozie.com.full';
        INSERT ebsOrderTestRecord;
        
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assertEquals('ordershippingcontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'Order & Shipping Email are Different');
        system.assertNotEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'PO & Order Email are same');
        system.assertNotEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Notification Email are same');
        
        system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');        
        Test.stopTest(); 
    }
    @isTest
    private static void insertEBSOrderRecordScenario5(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com.full');
        ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordercontacttest@koozie.com.full';
        ebsOrderTestRecord.Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com.full';
        ebsOrderTestRecord.Sales_Contact__c = 'salescontacttest@koozie.com.full';
        INSERT ebsOrderTestRecord;
        EBSOrderTriggerUtility.updateSalesContactToNewDistributor(ebsOrderTestRecord);
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        system.assertNotEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'Order & Shipping Email are same');
        system.assertNotEquals('pocontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are same');
        system.assertNotEquals('ordercontacttest@koozie.com.full',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'Order & shipping Email are same');
        
        system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
        system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');        
        Test.stopTest(); 
    }
    /*
@isTest
private static void insertEBSOrderRecordScenarioSales5(){
List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com');
ebsOrderTestRecord.Order_Confirmation_Email__c = 'ordercontacttest@koozie.com';
ebsOrderTestRecord.Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com';
ebsOrderTestRecord.Sales_Contact__c = 'shippingcontacttest@koozie.com';
INSERT ebsOrderTestRecord;

List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Order_Confirmation_Email__c , 'Order & Shipping Email are same');
system.assertNotEquals('pocontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'PO & Shipping Email are same');
system.assertNotEquals('ordercontacttest@koozie.com',ebsOrderRecordList.get(0).Shipping_Notification_Email__c , 'Order & shipping Email are same');

system.assert(ebsOrderRecordList.get(0).PO_Contact__c!=null,'PO Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Order_Confirm_Contact__c!=null,'Order Contact was not populated');
system.assert(ebsOrderRecordList.get(0).Shipping_Notif_Contact__c!=null,'Shipping Contact was not populated');
system.assert(ebsOrderRecordList.get(0).SalesContact__c!=null,'Sales Contact was not populated');        
Test.stopTest(); 
}*/
    @isTest
    private static void updateEBSOrderRecordScenario1(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrderTestRecord = TestData.createEBSOrderPOContactEmail(false,accTestRecord.get(0).Id,'pocontacttest@koozie.com.full');
        INSERT ebsOrderTestRecord;
        List<EBS_Order__c> ebsOrderRecordList = getEBSOrderRecord(ebsOrderTestRecord.Id);
        ebsOrderRecordList.get(0).PO_Contact_Email__c = 'pocontact2test@koozie.com.full';
        UPDATE ebsOrderRecordList;
        system.assert(String.isNotBlank(ebsOrderRecordList.get(0).PO_Contact_Email__c), 'PO Email is null');
        Test.stopTest();
    }
    private static List<EBS_Order__c> getEBSOrderRecord(String ebdOrderId){
        return [Select Id,PO_Contact_Email__c,Order_Confirmation_Email__c,Shipping_Notification_Email__c,PO_Contact__c,Order_Confirm_Contact__c,Shipping_Notif_Contact__c,SalesContact__c, Sales_Contact__c From EBS_Order__c WHERE ID =:ebdOrderId];
    }
    /*
@isTest
private static void insertEBSOrderRecordScenarioSales6(){
Account distributor = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
Test.startTest();
Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
EBS_Order__c order = new EBS_Order__c(Account_Name__c = distributor.Id,Sales_Contact__c = 'perfectsales@koozie.com',
Distributor_Account__c = distributor.Id
);
insert order;
Test.stopTest();
EBS_Order__c result = [SELECT Id, SalesContact__c FROM EBS_Order__c WHERE Id = :order.Id];
System.assertNotEquals(null, result.SalesContact__c, 'Sales Contact was not populated even though a matching CRM contact existed');
}*/
    @isTest
    private static void insertEBSOrderRecord_SalesContactFieldNull(){
        Account acc = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c order = new EBS_Order__c(Account_Name__c = acc.Id, Sales_Contact__c = null);
        insert order;
        Test.stopTest();
        EBS_Order__c result = [SELECT SalesContact__c FROM EBS_Order__c WHERE Id = :order.Id];
        System.assertEquals(null, result.SalesContact__c, 'SalesContact__c should remain null if email is not provided');
    }
    @isTest
    private static void insertEBSOrder_POOnly(){
        List<Account> accTestRecord = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrder = new EBS_Order__c(Account_Name__c = accTestRecord.get(0).Id,PO_Contact_Email__c = 'pocontacttest@koozie.com.full'
                                                );
        insert ebsOrder;
        Test.stopTest();
    }
    @isTest
    private static void updateEBSOrder_SalesContactUpdate(){
        Account acc = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            Distributor_Account__c = acc.Id,
            Sales_Contact__c = 'noexistingmatch@koozie.com.full' // Set initially to a non-matching contact
        );
        insert ebsOrder;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ebsOrder.Sales_Contact__c = 'perfectsales@koozie.com.full'; // Now update to valid match
        update ebsOrder;
        Test.stopTest();
    }
    @isTest
    private static void insertEBSOrder_AllThreeEmails(){
        List<Account> accList = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Account acc = accList[0];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'pocontacttest@koozie.com.full',
            Order_Confirmation_Email__c = 'ordercontacttest@koozie.com.full',
            Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com.full',
            Sales_Contact__c = 'salescontacttest@koozie.com.full',
            Distributor_Account__c = acc.Id
        );
        insert ebsOrder;
        Test.stopTest();
    }
    @isTest
    private static void updateEBSOrder_SetShippingEmail(){
        List<Account> accList = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Account acc = accList[0];
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id
        );
        insert ebsOrder;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ebsOrder.Shipping_Notification_Email__c = 'shippingcontacttest@koozie.com.full';
        update ebsOrder;
        Test.stopTest();
    }
    @isTest
    private static void updateEBSOrder_ClearPOEmail(){
        List<Account> accList = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Account acc = accList[0];
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            PO_Contact_Email__c = 'pocontacttest@koozie.com.full'
        );
        insert ebsOrder;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ebsOrder.PO_Contact_Email__c = null;
        update ebsOrder;
        Test.stopTest();
    }
    
    @isTest
    private static void updateSalesContact_NoDistributor(){
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = accList[0].Id,
            Sales_Contact__c = 'salescontacttest@koozie.com.full'
        );
        insert ebsOrder;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBSOrderTriggerUtility.updateSalesContactToNewDistributor(ebsOrder); // Should gracefully skip logic
        Test.stopTest();
    }
    
    @isTest
    private static void insertEBSOrder_SalesContact_NoMatch(){
        Account acc = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            Distributor_Account__c = acc.Id,
            Sales_Contact__c = 'notfound@koozie.com.full'
        );
        insert ebsOrder;
        Test.stopTest();
    }
    
    @isTest
    private static void insertEBSOrderkooziegroup(){
        Account acc = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            Distributor_Account__c = acc.Id,
            Sales_Contact__c = 'notfound@kooziegroup.com'
        );
        insert ebsOrder;
        Test.stopTest();
    }
    
    @isTest
    private static void insertGolfAccount(){
        Account acc = [SELECT Id FROM Account WHERE Customer_Class_Code__c = 'BDF' AND AccountNumber = null LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        EBS_Order__c ebsOrder = new EBS_Order__c(
            Account_Name__c = acc.Id,
            Distributor_Account__c = acc.Id,
            Sales_Contact__c = 'test@test.com' 
        );
        insert ebsOrder;
        Test.stopTest();
    }
        
}