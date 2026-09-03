/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 01-22-2026
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-16-2023   Ritesh Kumar   Initial Version
**/
public without sharing class DeleteContactRoleODS  {
    @TestVisible
    private static LogInput deleteOdsContactRole( String ContactId){ 
       // Contact_And_Contact_Role_Settings__mdt  API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');
        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance(KoozieUtility.isSandbox() ? 'Send_Contact_Role_Information_Full_Copy' : 'Send_Contact_Role_Information');
        LogInput errorLog = new LogInput(); 
        Set<Integer> successStatusCode = new Set<Integer>{200, 201};

        String endpoint = API_SETTING.End_Point__c+'action/deleteOne';
       
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('api-key', API_SETTING.API_Key__c);  
        request.setBody(genrateDeleteJSON(ContactId, API_SETTING));
        request.setTimeout(120000);
         
        HttpResponse response = http.send(request);
        if( !successStatusCode.contains(response.getStatusCode())){  
            errorLog.source = 'ODS : Single Contact Role Delete';
            errorLog.requestBody = genrateDeleteJSON(ContactId, API_SETTING);
            errorLog.resopnseBody =  response.toString();
            errorLog.recordId = ContactId;
            errorLog.objectName = 'Contact_Roles__c';
            errorLog.statusCode = response.getStatusCode(); 
        } 
        System.debug('== Status Code====='+response.getStatusCode());
        System.debug('== Response Body ====='+response.getBody());
        return errorLog;

    }
    @TestVisible
    private static String genrateDeleteJSON(String contactId, Contact_And_Contact_Role_Settings__mdt API_SETTING){
        String deleteJSON  = ''; 
        deleteJSON =+ '{ "dataSource": "'+API_SETTING.Data_Source__c+'","collection": "'+API_SETTING.Collection__c+'","database": "'+ API_SETTING.Database__c+'","filter": { "recordId": "'+contactId+'" }}';
        System.debug('===== JSON ====='+deleteJSON);
        return deleteJSON;

    } 
    
 
    public static void syncContactRoleThroughBatch(String contactRoleId ){
         
        List<LogInput> errorLogList = new List<LogInput>();
        
        if(String.isNotBlank(contactRoleId) ){
            errorLogList.add(deleteOdsContactRole(contactRoleId));
        }
        
        
        if(errorLogList.size() > 0){
            ApexLogUtill.createApexLogs(errorLogList);
        }
    }
}