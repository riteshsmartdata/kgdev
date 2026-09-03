/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-09-2023   Ritesh Kumar   Initial Version
**/
public without sharing class ContactSynBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful{

    public Database.QueryLocator start(Database.BatchableContext bc){
    
        String recordType = 'CRM Contact';
        String contactSOQL = 'SELECT Id, Name, API_Callout_Required__c, Email FROM Contact WHERE RecordType.Name =: recordType and API_Callout_Required__c = TRUE';
        Return Database.getQueryLocator(contactSOQL);
    }

    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<LogInput> errorLogList = new List<LogInput>();
        List<Contact> updateContacts = new List<Contact>();

        if(contactList.size() > 0){
            for (Contact record : contactList) {
                Contact tempRecord  = new Contact();
                LogInput [] grandNodeRecords =  GrandNodeContactSync.contactSync(ContactUtill.contactRequest(record.Id, 'CUSTOMER', 'DML').getAsString(), record.Id);
                if(grandNodeRecords.size() > 0){
                    errorLogList.addAll(grandNodeRecords);
                }else{
                    tempRecord.id = record.Id;
                    tempRecord.API_Callout_Required__c = FALSE;
                    updateContacts.add(tempRecord);
                }
            } 

            if(updateContacts.size() > 0){
                Database.Update(updateContacts, false);
            }

            if(errorLogList.size() > 0){
                ApexLogUtill.createApexLogs(errorLogList);
            } 
        } 
    }
    
    public void finish(Database.BatchableContext bc){  
    } 
}