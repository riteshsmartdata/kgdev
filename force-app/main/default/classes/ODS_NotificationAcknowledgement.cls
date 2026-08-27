/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 01-19-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ODS_NotificationAcknowledgement {


    /**
     * Description: method is used in flow (Name : S3: ODS Notification Acknowledgement)
     * Param : notificationList :hold notification record list
     */
    
    @InvocableMethod(label = 'Send Notification Status to ODS' description='Sync Notification status to ODS system')
    public static void sendNotificationStatus(List<Notification__c> notificationList){ 
        System.debug('==== sendNotificationStatus ====='+notificationList); 
        Contact_And_Contact_Role_Settings__mdt jsonSetting = new Contact_And_Contact_Role_Settings__mdt(); 
       // jsonSetting =  [SELECT id, API_Key__c, Collection__c, Database__c, Data_Source__c, End_Point__c FROM Contact_And_Contact_Role_Settings__mdt WHERE DeveloperName = 'ODS_NotificationAcknowledgement' LIMIT 1];
        jsonSetting =  [
            SELECT id, API_Key__c, Collection__c, Database__c, Data_Source__c, End_Point__c
            FROM Contact_And_Contact_Role_Settings__mdt
            WHERE DeveloperName = :(
                KoozieUtility.isSandbox()
                ? 'ODS_NotificationAcknowledgement_FullCopy'
                : 'ODS_NotificationAcknowledgement'
            )
            LIMIT 1
        ];

        if(notificationList.size() >= 1){
            for(Notification__c notification : notificationList){
                odsCallOut( genrateJSON(notification, jsonSetting), jsonSetting.End_Point__c,jsonSetting.API_Key__c, (String) notification.Id);
            }
        } 
    } 

    /**
     * Description : Method is used to send notification information to ODS system.
     * Param : 1) requestBody: hold json body, 2) apiKey : hold access key, 3) recordId : hold notification record id.
     */

    @future(callout = true)
    public static void odsCallOut(String requestBody, String endURL, String apiKey, String  recordId) {
        
        System.debug('==== odsCallOut ====='+requestBody); 
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(endURL);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('api-key', apiKey);   
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        System.debug('==== Notification Acknowledgement boday  ====='+response.getBody());
        System.debug('==== Notification Acknowledgement status Code  ====='+response.getStatusCode());

        /**
         * if the callout fails then apex logs are created
         */
        if(! KoozieConstants.SUCCESS_CODES.contains(response.getStatusCode())){ 
            ApexLogUtill.createApexLog('ODS : Notification Acknowledgement', requestBody, response.getBody(), recordId, 'Notification__c', response.getBody(), response.getStatusCode());
        }
    } 
    
    /**
     * Description : Method is used to genrate request body, which we send to ODS system.
     * Param : 1) notification : hold current notification record. 2) jsonSetting : Hold API nformation.
     */
    public static String genrateJSON(Notification__c notification, Contact_And_Contact_Role_Settings__mdt jsonSetting){  
        System.debug('======== jsonSetting ======='+jsonSetting);
        String json = ''; 
        json += '{"dataSource":"'+jsonSetting.Data_Source__c+'","collection":"'+jsonSetting.Collection__c+'","database":"'+jsonSetting.Database__c+'","filter":{"_id":{"$oid":"'+notification.ODS_ID__c+'"}},"update":{"$set":{"notification.status":"'+notification.Status__c+'","notification.deliveredAt":{"$date":{"$numberLong":"'+notification.Notif_Send_Resend_Date__c.getTime()+'"}}}}}';
        System.debug('======= Request Body ======='+JSON);
        return json;
    }
    
}