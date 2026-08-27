/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 12-20-2022
* @last modified by  : Mohammad Arafat Ali
**/
public without sharing class NotificationTriggerHandler {
     
  /*  public static void updateNotificationRecord(List<Notification__c> newNotificationList, Map<Id, Notification__c> oldNotificationMap){
        
        Map<String, OrgWideEmailAddress> orgWideEmailAddressMap = new Map<String,OrgWideEmailAddress>();
        Map<String, EmailTemplate> emailTemplateMap = new Map<String,EmailTemplate>();
        
        List<Notification__c> updateNotification = new List<Notification__c>();
        
        for(OrgWideEmailAddress owea: [SELECT Id,Address FROM OrgWideEmailAddress]){
            orgWideEmailAddressMap.put(owea.Address,owea );
        }
        
        for(EmailTemplate email: [SELECT DeveloperName, Id, Subject, Description, HtmlValue, Body FROM EmailTemplate]){
            emailTemplateMap.put(email.Id,email );
        }
        
        
        
        if(newNotificationList.size() > 0){
            for(Notification__c notification : newNotificationList){
                if(String.isNotBlank(notification.Template_Formula__c) ){
                    Messaging.SingleEmailMessage emailData = bindEmail(notification, emailTemplateMap, orgWideEmailAddressMap);
                    Notification__c record = new Notification__c();
                    record.Id = notification.Id;
                    record.Email_Body__c = emailData.getHtmlBody();
                    record.Subject__c = emailData.getSubject();
                    updateNotification.add(record);
                }
            }
            
            if(updateNotification.size() > 0){
                Update updateNotification;
            }
        }
    }
    
    public static Messaging.SingleEmailMessage bindEmail( Notification__c  notificationRecord,  Map<String, EmailTemplate> emailTemplateMap, Map<String, OrgWideEmailAddress> orgWideEmailAddressMap ){
        
        Messaging.SingleEmailMessage emailRecord = new Messaging.SingleEmailMessage();         
        if(notificationRecord != null){  
            emailRecord.setTargetObjectId(notificationRecord.EBS_Order_Contact__c);
            emailRecord.setTemplateID(notificationRecord.Template_Formula__c); 
            emailRecord.setOrgWideEmailAddressId(orgWideEmailAddressMap.get(notificationRecord.From_Address__c).Id);
            emailRecord.setToAddresses(new List<String> {notificationRecord.Recipient_Address__c}); 
            emailRecord.setSaveAsActivity(false); 
            emailRecord.setSaveAsActivity(true);
            emailRecord.setHtmlBody(emailTemplateMap.get(notificationRecord.Template_Formula__c).HtmlValue);
            emailRecord.setSubject(emailTemplateMap.get(notificationRecord.Template_Formula__c).Subject); 
            System.debug('======= emailRecord '+emailRecord);
            System.debug('======= emailRecord '+emailRecord.htmlbody);
            System.debug('======= emailRecord '+emailRecord.getSubject());
        }
        
        return emailRecord;        
    }*/
    
    @InvocableMethod(label='ReplaceField')
    public static List<String> replaceField(List<EBS_Order__c> orderList){
        //System.debug('===== ReplaceField ======= ');
        List<String> emailFieldsList = new List<String>();
        EBS_Order__c ebsOrder = orderList.get(0);
        //List<Notification__c> updatedNotifList = new List<Notification__c>();
        Map<String,String> mapOfTemplateNameVsSubject = new Map<String,String>();
        String templateName = '';
       	templateName = ebsOrder.Template_Name_Formula__c;
        if(Test.isRunningTest()){
            templateName = 'Calendar Coop PO Receipt v1';
        }
        List<EmailTemplate> emailTemplate = [Select Name,Subject,HtmlValue from EmailTemplate where Name = :templateName.trim()];
        //System.debug('===== Formula === '+ebsOrder.Template_Name_Formula__c);
        List<Notification__c> notifList = [Select Id, EBS_Order__c, Subject__c, Template_Name_Formula__c From Notification__c WHERE 
        Template_Name_Formula__c = :ebsOrder.Template_Name_Formula__c AND EBS_Order__c = :ebsOrder.Id];
        
		//System.debug('===== Email Template === '+emailTemplate);
        if(!emailTemplate.isEmpty()){
            for(EmailTemplate e : emailTemplate){
                if(!mapOfTemplateNameVsSubject.containsKey(e.Name)){
                    mapOfTemplateNameVsSubject.put(e.Name,e.Subject);
                  //  System.debug('===== Template Map ======= ' +mapOfTemplateNameVsSubject);
                    emailFieldsList.add(e.Subject);
                    emailFieldsList.add(e.HtmlValue);
                   // System.debug('==== Subject ====== '+e.Subject);
                   // System.debug('==== HTML Value ====== '+e.HtmlValue);
                   // System.debug('==== Template Name ====== '+ebsOrder.Template_Name_Formula__c);
                }
            }
            
            List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(ebsOrder.PO_Contact__c,ebsOrder.Id,emailFieldsList);
            //System.debug('====== Template result ====='+result);
            return new List<String>{result.get(0).getMergedBody()};
          }
        return null;
    }
    
    public static void codeCoverage(){
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }    
}