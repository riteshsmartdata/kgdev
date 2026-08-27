/**
* @description: Tests for PopulateFromEmailOnOrder to achieve 100% coverage
* Uses TestDataFactory where applicable to create Account/Contact etc.
*/
@IsTest
private class PopulateFromEmailOnOrderTest {
    
    private class RestMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest req) {
			HTTPResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'text/json'); 
			res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
			res.setStatusCode(200);
			return res;
		}
    }
        
    // Utility: create ACT record
    private static Account_Clarification_Team__c makeACT(String ebsNum, String fromEmail, String category, String logo) {
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'ACT ' + ebsNum;
        act.EBS_Num__c = ebsNum;
        act.From_Email__c = fromEmail;
        act.Customer_Category__c = category;
        act.Logo__c = logo;
        act.Account_Queue__c = 'General';
        return act;
    }
    
    // Utility: create Account with desired attributes
    private static Account makeAccount(String name, String can, String customerCategory, String logo, String routingOverride, Id parentId) {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = TestDataFactory.createAccount(name, can, 'Customers', false);
        a.Customer_Category__c = customerCategory;
        a.Logo__c = logo;
        a.Routing_Override__c = routingOverride;
        if (parentId != null) a.ParentId = parentId;
        return a;
    }
    
    // Cover path: no Customer_Account_Number__c set on order => defaults to CUSTOMER_SERVICE
    @IsTest
    static void test_DefaultsToCustomerService_WhenNoCustomerAccount() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        // minimal order record (do not set Name; not writeable)
        EBS_Order__c ord = new EBS_Order__c();
        // no Customer_Account_Number__c
        insert ord;
        
        // invoke
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        
        Test.stopTest();
        
        System.assertEquals('customerservice@kooziegroup.com', ord.From_Email__c, 'Should default to Customer Service email');
    }
    
    // Cover: Account exists and Logo__c = 'Calendar Coop'
    @IsTest
    static void test_FromEmail_ByLogoCalendarCoop() {
        // Ensure required app settings in factory that some code may rely on
        TestDataFactory.loadAppSetting();
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        // Account matching logo condition
        Account a = makeAccount('Acc Coop', 'A1001', null, 'Calendar Coop', null, null);
        insert a;
        
        // Order for this customer (omit Name; not writeable)
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1001');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('csinfo@calendarcs.com', ord.From_Email__c, 'Calendar Coop route');
    }
    
    // Cover: Routing_Override__c = 'Calendar Dedicated'
    @IsTest
    static void test_FromEmail_ByRoutingOverrideCalendarDedicated() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc Dedicated', 'A1002', null, null, 'Calendar Dedicated', null);
        insert a;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1002');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('coopspecialtyteam@kooziegroup.com', ord.From_Email__c, 'Calendar Dedicated route');
    }
    
    // Cover: Customer_Category__c = Bookstore => Anchor Wallace
    @IsTest
    static void test_FromEmail_CategoryBookstore() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc Book', 'A1003', 'Bookstore', null, null, null);
        insert a;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1003');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('anchorwallace@anchorwallace.com', ord.From_Email__c, 'Bookstore => Anchor Wallace');
    }
    
    // Cover: Category Church => Anchor Wallace
    @IsTest
    static void test_FromEmail_CategoryChurch() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc Church', 'A1004', 'Church', null, null, null);
        insert a;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1004');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('anchorwallace@anchorwallace.com', ord.From_Email__c, 'Church => Anchor Wallace');
    }
    
    // Cover: Category Casino => CS Hotel
    @IsTest
    static void test_FromEmail_CategoryCasino() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc Casino', 'A1005', 'Casino', null, null, null);
        insert a;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1005');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('cshotel@kooziegroup.com', ord.From_Email__c, 'Casino => CS Hotel');
    }
    
    // Cover: Category Hotel => CS Hotel
    @IsTest
    static void test_FromEmail_CategoryHotel() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc Hotel', 'A1006', 'Hotel', null, null, null);
        insert a;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1006');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('cshotel@kooziegroup.com', ord.From_Email__c, 'Hotel => CS Hotel');
    }
    
    // Cover: Parent relation P with specific numeric EBS numbers: 33381 => proformabcsteam
    @IsTest
    static void test_FromEmail_Parent33381() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account parent = makeAccount('Parent33381', '33381', null, null, null, null);
        insert parent;
        
        Account child = makeAccount('Child1', 'C1007', null, null, null, parent.Id);
        insert child;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='C1007');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('proformabcsteam@kooziegroup.com', ord.From_Email__c, 'Parent 33381 route');
    }
    
    // Cover: Parent relation P with specific numeric: 741016 => Anchor Wallace
    @IsTest
    static void test_FromEmail_Parent741016() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account parent = makeAccount('Parent741016', '741016', null, null, null, null);
        insert parent;
        
        Account child = makeAccount('Child2', 'C1008', null, null, null, parent.Id);
        insert child;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='C1008');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('anchorwallace@anchorwallace.com', ord.From_Email__c, 'Parent 741016 route');
    }
    
    // Cover: Parent relation P with numeric: 22452 => Gary Containers
    @IsTest
    static void test_FromEmail_Parent22452() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account parent = makeAccount('Parent22452', '22452', null, null, null, null);
        insert parent;
        
        Account child = makeAccount('Child3', 'C1009', null, null, null, parent.Id);
        insert child;
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='C1009');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('customerservice@garycontainers.com', ord.From_Email__c, 'Parent 22452 route');
    }
    
    // Cover: Account not found but ACT exists => get ACT.From_Email__c
    @IsTest
    static void test_FromEmail_WhenAccountMissing_ACTPresent() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        insert makeACT('ACT101', 'act101@kooziegroup.com', null, null);
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='ACT101');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('act101@kooziegroup.com', ord.From_Email__c, 'Should use ACT From Email when account missing');
    }
    
    // Cover: Neither Account nor ACT => default CUSTOMER_SERVICE
    @IsTest
    static void test_FromEmail_WhenNoAccountNoACT() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='X-NOT-FOUND');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('customerservice@kooziegroup.com', ord.From_Email__c, 'Fallback to customer service');
    }
    
    // Cover: else branch inside accounts.containsKey customer path - use ACT From_Email__c
    @IsTest
    static void test_FromEmail_AccountExistsButNoSpecificMatch_UseACT() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account a = makeAccount('Acc ACT', 'A1012', null, null, null, null);
        insert a;
        insert makeACT('A1012', 'act@kooziegroup.com', null, null);
        
        EBS_Order__c ord = new EBS_Order__c(Customer_Account_Number__c='A1012');
        insert ord;
        
        Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ ord });
        Test.stopTest();
        
        System.assertEquals('act@kooziegroup.com', ord.From_Email__c, 'Use ACT when no other account attribute matched');
    }
    
    // Cover: Batch/multi-record path + mixed relations (parent and child and no number)
    @IsTest
    static void test_MultipleOrders_MixedScenarios() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        // Parent 33381 => child should map
        Account p1 = makeAccount('P33381', '33381', null, null, null, null); insert p1;
        Account c1 = makeAccount('C-A', 'C2001', null, null, null, p1.Id); insert c1;
        
        // Simple account with ACT fallback
        Account a2 = makeAccount('A2', 'A2002', null, null, null, null); insert a2;
        insert makeACT('A2002', 'a2@kooziegroup.com', null, null);
        
        EBS_Order__c o1 = new EBS_Order__c(Customer_Account_Number__c='C2001');
        EBS_Order__c o2 = new EBS_Order__c(Customer_Account_Number__c='A2002');
        EBS_Order__c o3 = new EBS_Order__c(); // no CAN
        insert new List<EBS_Order__c>{ o1, o2, o3 };
            
            Test.startTest();
        PopulateFromEmailOnOrder.populateFromEmail(new List<EBS_Order__c>{ o1, o2, o3 });
        Test.stopTest();
        
        System.assertEquals('proformabcsteam@kooziegroup.com', o1.From_Email__c, 'Parent 33381 route in batch');
        System.assertEquals('a2@kooziegroup.com', o2.From_Email__c, 'ACT fallback in batch');
        System.assertEquals('customerservice@kooziegroup.com', o3.From_Email__c, 'Default in batch');
    }
}