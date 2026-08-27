/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-03-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public with sharing class ApexLogUtill {
     
    public static void createApexLog(String source, String requestBody, String resopnseBody, String recordId, String objectName, String error, Integer statusCode){
        //System.debug('======createApexLog==== ');
        Apex_Errors__c log = new Apex_Errors__c();
        log.Error_Date_Time__c= System.today();
        log.Error_Message__c = error;
        log.Object_API_Name__c = objectName;
        log.Record_ID__c = recordId;
        log.Response_Body__c = resopnseBody;
        log.Request_Body__c = requestBody;
        log.Source__c = source;
        log.Status_Code__c = statusCode;
        Insert log;
        //System.debug('=====Apex Log Id==== '+log.Id);
    } 
    
    
    public static Apex_Errors__c assignApexLog(String source, String requestBody, String resopnseBody, String recordId, String objectName, String error, Integer statusCode){
        //System.debug('======createApexLog==== ');
        Apex_Errors__c log = new Apex_Errors__c();
        log.Error_Date_Time__c= System.today();
        log.Error_Message__c = error;
        log.Object_API_Name__c = objectName;
        log.Record_ID__c = recordId;
        log.Response_Body__c = resopnseBody;
        log.Request_Body__c = requestBody;
        log.Source__c = source;
        log.Status_Code__c = statusCode;
        return log;
        //System.debug('=====Apex Log Id==== '+log.Id);
    } 

    public static void createApexLogs(List<LogInput> errorLogList){
        List<Apex_Errors__c> logList = new List<Apex_Errors__c>();
        for(LogInput error : errorLogList){
            Apex_Errors__c log = new Apex_Errors__c();
            log.Error_Date_Time__c= System.today();
             
            log.Object_API_Name__c = error.objectName;
            log.Record_ID__c = error.recordId;
            log.Response_Body__c = error.resopnseBody;
            log.Request_Body__c = error.requestBody;
            log.Source__c = error.source;
            log.Status_Code__c = error.statusCode;
            if(error.source != null && error.source != ''){
                logList.add(log);
            } 

        }
 
        if(logList.size() >0){
            Database.insert(logList);
        }
    } 
    
}