/**
* @description       : 
* @author            : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
* @group             : 
* @last modified on  : 12-02-2025
* @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
@IsTest
public class LeadTimeAutomation_Test {
    
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
    static void makeData(){
        TestDataFactory tdf = new TestDataFactory('loadCustom'); 
    } 
    
    
    @isTest
    static void sendLeadTimeAutomationEmailsTest() {    
         Test.setMock(HttpCalloutMock.class, new RestMock());
        Account acc = TestDataFactory.createAccount('Test Account', 'CUST12345', 'Customers', true);
        Contact con = TestDataFactory.createContact('Doe', 'John', acc.Id, 'CRM Contact', true);
        
        Ebs_Order__c ebsOrder = new Ebs_Order__c();
        ebsOrder.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        ebsOrder.Acc_PO_Contact_To_Email__c = 'test@test.com.full';
        ebsOrder.PO_Contact__c = con.id;
        ebsOrder.Template_Type__c = 'Koozie Group';
        ebsOrder.Lead_Time_Template__c = 'Koozie: Lead Time Automation';
        ebsOrder.RecordTypeId = KoozieUtility.getRecordTypeId('Ebs_Order__c', 'KG EBS Order');
        insert ebsOrder;
        
        EBS_Order_Line__c oli = new EBS_Order_Line__c();
        oli.Promise_Date__c = system.today() + 10;
        oli.Request_Ship_Date__c = system.today();
        oli.Order__c = ebsorder.id;
        insert oli; 
        
        ebsOrder.Order_Header_Status__c = 'BOOKED';
        update ebsOrder;
        
        Test.startTest();
        LeadTimeAutomation.sendLeadTimeAutomationEmails(new List<Id>{ebsOrder.Id});
        Test.stopTest();
    }
}