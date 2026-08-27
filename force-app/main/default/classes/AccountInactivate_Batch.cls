/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : Mohammad Arafat Ali
**/
public class AccountInactivate_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext BC){   
        String contactSOQL = 'SELECT Contact_Status__c, Account.Status__c, Id FROM Contact WHERE Account.Status__c = \'Inactive\' AND Contact_Status__c = \'Active\' AND RecordType.Name = \'CRM Contact\' ORDER BY CreatedDate DESC';
        return Database.getQueryLocator(contactSOQL);
    }
    public void execute(Database.BatchableContext BC, List<Contact> contactList){

        List<Contact> contactInactive = new List<Contact>();
        if(!contactList.isEmpty()){
            for(Contact record : contactList){
                Contact tempData = new Contact();
                tempData.Contact_Status__c = 'Inactive';
                tempData.isBatchRunning__c = true;
                tempData.Id = record.Id;
                contactInactive.add(tempData);
            }
        }
        
        if(!contactInactive.isEmpty()){
            Database.SaveResult[] results = Database.update(contactInactive, false);
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug('***Batch Finished***');
    }
}