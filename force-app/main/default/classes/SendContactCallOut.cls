/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 11-13-2023
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   10-25-2023   Ritesh Kumar   Initial Version
**/
public without sharing class SendContactCallOut {
    
    final static public String INSERT_DML = 'INSERT';
    final static public String UPDATE_DML = 'UPDATE';
    final static public String CRM_CONTACT = 'CRM Contact'; 
    
    public static Boolean isfirstRun = true; 
    public enum DML_MODE{INSERT_MODE,UPDATE_MODE}
    
    
    /**
    * @desription :    runBatch accepts class name and job type, based on the input it will check the job, 
    *                  if the job is running then it will quit the process and if it is not running then it will run the job.
    * @Parameters :    Accept two parameters and first is class name and second is jobtype both are string type.
    */
    private static void runBatch(){ 
        Id jobIdVariable = System.enqueueJob(new ContactQueueable());
       // System.debug(LoggingLevel.INFO,'==== runBatch : Sync Contact Queueable ID : '+jobIdVariable);
    }
    
    private static Contact apiCallout(Contact contactRecord, SendContactCallOut.DML_MODE dmlmode, String websiteCallout){
        
       // System.debug(LoggingLevel.INFO,'==== apiCallout: contactRecord : '+contactRecord);
       // System.debug(LoggingLevel.INFO,'==== apiCallout: dmlmode : '+dmlmode);
       // System.debug(LoggingLevel.INFO,'==== apiCallout: websiteCallout : '+websiteCallout);
       // System.debug(LoggingLevel.INFO,'==== apiCallout: System.isFuture() : '+System.isFuture());
        Contact tempRecord = new Contact();
        switch on dmlmode {
            when INSERT_MODE{
                
                if((!System.isFuture()) && contactRecord.isBatchRunning__c == false && contactRecord.recordTypeID == getRecordTypeID(CRM_CONTACT)){ 
                    ContactCallOutHandler.contactCallOutSync(JSON.serialize(contactRecord), INSERT_DML, '',websiteCallout);
                }else{
                    tempRecord.Id = contactRecord.Id;
                    tempRecord.API_Callout_Required__c = TRUE;
                }
            }
            
            when UPDATE_MODE{
                if((!System.isFuture()) && contactRecord.isBatchRunning__c == false && contactRecord.recordTypeID == getRecordTypeID(CRM_CONTACT)){
                    
                    ContactCallOutHandler.contactCallOutSync(JSON.serialize(contactRecord), UPDATE_DML, '',websiteCallout );
                }else{
                    tempRecord.Id = contactRecord.Id;
                    tempRecord.API_Callout_Required__c = TRUE;
                }
            }
            
        }        
        
       // System.debug(LoggingLevel.INFO,'==== apiCallout: tempRecord : '+tempRecord);
        Return tempRecord;
    }
    
    private static String getRecordTypeID(String recordTypeName){
       // System.debug(LoggingLevel.INFO,'==== getRecordTypeID: recordTypeName : '+recordTypeName);
        String typeId ='';
        typeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
       // System.debug(LoggingLevel.INFO,'==== getRecordTypeID: typeId : '+typeId);
        Return typeId;
    }
    
    private static void updateRequest(List<Contact> newContactList, Map<Id, Contact> oldContactMap){
        
       // System.debug(LoggingLevel.INFO,'==== updateRequest: typeId : '+newContactList);
       // System.debug(LoggingLevel.INFO,'==== updateRequest: typeId : '+oldContactMap);
        List<Contact> updateContactList = new List<Contact>();
        
        for(Contact contactRecord : newContactList){
            Set<String> fieldDifference = new Set<String>();
            String websiteCallout = '';
            Contact tempRecord = new Contact();
            
            // Check field difference for website integration
            websiteCallout = ContactUtill.getFieldDifference(contactRecord, oldContactMap.get(contactRecord.Id)).size() > 0 ? 'Yes':'No';
            
            if (websiteCallout == 'Yes'){
                tempRecord =  apiCallout(contactRecord,SendContactCallOut.DML_MODE.UPDATE_MODE,websiteCallout);
                if(tempRecord.API_Callout_Required__c  == TRUE){
                    updateContactList.add(tempRecord);
                }
            } 
        }
        if(updateContactList.size() > 0){
            Database.SaveResult[] updatedRecords = Database.Update(updateContactList, false);
            Boolean runBatch = FALSE; 
            for (Database.SaveResult record : updatedRecords) {
                if (record.isSuccess()) {
                    runBatch = TRUE; 
                   // System.debug(LoggingLevel.INFO,'==== updateRequest: Updated Record : '+record.getId());
                }
            }
            if(runBatch){
                runBatch();
            } 
        }
    }
    
    private static void insertRequest(List<Contact> newContactList){
        
       // System.debug(LoggingLevel.INFO,'==== insertRequest: newContactList : '+newContactList);
        List<Contact> insertContactList = new List<Contact>();
        for(Contact contactRecord : newContactList){
            Contact tempRecord = new Contact();
            
            tempRecord =  apiCallout(contactRecord, SendContactCallOut.DML_MODE.INSERT_MODE,'');
            
            if(tempRecord.API_Callout_Required__c  == TRUE){
                insertContactList.add(tempRecord);                
            }
        } 
        
        if(insertContactList.size() > 0){
            Database.SaveResult[] insertedRecords = Database.Update(insertContactList, false);
            Boolean runBatch = FALSE; 
            for (Database.SaveResult record : insertedRecords) {
                if (record.isSuccess()) {
                    runBatch = TRUE; 
                   // System.debug(LoggingLevel.INFO,'==== updateRequest: Inserted Record : '+record.getId());
                }
            }
            
            if(runBatch){
                runBatch();
            }
            
        }
    } 
    
    public static void sendContactInformation(List<Contact> newContactList, Map<Id, Contact> oldContactMap, String operationMode){ 
        
       // System.debug(LoggingLevel.INFO,'==== sendContactInformation: newContactList : '+newContactList);
       // System.debug(LoggingLevel.INFO,'==== sendContactInformation: oldContactMap : '+oldContactMap);
       // System.debug(LoggingLevel.INFO,'==== sendContactInformation: operationMode : '+operationMode);
        switch on operationMode {
            when 'UPDATE'  {
                updateRequest(newContactList, oldContactMap);                
            } 
            
            when 'INSERT' {
                insertRequest(newContactList);
            }
        }
    }
    
}