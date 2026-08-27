/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : Ritesh Kumar
**/
public class sendResendEmail {  

    /**
     * Description : method used to send/resend email notification & is used in the flow : Email Notification Screen-flow
     * Param : notificationList holds Notification Ids
     */

    @InvocableMethod(label='Send Email')
    public static void sendEmail(List<String> notificationList){
        
       System.debug('======= sendResendEmail: sendEmail =======');
       System.debug('======= sendResendEmail: notificationList ======='+notificationList);

        Set<String> notificationRecordIdSet = new Set<String>(); 
        Set<Messaging.SingleEmailMessage> emailSet = new set<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailReadyToSent = new List<Messaging.SingleEmailMessage>();
        List<Notification__c> updatedNotificationList = new List<Notification__c>(); 
        Map<String, OrgWideEmailAddress> orgWideEmailAddressMap = new Map<String,OrgWideEmailAddress>();  
       
        for(OrgWideEmailAddress owea: [SELECT Id,Address FROM OrgWideEmailAddress]){
            orgWideEmailAddressMap.put(owea.Address,owea );
        }

       System.debug('======= sendResendEmail: orgWideEmailAddressMap ======='+orgWideEmailAddressMap);
        

        if(notificationList.size() > 0){
            for(String recordId : notificationList){
                if(String.isNotBlank(recordId)){
                    notificationRecordIdSet.addAll(recordId.split(';'));
                } 
            } 
        } 

       System.debug('======= sendResendEmail: notificationRecordIdSet ======='+notificationRecordIdSet);

        if(notificationRecordIdSet.size() > 0 ){
            for(Notification__c notification : [ 
                SELECT  
                    Id, Name,EBS_Order__c,EBS_Order_Contact__c,Email_Body__c,Email_Identifier__c,From_Address__c,
                    Notification_Type__c, Email_Recipient__c,Subject__c,Template_Id__c,Template_Name__c,Is_Sent__c, Notif_Send_Resend_Date__c 
                FROM Notification__c 
                WHERE 
                    Id IN: notificationRecordIdSet LIMIT 50000
            ]){ 
               System.debug('======= sendResendEmail: notification.Template_Id__c ======='+notification.Template_Id__c);
               System.debug('======= sendResendEmail: notification.EBS_Order_Contact__c ======='+notification.EBS_Order_Contact__c);
               System.debug('======= sendResendEmail: notification.EBS_Order__c ======='+notification.EBS_Order__c);
                
                Messaging.SingleEmailMessage emailRecord = Messaging.renderStoredEmailTemplate(notification.Template_Id__c,notification.EBS_Order_Contact__c,notification.EBS_Order__c);
                emailRecord.setOrgWideEmailAddressId(orgWideEmailAddressMap.get(notification.From_Address__c).Id);
                List<String>  toEmail = new List<String>(); 
                toEmail.addALL(notification.Email_Recipient__c.split(', '));
               System.debug('======= sendResendEmail: toEmail ======='+toEmail);
                if(!toEmail.isEmpty()){
                    emailRecord.setToAddresses(toEmail);  
                    emailRecord.setSaveAsActivity(true);  
                    emailSet.add(emailRecord); 
                    
                    Notification__c tempVar = new Notification__c();
                    tempVar.Id = notification.Id;
                    tempVar.Notif_Send_Resend_Date__c = System.now();
                    tempVar.Status__c = 'Resent';
                    updatedNotificationList.add(tempVar);
                }
            }
        }
       System.debug('======= sendResendEmail: emailSet ======='+emailSet);

        if(emailSet.size() > 0){
            emailReadyToSent.addAll(emailSet);
            Messaging.sendEmail(emailReadyToSent);

            if(!updatedNotificationList.isEmpty()){
                Database.update (updatedNotificationList,false);
            }
        } 
       System.debug('======= sendResendEmail: END =======');
    } 
}