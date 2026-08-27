/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-07-2025   Ritesh Kumar   Initial Version
**/
public with sharing class AccountStatusSyncBatch implements Database.Batchable<sObject>, Database.Stateful {

    // Instance variables for tracking
    private Integer totalRecords = 0;
    private Integer successCount = 0;
    private Integer failureCount = 0;
	final private String INACTIVE = 'Inactive';
	final private String ACTIVE = 'Active';
	final private String CRM_CONTACT = KoozieUtility.getRecordTypeId('Contact','CRM Contact');

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(getInactiveAccountsQuery());
    }

    public void execute(Database.BatchableContext BC, List<Account> accountList) {
        if (accountList.isEmpty()) return;

        Set<Id> accountIds = extractAccountIds(accountList);
        List<Contact> contactsToUpdate = getContactsToUpdate(accountIds);

        totalRecords += contactsToUpdate.size();

        if (!contactsToUpdate.isEmpty()) {
            updateContacts(contactsToUpdate);
        }
    }

    public void finish(Database.BatchableContext BC) {
        sendEmailNotification();
    }

    private String getInactiveAccountsQuery() { 
        return 'SELECT Id FROM Account WHERE Status__c =: INACTIVE AND Id IN (SELECT AccountId FROM Contact WHERE RecordTypeId =: CRM_CONTACT AND Contact_Status__c =: ACTIVE AND Web_Id__c = null)';
    }

    private Set<Id> extractAccountIds(List<Account> accounts) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }
        return accountIds;
    }

    private List<Contact> getContactsToUpdate(Set<Id> accountIds) {
        return [
            SELECT Id, AccountId, Contact_Status__c 
            FROM Contact 
            WHERE AccountId IN :accountIds AND Web_Id__c = NULL AND RecordTypeId =: CRM_CONTACT
        ];
    }

    private void updateContacts(List<Contact> contacts) {

        for (Contact con : contacts) {
            con.Contact_Status__c = INACTIVE;
			
        }

        Database.SaveResult[] results = Database.update(contacts, false);

        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                successCount++;
            } else {
                failureCount++;
            }
        }
    }

    private void sendEmailNotification() {
        String currentUserEmail = UserInfo.getUserEmail(); // Get the logged-in user's email

        String subject = 'Batch Job Report: Contact Sync with Inactive Accounts';
        String body = 'Batch Job Completed!' + 
                      '\n\nTotal Records Processed: ' + totalRecords + 
                      '\nSuccessful Updates: ' + successCount + 
                      '\nFailed Updates: ' + failureCount;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{currentUserEmail});
        email.setSubject(subject);
        email.setPlainTextBody(body);
        try{
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'Failed to sent batch job status email. Error: ' + e.getMessage());
        } 
    }

}