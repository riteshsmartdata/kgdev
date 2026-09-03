/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 10-16-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
global with sharing class UpdateContactStatus implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    private map<Id,String> accountInfo; 
	
	public UpdateContactStatus(Map<Id,String> accounts ) {
        this.accountInfo = accounts; 
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {
		//System.debug(LoggingLevel.INFO,'======== accountInfo ====='+accountInfo);
		Set<Id> accountIds = accountInfo.keySet();
        String query = 'SELECT id, Contact_Status__c, AccountId FROM Contact WHERE AccountId IN : accountIds';
        //System.debug(LoggingLevel.INFO,'======== Contact SOQL ====='+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contacts) {

		//System.debug(LoggingLevel.INFO,'======== contacts  ====='+contacts.size());
		

        if(contacts.size() > 0){
			for (Contact record : contacts) { 
				record.Contact_Status__c = accountInfo.get(record.AccountId);
				record.isBatchRunning__c = true;
				//System.debug(LoggingLevel.INFO,'======== contacts  ====='+contacts);
			}

			Database.update(contacts, false);

			for (Contact record : contacts) { 
				record.isBatchRunning__c = false; 
				//System.debug(LoggingLevel.INFO,'======== contacts ====='+contacts);
			} 

			Database.update(contacts, false);
			
		}
 
    }

	global void finish(Database.BatchableContext BC) {
		//System.debug(LoggingLevel.INFO,'====== Finished Batch updateContactStatus=========');
		 
    }
}