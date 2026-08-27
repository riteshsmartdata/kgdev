public class ContactRolesHandler {
    // Method to handle duplicate Contact Roles
    public static void handleContactRoleDuplicates(List<Contact_Roles__c> contactRoles) {
        if (contactRoles.isEmpty()) {
            return;
        }

        // Retrieve the Contact Roles ordered by CreatedDate (oldest first)
        contactRoles = [SELECT Id, Contact__c, Contact_Role_Name__c, CreatedDate
                        FROM Contact_Roles__c
                        WHERE Id IN :contactRoles
                        ORDER BY CreatedDate ASC];

        // Use a map to group roles by Contact and Role Name
        Map<Id, Map<String, List<Contact_Roles__c>>> contactRoleMap = new Map<Id, Map<String, List<Contact_Roles__c>>>();

        for (Contact_Roles__c cr : contactRoles) {
            if (!contactRoleMap.containsKey(cr.Contact__c)) {
                contactRoleMap.put(cr.Contact__c, new Map<String, List<Contact_Roles__c>>());
            }
            if (!contactRoleMap.get(cr.Contact__c).containsKey(cr.Contact_Role_Name__c)) {
                contactRoleMap.get(cr.Contact__c).put(cr.Contact_Role_Name__c, new List<Contact_Roles__c>());
            }
            contactRoleMap.get(cr.Contact__c).get(cr.Contact_Role_Name__c).add(cr);
        }

        List<Contact_Roles__c> rolesToDelete = new List<Contact_Roles__c>();
        for (Id contactId : contactRoleMap.keySet()) {
            Map<String, List<Contact_Roles__c>> roleTypeMap = contactRoleMap.get(contactId);
            for (String roleType : roleTypeMap.keySet()) {
                List<Contact_Roles__c> roles = roleTypeMap.get(roleType);
                if (roles.size() > 1) {
                    // Since roles are already ordered by CreatedDate, remove everything except the first role
                    roles.remove(0); // Keep the oldest, remove the rest
                    rolesToDelete.addAll(roles);
                }
            }
        }

        // Delete duplicate Contact Roles
        if (!rolesToDelete.isEmpty()) {
            delete rolesToDelete;
        }
    }
}