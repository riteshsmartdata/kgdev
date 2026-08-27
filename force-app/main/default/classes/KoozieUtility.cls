/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 10-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-07-2023   Ritesh Kumar   Initial Version
**/
public without sharing class KoozieUtility {
    public Static Boolean isRecursion = TRUE;
    
    public Static Set<String> recursionSet = new Set<String>();
    public static Boolean isAsyncApexRunning(String apexClassName, String jobType){ 
        //System.debug(LoggingLevel.INFO,'==== isAsyncApexRunning : apexClassName : '+apexClassName);
        //System.debug(LoggingLevel.INFO,'==== isAsyncApexRunning : jobType : '+jobType);
        AsyncApexJob [] apexJob =  [
            SELECT 
                Status, ApexClass.Name,Id, JobType
            FROM 
                AsyncApexJob 
            WHERE 
                Status != 'Completed' AND 
                ApexClass.Name =: apexClassName AND 
                JobType =:jobType  WITH SECURITY_ENFORCED LIMIT 2
        ];

        Boolean t = apexJob.size() > 0 ? TRUE: FALSE;
        //System.debug(LoggingLevel.INFO,'==== isAsyncApexRunning : apexJob : ' + t);
        Return apexJob.size() > 0 ? TRUE: FALSE; 
    }
    
    /**
    * @description       : This method is used to get the record type id based on recordtype name and object.
    * @Parameters        : Accept three parameters and first is object api name and second is record type name.
    */
    public static String getRecordTypeId(String objectAPI, String recordtypeName){
        String recordId ='';
        recordId = Schema.getGlobalDescribe().get(objectAPI).getDescribe().getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
        return recordId; 
    }

    public static Boolean isSandbox(){ 
        Boolean isSandbox = TRUE;
       	Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1]; 
        if(org != null){
            isSandbox = org.IsSandbox;
        } 
        return isSandbox;
    }

    /**
    * @description       : This method is used to get the object name based on salesforce record Id.
    * @Parameters        : Accept Record id as parameter.
    */
    public static String getObjectNameById(String recordId){ 
        Id currentRecordId = Id.valueOf(recordId); 
        String objectName = currentRecordId.getSObjectType().getDescribe().getName();
        System.debug(LoggingLevel.INFO,'==== Object Name ===== : ' + objectName);
        return objectName;
    }

    public static String getRecordTypeName(String objectName, Id strRecordTypeId){
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }

    /*
    * @description : This method will give you all the fields of Contact Object
    * @paramerters : Accepts SObjectAPI Name and record Id of the record
    */
    public static List<SObject> getAllFieldValues(String objectApi,Id recordId){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectAPI);
        List<String> objectFields = new List<string>(objectType.getDescribe().fields.getMap().keySet());
        String soql = 'SELECT ' + String.join(objectFields, ',') + ' FROM ' + objectApi + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
        List<SObject> result = Database.query(soql);
        return result;
    }

    /** @description : This method will give you all the fields of Contact Object
    * @paramerters : Accepts SObjectAPI Name and record Id of the record
    */
    public static ZipCode__c getZipCode (String zipCode){
        ZipCode__c [] zipList = [SELECT ID, Zip__c,Country__c,Country_Abbre__c,State_Abbre__c,State_Name__c FROM ZipCode__c WHERE Zip__c =:zipCode LIMIT 1];
        if(zipList != null && zipList.size() > 0){
            return zipList[0];
        }
        return null;
    }
}