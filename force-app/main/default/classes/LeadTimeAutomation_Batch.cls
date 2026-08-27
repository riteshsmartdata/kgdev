/**
 * @description       : 
 * @author            : Nitesh
 * @group             : 
 * @last modified on  : 03-01-2023
 * @last modified by  : Nitesh
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   02-27-2023   Nitesh   Initial Version
**/
public class LeadTimeAutomation_Batch implements Database.Batchable<SObject>,Database.Stateful, Database.AllowsCallouts {
    Set<String> orderHeader = new Set<String>{'CANCELLED','CLOSED'};
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('BATCH START METHOD');
        return Database.getQueryLocator('SELECT Id,From_Email__c,PO_Contact__c,PO_Contact_Email__c, Template_Type__c,Acc_PO_Contact_To_Email__c, Order_Confirmation_Email__c,Shipping_Notification_Email__c,Template_Name__c,Send_Lead_Time_Notification__c,Lead_Time_Template__c FROM EBS_Order__c WHERE Send_Lead_Time_Notification__c = true AND Order_Header_Status__c NOT IN: orderHeader AND  PO_Contact__c != null');
    }
    public void execute(Database.BatchableContext BC, List<EBS_Order__c> ebsList){
        system.debug('BATCH list==='+ebsList);
        Map<Id, EBS_Order__c> EbsOrderMap = new Map<Id, EBS_Order__c>();
        Map<Id,Id> SuccessEbsIdMap = new Map<Id,Id>();
        Set<Id> failedEbsIdSet = new Set<Id>();
        for (EBS_Order__c sObj : ebsList) {
            sObj.Send_Lead_Time_Notification__c = false;
            EbsOrderMap.put(sObj.Id,sObj);
        }
        Database.SaveResult[] results = Database.update(ebsList, false);
        System.debug('results='+results);
        for (Database.SaveResult sr : results) {
            if(sr.isSuccess()){//if success
                SuccessEbsIdMap.put(sr.id,sr.id);
            }else if(!sr.isSuccess()){ //if failure
                failedEbsIdSet.add(sr.id);
            }
        }
        //Get Org Wide Email List to set the FROM email
        List<OrgWideEmailAddress> allOWE = [SELECT Id, Address, DisplayName 
        FROM OrgWideEmailAddress];
        Map<String, OrgWideEmailAddress> OWEToEmail_map = new Map<String, OrgWideEmailAddress>();
        
        //Loop and add to OWE Map
        for(OrgWideEmailAddress owe : allOWE){
            OWEToEmail_map.put(owe.Address, owe);
        }
        system.debug('OWEToEmail_map==='+OWEToEmail_map);

        //Query and prepare Map of custom metadata type for Email templates.
        Map<String,Email_Template_Setting__mdt> emailTemplateMdt_Map = new Map<String,Email_Template_Setting__mdt>();
        Email_Template_Setting__mdt[] temp_mdt = [SELECT Id, MasterLabel, Template_Name__c,Template_Type__c, Email_Category__c 
                                                    FROM Email_Template_Setting__mdt
                                                    WHERE Email_Category__c='Inventory Hold'  LIMIT 1000];
        for(Email_Template_Setting__mdt rec : temp_mdt) {
            emailTemplateMdt_Map.put(rec.Template_Type__c, rec);
        }

        Map<String,EmailTemplate> emailTemplate_Map = new Map<String,EmailTemplate>();
        //Query all the Lightning email template used in Inventory Hold Lead Time Automations folder
        EmailTemplate[] emailTemplate = [Select Body, DeveloperName, HtmlValue, Id, Name, Subject, TemplateType, TemplateStyle
                                         From EmailTemplate WHERE Folder.Name='Inventory Hold Lead Time Automations' LIMIT 1000];
        for(EmailTemplate emp : emailTemplate){
            emailTemplate_Map.put(emp.Name,emp);
        }
        System.debug('email template=='+emailTemplate);
        //Send Email for all success
        List<Messaging.SingleEmailMessage> EmailList = new List<Messaging.SingleEmailMessage>();
        for (Id ebsId : SuccessEbsIdMap.keySet()){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            if (EbsOrderMap.containsKey(ebsId)) {
                //PO contact email is contained within the Acc_PO_Contact_To_Email__c
                String AccPoContactToEmail = EbsOrderMap.get(ebsId).Acc_PO_Contact_To_Email__c;
                
                /*if (String.isNotBlank(AccPoContactToEmail)) {
                    String [] toEmail = AccPoContactToEmail.split(', ');
                    msg.setToAddresses(toEmail);
                }*/
                Id poId = EbsOrderMap.get(ebsId).PO_Contact__c;
                if (poId != null) {
                    msg.setTargetObjectId(poId);
                }
                //Get the Lead time automation template
                String templateType = EbsOrderMap.get(ebsId).Template_Type__c;
                String LeadTypeTemplateName = emailTemplateMdt_Map.get(templateType).Template_Name__c;
                system.debug('Lead_Time_Template__c===='+LeadTypeTemplateName);
                //set the email template
                if(String.isNotBlank(LeadTypeTemplateName) && 
                   emailTemplate_Map.containsKey(LeadTypeTemplateName)){
                    msg.setTemplateID(emailTemplate_Map.get(LeadTypeTemplateName).Id);
                }
            }
            //Setting the org wide email
            String fromEmail = EbsOrderMap.get(ebsId).From_Email__c;
            if(OWEToEmail_map.containsKey(fromEmail)){
                msg.setOrgWideEmailAddressId(OWEToEmail_map.get(fromEmail).id);
            }
            //Linking the Email activity with the EBS order
            msg.setWhatId(ebsId);
            //msg.setHtmlBody(param1)
            EmailList.add(msg);
        }
        system.debug('email list =='+EmailList);
        //send emails and capture its results.
        Messaging.SendEmailResult[] EmailResults = Messaging.sendEmail(EmailList);
        System.debug('EmailResults=='+EmailResults);
        List<Notification__c> notifList = new List<Notification__c>();
        //create notification records for all the success emails
        for (Id ebsId : SuccessEbsIdMap.keySet()) {
            //EBS_Order_Contact__c = Order Po Contact 
            Notification__c notifObj = new Notification__c();
            notifObj.Notification_Type__c = 'Lead Time Automation';
            notifObj.EBS_Order__c = ebsId;
            notifObj.Notif_Send_Resend_Date__c = System.now();
            notifObj.Is_Sent__c = False;
            String templateType = EbsOrderMap.get(ebsId).Template_Type__c;
            notifObj.Template_Name__c = emailTemplateMdt_Map.get(templateType).Template_Name__c;
            if(EbsOrderMap.containsKey(ebsId)){
                notifObj.Email_Recipient__c = EbsOrderMap.get(ebsId).Acc_PO_Contact_To_Email__c;
            }
           
            String templateName = emailTemplateMdt_Map.get(templateType).Template_Name__c;
            Messaging.SingleEmailMessage emailRecord = Messaging.renderStoredEmailTemplate(emailTemplate_Map.get(templateName).Id,EbsOrderMap.get(ebsId).PO_Contact__c,ebsId);
            System.debug('rendered email ---'+emailRecord);
            System.debug('subject=='+emailRecord.getSubject());
            System.debug('HTML body===='+emailRecord.getHtmlBody());
            notifObj.Subject__c = emailRecord.getSubject();
            notifObj.Email_Body__c = emailRecord.getHtmlBody();
            //notifObj.
            notifList.add(notifObj);
        }
        try {
            Database.insert(notifList,false);
        } catch (Exception exp) {
            System.debug(exp.getMessage());
            System.debug(exp.getLineNumber());
        }
        System.debug('notif list ---'+notifList);
    }
    public void finish(Database.BatchableContext BC){
        System.debug('***Batch Finished***');
    }
}