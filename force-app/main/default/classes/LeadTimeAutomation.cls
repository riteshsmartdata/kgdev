/**
* @description       : 
* @author            : Nitesh
* @group             : 
* @last modified on  : 28-10-2024
* @last modified by  : Nitesh
* Modifications Log
* Ver   Date         Author   Modification
* 1.0   02-21-2023   Nitesh   Initial Version
SF-2193	28-10-2024	Nitesh		Added exception handling to log Errors in apex logs if email sending is failed.
**/
public with sharing class LeadTimeAutomation {
    @InvocableMethod(label='Ship Date Notification' description='Sending Ship Date Notification email only once if the Promise date is greater than Request Ship Date')
    public static void sendLeadTimeAutomationEmails(List<Id> newEBSorderId){
        system.debug('logic started');
        Map<Id,Ebs_Order__c> newEBSorderMap = new Map<Id,Ebs_Order__c>([SELECT Id,PO_Contact__c,PO_Contact_Email__c, Lead_Time_Template__c,Template_Type__c, From_Email__c, Acc_PO_Contact_To_Email__c FROM Ebs_Order__c WHERE Id IN:newEBSorderId AND PO_Contact__c != null ]);
        Set<Id> ebsOrderIdSet = new Set<Id>();
        Map<Id,EBS_Order_Line__c> ebsIdVsOrderLineMap = new Map<Id,EBS_Order_Line__c>(); 
        
        List<EBS_Order_Line__c> linesList = [SELECT Id, Name, Order__c, Is_PD_greater_than_RSD__c
                                             FROM EBS_Order_Line__c WHERE Order__c IN :newEBSorderId //ebsOrderIdSet
                                             AND Is_PD_greater_than_RSD__c ='Yes' LIMIT 50000];
        if (!linesList.isEmpty()){
            for (EBS_Order_Line__c ebsLine : linesList) {
                ebsIdVsOrderLineMap.put(ebsLine.Order__c,ebsLine);
            }
        }
        system.debug('all lines'+lineslist);
        //Get Org Wide Email List to set the FROM email
        List<OrgWideEmailAddress> allOWE = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress LIMIT 1000];
        Map<String, OrgWideEmailAddress> OWEToEmail_map = new Map<String, OrgWideEmailAddress>();
        
        //Loop and add to OWE Map
        for(OrgWideEmailAddress owe : allOWE){
            OWEToEmail_map.put(owe.Address, owe);
        }
        //Query and prepare Map of custom metadata type for Email templates.
        Map<String,Email_Template_Setting__mdt> emailTemplateMdt_Map = new Map<String,Email_Template_Setting__mdt>();
        Email_Template_Setting__mdt[] temp_mdt = [SELECT Id, MasterLabel, Template_Name__c,Template_Type__c, Email_Category__c 
                                                  FROM Email_Template_Setting__mdt
                                                  WHERE Email_Category__c='Booked' LIMIT 100];
        for(Email_Template_Setting__mdt rec : temp_mdt) {
            emailTemplateMdt_Map.put(rec.Template_Type__c, rec);
        }
        Map<String,EmailTemplate> emailTemplate_Map = new Map<String,EmailTemplate>();
        //Query all the Lightning email template used in BOOKED Lead time automations
        EmailTemplate[] emailTemplate = [Select Body, DeveloperName, HtmlValue, Id, Name, Subject, TemplateType, TemplateStyle
                                         From EmailTemplate WHERE Folder.Name='Booked Lead Time Automations' LIMIT 100];
        for(EmailTemplate emp : emailTemplate){
            emailTemplate_Map.put(emp.Name,emp);
        }
        system.debug('email templates'+emailTemplate);
        //send single email to order
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        for(Id orderId : ebsIdVsOrderLineMap.keyset()){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            Id poId = newEBSorderMap.get(orderId).PO_Contact__c;
            
            if (poId != null) {
                msg.setTargetObjectId(poId);
            }
            String templateType = newEBSorderMap.get(orderId).Template_Type__c;
            system.debug('template type='+newEBSorderMap.get(orderId).Template_Type__c);
            String LeadTypeTemplateName =  emailTemplateMdt_Map.get(templateType).Template_Name__c;
            //set the email template
            if(String.isNotBlank(LeadTypeTemplateName) && 
               emailTemplate_Map.containsKey(LeadTypeTemplateName)){
                   msg.setTemplateID(emailTemplate_Map.get(LeadTypeTemplateName).Id);
               }
            //Setting the org wide email
            String fromEmail = newEBSorderMap.get(orderId).From_Email__c;
            if(OWEToEmail_map.containsKey(fromEmail)){
                msg.setOrgWideEmailAddressId(OWEToEmail_map.get(fromEmail).id);
            }
            //Linking the Email activity with the EBS order
            msg.setWhatId(orderId);
            EmailList.add(msg);
        }
        //send emails, capture its results and log exceptions.
        if (!EmailList.isEmpty()) {
            Messaging.SendEmailResult[] EmailResults = Messaging.sendEmail(EmailList,false);
            system.debug('EmailResults='+EmailResults);
            for(Messaging.SendEmailResult res : EmailResults){
                if(!res.isSuccess()){
                    system.debug('Email sending failed');
                    for(Messaging.SendEmailError err : res.getErrors()){
                        ApexLogUtill.createApexLog(
                            'Ship Date Notification- LeadTimeAutomation.apex', 
                            '', 
                            '', 
                            String.valueOf(err.getTargetObjectId()), 
                            'Contact', 
                            err.getMessage(), 
                            0
                        );
                    }
                }
            }
        }
        
        
        //create notification records
        List<Notification__c> notifList = new List<Notification__c>();
        for(Id ebsId : ebsIdVsOrderLineMap.keyset()){
            Notification__c notifObj = new Notification__c();
            notifObj.Notification_Type__c = 'Lead Time Automation';
            notifObj.EBS_Order__c = ebsId;
            notifObj.Notif_Send_Resend_Date__c = System.now();
            notifObj.Is_Sent__c = False;
            notifObj.Template_Name__c = newEBSorderMap.get(ebsId).Lead_Time_Template__c;
            if(newEBSorderMap.containsKey(ebsId)){
                notifObj.Email_Recipient__c = newEBSorderMap.get(ebsId).Acc_PO_Contact_To_Email__c;
            }
            
            String templateName = newEBSorderMap.get(ebsId).Lead_Time_Template__c;
            Messaging.SingleEmailMessage emailRecord = Messaging.renderStoredEmailTemplate(emailTemplate_Map.get(templateName).Id,newEBSorderMap.get(ebsId).PO_Contact__c,ebsId);
            notifObj.Subject__c = emailRecord.getSubject();
            notifObj.Email_Body__c = emailRecord.getHtmlBody();
            notifObj.Status__c = 'delivered';
            notifList.add(notifObj);
        }
        if (!notifList.isEmpty()) {
            try {
                database.insert(notifList,false);
            } catch (Exception exp) {
                System.debug(exp.getMessage());
            }
        }
    }
}