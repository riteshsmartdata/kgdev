/**
* @description       : 
* @author            : Mohammad Arafat Ali
* @group             : 
* @last modified on  : 01-25-2023
* @last modified by  : Mohammad Arafat Ali
**/
@isTest
public without sharing class PopulateEmailSubjectTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void populateSubject() {
      /*  Profile pf = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(
            Alias                 = 'usralias',
            Email                 = 'theuser@email.com',
            Emailencodingkey      = 'UTF-8',
            Lastname              = 'user_lastname',
            Languagelocalekey     = 'en_US',
            Localesidkey          = 'en_US',
            Profileid             =  pf.Id,
            Timezonesidkey        = 'America/Los_Angeles',
            Username              =  Math.random() + 'test@testuser.com',
            CompanyName           = 'the company'
        );
        insert usr ;
        
        string templateText = '<messaging:emailTemplate subject="Test {!relatedTo.Name}" recipientType="User" relatedToType="EBS_Order__c"><messaging:htmlEmailBody ><ul><li>test {!recipient.Name} {!relatedTo.Name} content</li></ul></messaging:htmlEmailBody></messaging:emailTemplate>';
        EmailTemplate template = new EmailTemplate(DeveloperName = 'Calendar_Coop_PO_Receipt_v1', TemplateType = 'visualforce', FolderId = UserInfo.getUserId(),
                                                   Name = 'Calendar_Coop_PO_Receipt_v1', Subject = 'This is a test Email subject',
                                                   IsActive = true);
        
        template.Markup=templateText;
        
        System.runAs(usr){
            insert template;
        }*/
        EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE Name like '%Price Change%' LIMIT 1];
        
        
        List<EBS_Order__c> ebsList = new List<EBS_Order__c>();   
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        
        Account acc= new Account();
        acc.Name = 'Test Account';
        acc.Acc_PO_Contact_Email__c = 'arafata@damco.com';
        acc.Customer_Account_Number__c = '123456';
        acc.Customer_PO_Number__c = '12345';
        acc.RecordTypeId = accRecTypId;
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Email = 'Test@testing.com';
        con.RecordTypeId = conRecTypId;
        con.Acc_PO_Contact__c = True;
        insert con;
        
        EBS_Order__c ebsOrder = new EBS_Order__c();
        ebsOrder.Account_Name__c = acc.Id; 
        ebsOrder.PO_Contact_Email__c = 'arafata@damco.com'; 
        ebsOrder.Customer_Account_Number__c = '123456'; 
        ebsOrder.EBS_Order_Number__c = '1234';
        ebsOrder.Send_Lead_Time_Notification__c = true;
        ebsOrder.Acc_PO_Contact_To_Email__c = 'nik@abctestinvalid.com, nik2@abctestinvalid2.com';
        ebsOrder.Lead_Time_Template__c = 'Koozie: Lead Time Automation';
        ebsOrder.PO_Contact__c = con.Id; 
        insert ebsOrder;
        
        Notification__c notif = new Notification__c();
        notif.EBS_Order__c = ebsOrder.Id;
        notif.EBS_Order_Contact__c = con.Id;
        notif.Template_Id__c = template.Id;
        notif.Email_Recipient__c = ebsOrder.PO_Contact_Email__c;
        notif.Email_Body__c ='Test Body';
        notif.Subject__c = 'Test subject';
        notif.Notification_Type__c ='PO Contact';
        Insert notif;
        
        PopulateEmailSubject.EmailValues emv = new PopulateEmailSubject.EmailValues();
        emv.ContactId = con.Id;
        emv.orderId = ebsOrder.Id;
        emv.templateId = template.Id; 
        
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest(); 
        PopulateEmailSubject.populateSubject(new List<PopulateEmailSubject.EmailValues>{emv});
        Test.stopTest();
    }
}