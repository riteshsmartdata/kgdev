/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-06-2024   Ritesh Kumar   Initial Version
**/
@IsTest
public class EBSOrderLineSendEmailTest {
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
    static void makeData(){
        SwitchTrigger__c st = new SwitchTrigger__c(Name='EmailLinkTrigger',Deactivate__c=false);
        insert st;
        Account accountRecord =  TestData.createAccount(FALSE);
        accountRecord.Customer_Account_Number__c = '159753215';
        insert accountRecord;
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Contact contactRecord = TestData.createContact(FALSE,accountRecord.Id);
        contactRecord.email = 'test@test.com.full';
        contactRecord.Order_Acknowledgement__c = 'Email';
        contactRecord.Shipment_Confirmation__c = 'Email';
        contactRecord.PO_Confirmation__c = 'Email';
        insert contactRecord;
        EBS_Order__c orderRecord1 = TestData.createEBSOrder(FALSE);
        orderRecord1.PO_Contact_Email__c = 'test@test.com.full';
        orderRecord1.Customer_Account_Number__c = '159753215';
        orderRecord1.EBS_Order_Number__c = '87080';
        orderRecord1.Account_Name__c = accountRecord.Id;
        orderRecord1.Latest_in_Production_Date_Time__c = null;
        insert orderRecord1;
        EBS_Order__c orderRecord2 = TestData.createEBSOrder(FALSE);
        orderRecord2.PO_Contact_Email__c = 'test@test.com.full';
        orderRecord2.Customer_Account_Number__c = '159753215';
        orderRecord2.EBS_Order_Number__c = '98964';
        orderRecord2.Account_Name__c = accountRecord.Id;
        orderRecord2.Latest_in_Production_Date_Time__c = null;
        insert orderRecord2;
    }
    @IsTest
    public static void inProduction_Test(){
        EBS_Order__c lstEBsOrder1 = [SELECT Id FROM EBS_Order__c WHERE EBS_Order_Number__c ='87080' LIMIT 1];
        EBS_Order__c lstEBsOrder2 = [SELECT Id FROM EBS_Order__c WHERE EBS_Order_Number__c ='98964' LIMIT 1];
        Test.startTest();
            List<EBS_Order_Line__c> lstEBSOrderLine  = new List<EBS_Order_Line__c>();
            EBS_Order_Line__c orderLineRecord = TestData.createEBSOrderLine(false);
            orderLineRecord.Order__c = lstEBsOrder1.Id;
            orderLineRecord.TOV_Line_Status__c = 'In Production'; 
            lstEBSOrderLine.add(orderLineRecord);
            EBS_Order_Line__c orderLineRecord1 = TestData.createEBSOrderLine(false);
            orderLineRecord1.Order__c = lstEBsOrder1.Id;
            orderLineRecord1.TOV_Line_Status__c = 'In Production'; 
            lstEBSOrderLine.add(orderLineRecord1);
            EBS_Order_Line__c orderLineRecord2 = TestData.createEBSOrderLine(false);
            orderLineRecord2.Order__c = lstEBsOrder2.Id;
            orderLineRecord2.TOV_Line_Status__c = 'Complete';
            orderLineRecord2.Shipment_Email_Sent__c = true; 
            lstEBSOrderLine.add(orderLineRecord2);
            EBS_Order_Line__c orderLineRecord3 = TestData.createEBSOrderLine(false);
            orderLineRecord3.Order__c = lstEBsOrder2.Id;
            orderLineRecord3.TOV_Line_Status__c = 'Complete';
            orderLineRecord3.Shipment_Email_Sent__c = true; 
            lstEBSOrderLine.add(orderLineRecord3);
            insert lstEBSOrderLine;
            EBS_Order__c order = [SELECT Id, name, Latest_in_Production_Date_Time__c FROM EBS_Order__c WHERE EBS_Order_Number__c ='87080' LIMIT 1];
            System.assertEquals(TRUE, order.Latest_in_Production_Date_Time__c != null);
        Test.StopTest();
    }
    @isTest
    public static void upProduction_Test(){
        List<EBS_Order_Line__c> lstUpdateOrderLine = new List<EBS_Order_Line__c>();
        EBS_Order__c lstEBsOrder1 = [SELECT Id FROM EBS_Order__c WHERE EBS_Order_Number__c ='87080' LIMIT 1];
        EBS_Order__c lstEBsOrder2 = [SELECT Id FROM EBS_Order__c WHERE EBS_Order_Number__c ='98964' LIMIT 1];
        Test.startTest();
            List<EBS_Order_Line__c> lstEBSOrderLine  = new List<EBS_Order_Line__c>();
            EBS_Order_Line__c orderLineRecord = TestData.createEBSOrderLine(false);
            orderLineRecord.Order__c = lstEBsOrder1.Id;
            orderLineRecord.TOV_Line_Status__c = 'draft'; 
            lstEBSOrderLine.add(orderLineRecord);
            EBS_Order_Line__c orderLineRecord1 = TestData.createEBSOrderLine(false);
            orderLineRecord1.Order__c = lstEBsOrder1.Id;
            orderLineRecord1.TOV_Line_Status__c = 'draft'; 
            lstEBSOrderLine.add(orderLineRecord1);
            EBS_Order_Line__c orderLineRecord2 = TestData.createEBSOrderLine(false);
            orderLineRecord2.Order__c = lstEBsOrder2.Id;
            orderLineRecord2.TOV_Line_Status__c = 'Pre Production'; 
            lstEBSOrderLine.add(orderLineRecord2);
            EBS_Order_Line__c orderLineRecord3 = TestData.createEBSOrderLine(false);
            orderLineRecord3.Order__c = lstEBsOrder2.Id;
            orderLineRecord3.TOV_Line_Status__c = 'Pre Production'; 
            lstEBSOrderLine.add(orderLineRecord3);
            insert lstEBSOrderLine;
            List<EBS_Order_Line__c> upEBSOrderLineProd = [SELECT Id,TOV_Line_Status__c FROM EBS_Order_Line__c WHERE Order__c =: lstEBsOrder1.Id LIMIT 2];
            List<EBS_Order_Line__c> upEBSOrderLineComp = [SELECT Id,TOV_Line_Status__c FROM EBS_Order_Line__c WHERE Order__c =: lstEBsOrder2.Id LIMIT 2];
            for(EBS_Order_Line__c olRecord: upEBSOrderLineProd){
                olRecord.TOV_Line_Status__c = 'In Production';
                lstUpdateOrderLine.add(olRecord);
            }
            for(EBS_Order_Line__c olRecord: upEBSOrderLineComp){
                olRecord.TOV_Line_Status__c = 'Complete';
                olRecord.Shipment_Email_Sent__c=true;
                lstUpdateOrderLine.add(olRecord);
            }
            update lstUpdateOrderLine;
        Test.StopTest();
    }
}