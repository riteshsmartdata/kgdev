/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : Ritesh Kumar
**/

@isTest
public class ODS_NotificationAcknowledgementTest {

    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"test@testers.com","EventStatus":"SUCCESS","EventType":"DML","EventStatusMessage":"Successfully Completed","CustomerData":{"sf_Id":"0035300000BK8KAAA1","web_Id":"5c9e20578513d211813ed6e5a43","userName":"test@testers.com","accountNumber":"24254","firstName":"Rob","lastName":"Meier","contactType":"Other","emailId":"test@testers.com","primaryPhone":null,"Mobile":null,"preferanceTypes":[{"preferanceTypeName":"Order Communication","preferanceTypeId":"Order_Communication","preferanceTypeDetails":null,"preferanceTypeDetailsId":null,"preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]}]}]}}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void sendNotification_UnitTest(){
       
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '828312';
        acc.EBS_Parent_ID__c = '12345';
        acc.Customer_Category__c= 'Casino';
        acc.ParentId = acc.Id;
        Insert acc;

        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact 0';
        con.AccountId = acc.Id;
        con.Email = 'Test0@testing.com'; 
        con.Acc_PO_Contact__c = true; 
        Insert con;   
 
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        ebs.Account_Name__c = acc.Id;
        ebs.Acc_PO_Contact_CC_Email__c = 'test@tes.com';
        ebs.PO_Contact_Email__c = 'test@test.com';
        insert ebs;
 
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.Status__c = 'New';
        notif.EBS_Order__c = ebs.Id;
        notif.ODS_ID__c = '63d7cc2d74e7e177eab76e9e';
        notif.Notif_Send_Resend_Date__c = System.now();
        notif.Notification_Type__c = 'Notifications';
        Insert notif;

        ODS_NotificationAcknowledgement.sendNotificationStatus(new list<Notification__c>{notif});
        Test.stopTest();


    }
}