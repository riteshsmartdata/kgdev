global class UpdateContactOwner implements Database.Batchable<SObject>, Database.Stateful {
    
    // Integration Service User ID
    private final Id INTEGRATION_SERVICE_USER_ID = '0051U000001M0nlQAC'; 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Account.OwnerId, Account.Primary_Team_Member2__c, OwnerId FROM Contact WHERE OwnerId IN (SELECT Id FROM User WHERE IsActive = false) AND AccountId != NULL';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        Set<Id> accountOwnerIds = new Set<Id>();
        
        // Filter contacts where Primary_Team_Member2__c is not null
        for (Contact contact : scope) {
            if (contact.Account.Primary_Team_Member2__c != null) {
                accountOwnerIds.add(contact.Account.Primary_Team_Member2__c);
            }
        }
        
        if (!accountOwnerIds.isEmpty()) {
            Map<Id, User> accountPrimaryOwnerMap = new Map<Id, User>([SELECT Id, Manager.Id, Manager.Name, Manager.IsActive, IsActive FROM User WHERE Id IN :accountOwnerIds]);
            
            List<Contact> contactsToUpdate = new List<Contact>();
            for (Contact contact : scope) {
                if (contact.Account.Primary_Team_Member2__c != null) {
                    User accountOwner = accountPrimaryOwnerMap.get(contact.Account.Primary_Team_Member2__c);
                    if (accountOwner != null) {
                        if (accountOwner.IsActive) {
                            contact.OwnerId = accountOwner.Id;
                        } else if (accountOwner.Manager != null && accountOwner.Manager.IsActive) {
                            contact.OwnerId = accountOwner.Manager.Id;
                        } else {
                            contact.OwnerId = INTEGRATION_SERVICE_USER_ID;
                        }
                    } else {
                        contact.OwnerId = INTEGRATION_SERVICE_USER_ID;
                    }
                } else {
                    contact.OwnerId = INTEGRATION_SERVICE_USER_ID;
                }
                contactsToUpdate.add(contact);
            }
            
            if (!contactsToUpdate.isEmpty()) {
                update contactsToUpdate;
            }
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        // Optional: Add finish logic if needed
    }
}