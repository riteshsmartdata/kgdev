public class ContactMergeHelper {
    public static Set<Id> contactIds = new Set<Id>();
    // Method to handle Contact processing after merge
    public static void handleContactPostMerge(List<Contact> contacts) {
          
        for (Contact contact : contacts) {
            if (contact.Id != null) {
                contactIds.add(contact.MasterRecordId);
            }
        }

        if (contactIds.isEmpty()) {
            return;
        }

        // Query Contact Roles related to these Contacts
        List<Contact_Roles__c> contactRoles = [SELECT Id, Contact__c,CreatedDate, Contact_Role_Name__c 
                                               FROM Contact_Roles__c 
                                               WHERE Contact__c IN :contactIds];

        // Process and clean up Contact Roles
        ContactRolesHandler.handleContactRoleDuplicates(contactRoles);
    }

    // Method to handle clean-up after Contact delete
    public static void handlePostDeleteCleanup(List<Contact> deletedContacts) {
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : deletedContacts) {
            contactIds.add(contact.Id);
        }

        if (contactIds.isEmpty()) {
            return;
        }

        // Query Contact Roles related to deleted Contacts
        List<Contact_Roles__c> contactRoles = [SELECT Id, Contact__c, Contact_Role_Name__c 
                                               FROM Contact_Roles__c 
                                               WHERE Contact__c IN :contactIds];

        // Process and clean up Contact Roles
        ContactRolesHandler.handleContactRoleDuplicates(contactRoles);
    }
}