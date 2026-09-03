/**
 * @description       : 
 * @author            : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 * @group             : 
 * @last modified on  : 11-17-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public with sharing class WebsiteContactSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {    

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,'===== : START  start method=====');
        String recordType = KoozieConstants.RECORD_TYPE_CRM_CONTACT;
        String status = KoozieConstants.CONTACT_ACTIVE_STATUS;
        String query = 'SELECT Id, Web_Id__c, Email FROM Contact WHERE RecordType.Name =: recordType AND Contact_Status__c =: status AND Web_Id__c != NULL';
       // String soql = 'SELECT Id FROM Contact WHERE Id IN (\'003UR00000ha84jYAA\',\'003UR00000hYFYaYAO\',\'003UR00000hYLVtYAO\',\'003UR00000hY0rGYAS\',\'003UR00000hWnXuYAK\',\'003UR00000hVidGYAS\',\'003UR00000hVYzBYAW\',\'003UR00000hVj2fYAC\',\'003UR00000hUIwPYAW\',\'003UR00000hRYcjYAG\')';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> selectedContact) {
        System.debug(LoggingLevel.INFO,'===== : START  execute method====='+selectedContact);
        List<LogInput> logInputList = new List<LogInput>();
        for(Contact record : selectedContact) {
            String contactJson = ContactUtill.contactRequest(record.Id, 'CUSTOMER', 'DML').getAsString();
			logInputList.addAll(GrandNodeContactSync.contactSync(contactJson, record.Id));
        }
        if(logInputList.size() > 0){
            ApexLogUtill.createApexLogs(logInputList);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.INFO,'===== : START  finish method=====');
    }   
 }