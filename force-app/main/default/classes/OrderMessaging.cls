/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 09-04-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
public with sharing class OrderMessaging {

    @AuraEnabled
    public static String getMessagingSessionId(String recordId){
        String messagingSessionId = '';
        String endUserId = '';
        if(String.isNotBlank(recordId)){ 
             

            for(EBS_Order__c order : [
                    SELECT Id, PO_Contact__c 
                    FROM EBS_Order__c 
                    WHERE Id =: recordId AND 
                    PO_Contact__c != NULL 
            ]){
                endUserId = order.PO_Contact__c;
            } 

        }
        System.debug(LoggingLevel.INFO, '===== endUserId: '+endUserId);
        if(String.isNotBlank(endUserId)){ 
            for(MessagingSession messageData : [
                SELECT Id, EndUserContactId 
                FROM MessagingSession 
                WHERE EndUserContactId =: endUserId ORDER BY CreatedDate DESC LIMIT 1
            ]) { 
                messagingSessionId = messageData.Id;
            } 
            
        }
        System.debug(LoggingLevel.INFO, '===== messagingSessionId: '+messagingSessionId);
        Return messagingSessionId;

    }

 

    @AuraEnabled
    public static MessagingSession getRecentMessagingSession(String recordId){
        MessagingSession msg = new MessagingSession();
        String endUserId = '';
        if(String.isNotBlank(recordId)){ 
             

            for(EBS_Order__c order : [
                    SELECT Id, PO_Contact__c 
                    FROM EBS_Order__c 
                    WHERE Id =: recordId AND 
                    PO_Contact__c != NULL 
            ]){
                endUserId = order.PO_Contact__c;
            } 

        }

         for(MessagingSession messageData : [
            SELECT ChannelEndUserFormula, ChannelKey, ConversationId, MessagingEndUserId, SessionKey, Status, PreviewDetails
            FROM MessagingSession 
            WHERE EndUserContactId =: endUserId ORDER BY CreatedDate DESC LIMIT 1
        ]){ 
            msg = messageData;
        }

        return msg;

    }
}