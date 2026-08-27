@Istest
public class PopulateCommunicationEmailTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    public static void setupData(){
        TestDataFactory.loadAppSetting();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountInfo  = TestDataFactory.createAccount('Test Account','0123645','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('Test', 'Test', accountInfo.Id, 'CRM Contact', FALSE);
        contactInfo.Acc_Shipping_Contact__c = TRUE;
        contactInfo.Acc_Order_Acknowledgement__c = TRUE;
        contactInfo.Acc_PO_Contact__c = TRUE;
        Insert contactInfo;
    }
    
    @Istest
    public static void TagNewContactTest() {
        Id accountId = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '0123645' LIMIT 1 ].Id;
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        EBS_Order__c ebsOrder = new EBS_Order__c();
        ebsOrder.PO_Contact_Email__c = 'test23@test.com'; 
        ebsOrder.Customer_Account_Number__c = '0123645'; 
        ebsOrder.EBS_Order_Number__c = '123';
        ebsOrder.Account_Name__c = accountId;
        Test.startTest();
        Insert ebsOrder;
        EBS_Order__c [] orders = [
            SELECT 
            Id, Shipping_Notif_Contact__c, Order_Confirm_Contact__c,PO_Contact__c 
            FROM 
            EBS_Order__c  
            WHERE 
            Shipping_Notif_Contact__c != null AND 
            Order_Confirm_Contact__c != null AND 
            PO_Contact__c != null
        ];
        
        Contact [] Contacts = [SELECT Id,Email FROM Contact]; 
        System.assertEquals(true, orders.size() > 0);
        System.assertEquals(true, Contacts.size()>1);
        Test.stopTest();
    }
    
    @Istest
    public static void TagOldContactTest() {
        
        Id accountId = [SELECT Id FROM Account WHERE Customer_Account_Number__c = '0123645' LIMIT 1 ].Id;
        Test.setMock(HttpCalloutMock.class, new RestMock());        
        EBS_Order__c ebsOrder = new EBS_Order__c();
        ebsOrder.PO_Contact_Email__c = 'test@test.com'; 
        ebsOrder.Customer_Account_Number__c = '0123645'; 
        ebsOrder.EBS_Order_Number__c = '123';
        ebsOrder.Account_Name__c = accountId;
        Test.startTest();
        Insert ebsOrder;
        
        // Query Order
        EBS_Order__c [] orders = [
            SELECT 
            Id, Shipping_Notif_Contact__c, Order_Confirm_Contact__c,PO_Contact__c 
            FROM 
            EBS_Order__c  
            WHERE 
            Shipping_Notif_Contact__c != null AND 
            Order_Confirm_Contact__c != null AND 
            PO_Contact__c != null
        ];
        
        //Query Contact        
        Contact [] Contacts = [SELECT Id FROM Contact]; 
        System.assertEquals(true, orders.size() > 0);
        System.assertEquals(true, Contacts.size() > 0);
        Test.stopTest();
    }
    
}