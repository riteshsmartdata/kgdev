public class UpdateContactAddressBatch implements Database.Batchable<SObject>{
    
    public List<String> accountIds;
    
    public UpdateContactAddressBatch(List<String> accountIds) {
        this.accountIds = accountIds;
        system.debug('accountIds@@@@'+accountIds);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Startcall@@@@@'+accountIds);
        system.debug('Startcall@@@@@'+this.accountIds);
        List<contact> contactList = [SELECT Id, AccountId, Remote_Contact__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE AccountId IN:accountIds AND Remote_Contact__c = false];
        system.debug('contactList@@@@@@@@@@' +contactList);
        return Database.getQueryLocator([
            SELECT Id, AccountId, Remote_Contact__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry FROM Contact WHERE AccountId IN:accountIds AND Remote_Contact__c = false
        ]);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList) {
        system.debug('ExecuteCall@@@@@');
        System.debug('BatchExecute ContactList@@@@@@ ' + contactList.size());
        List<Contact> contactsToUpdate = new List<Contact>();
        
        // Get the corresponding Account and update Contact Address
        
        //contactList = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry FROM Contact ];
        for(Contact cnn : contactList){
            
            cnn.MailingStreet = cnn.Account.ShippingStreet;
            cnn.MailingCity = cnn.Account.ShippingCity;
            cnn.MailingState = cnn.Account.ShippingState;
            cnn.MailingPostalCode = cnn.Account.ShippingPostalCode;
            cnn.MailingCountry = cnn.Account.ShippingCountry;
            
            contactsToUpdate.add(cnn);
        }
        
        // Update the contacts with the new addresses
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
            system.debug('contactsToUpdate@@@@@@'+contactsToUpdate);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
    }
    
}