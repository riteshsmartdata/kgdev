/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 12-16-2022
* @last modified by  : Ritesh Kumar
**/
public class ContactCallOutHandler { 
    
    @future(callout=true)
    public static void contactCallOutSync( String recordJSON, String crudMode, String objectFields, String websiteCallout ){
        
        Contact contactRecord = new Contact();
        Set<String> fieldsSet = new Set<String>();
        List<LogInput> errorLogList = new List<LogInput>();
        
        if(String.isNotBlank(recordJSON)){
            contactRecord =  (Contact)JSON.deserialize(recordJSON, Contact.Class);
        }
        
        //System.debug('======= contactCallOutSync contactRecord ====== '+contactRecord);
        
        if(String.isNotBlank(objectFields)){
            fieldsSet =   (Set<String>) JSON.deserialize(objectFields, Set<String>.Class);
        }
        
        //System.debug('======= contactCallOutSync fieldsSet ====== '+fieldsSet);
        
        Map<String,Callout_Handler_Setting__mdt> calloutSettingMap = new Map<String,Callout_Handler_Setting__mdt>() ; 
        
        for(Callout_Handler_Setting__mdt calloutSetting : [SELECT API_Method_Name__c,Is_Active__c FROM Callout_Handler_Setting__mdt]){
            calloutSettingMap.put(calloutSetting.API_Method_Name__c,calloutSetting); 
        }
        
        //System.debug('=======  contactCallOutSynccalloutSettingMap ====== '+calloutSettingMap);
        
        // Callout for ODS System 
        if(calloutSettingMap.containsKey('generateJSONForSingleContactInsert') && calloutSettingMap.get('generateJSONForSingleContactInsert').Is_Active__c){
            //System.debug('======= contactCallOutSync generateJSONForSingleContactInsert ====== ');
            //System.debug('======= contactCallOutSync crudMode ====== '+crudMode);
            if(crudMode == 'INSERT'){
                LogInput contactInsertRecord = new LogInput();
                contactInsertRecord  =  GenerateContactJSONData.generateJSONForSingleContactInsert( GenerateContactJSONData.insertOneContactJSON(contactRecord),crudMode,contactRecord.Id);
                if(contactInsertRecord != null){
                    errorLogList.add(contactInsertRecord);
                }
            } 
            
            If(crudMode == 'UPDATE'){
                LogInput contactUpdateRecord = new LogInput();  
                
                contactUpdateRecord  = GenerateContactJSONData.generateJSONForSingleContactInsert( GenerateContactJSONData.updateOneContactJSON(contactRecord, fieldsSet),crudMode,contactRecord.Id);
                if(contactUpdateRecord != null){
                    errorLogList.add(contactUpdateRecord);
                }
            }
        } 
        
        // Callout for Website
        if(calloutSettingMap.containsKey('contactSync')  && calloutSettingMap.get('contactSync').Is_Active__c){ 
            //System.debug('======= contactCallOutSync contactSync ====== '); 

            if(contactRecord.recordTypeID == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId()){
                if(crudMode == 'UPDATE' && websiteCallout == 'Yes'){
                    //System.debug('====== contactCallOutSync Contact UPDATE ====');
                    LogInput [] grandNodeRecords =  GrandNodeContactSync.contactSync(ContactUtill.contactRequest(contactRecord.Id, 'CUSTOMER', 'DML').getAsString(), contactRecord.Id);
                    if(grandNodeRecords.size() > 0){
                        errorLogList.addAll(grandNodeRecords);
                    } 
                }
    
                if(crudMode == 'INSERT'){
                    //System.debug('====== contactCallOutSync Contact INSERT ====');
                    if(contactRecord.CreatedById != Label.WebsiteUserId && contactRecord.LastModifiedById != Label.WebsiteUserId){
                        LogInput [] grandNodeRecords =  GrandNodeContactSync.contactSync(ContactUtill.contactRequest(contactRecord.Id, 'CUSTOMER', 'DML').getAsString(), contactRecord.Id);
                        if(grandNodeRecords.size() > 0){
                            errorLogList.addAll(grandNodeRecords);
                        }
                    } 
                } 
            }  
        } 
        
        if(errorLogList.size() > 0){
            ApexLogUtill.createApexLogs(errorLogList);
        }
    }
}