/*
*	Author : Kumar Saurav
* 	Created : 12-15-2023 
*	Updated : 12-26-2024
*	JIRA Ticket: SF-1235,MP-313, SF-1946
*	Description : This Apex Class is used to create and populate contacts on PO,Shipping,Order,Sales emails.
*/
public without sharing class EBSOrderTriggerUtility { 
    public static boolean isUpdated = false; 
    public static String recordTypeID = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');
    public static String multiLineRepRecType = KoozieUtility.getRecordTypeId('Contact', 'Multi-Line Rep');
    public static List<Contact> newContactList = new List<Contact>();
    public static List<Contact> successfullyInsertedContactList = new List<Contact>();
    public static List<EBS_Order__c> updateEBSOrderList = new List<EBS_Order__c>();
    public static Set<Id> updateEBSOrdersRecordIds = new Set<Id>();
    public static Map<String, String> newContactMap = new Map<String, String>();
    public static String domain = '@kooziegroup.com';
    public static Id koozieGroupAccountId = System.Label.Koozie_Group_Account_Id;
    public static String GOLF_PARENT_ACCOUNT_NUMBER = System.Label.Golf_Parent_Account_Number;
    private static Set<Id> golfAccountIdCache = null;
    /*Description : popoulate new Contact list based on the scenarios*/
    public static void populateContactsOnOrder(List<EBS_Order__c> newEBSOrderList, Map<Id, EBS_Order__c> oldEBSOrderMap) {
        if (!isUpdated) { 
            system.debug('helper called');
            try {
                Map<Id, Id> ebsOrderToSalesContactMap = new Map<Id, Id>();
                Map<String, AccountContactRelation> acrToInsertMap = new Map<String, AccountContactRelation>();
                
                List<EBS_Order__c> ebsRecordsToProcess = [ SELECT Id, Account_Name__c, Account_Name__r.Customer_Class_Code__c, 
                                                          Distributor_Account__c, Sales_Contact__c, PO_Contact__c, Order_Confirm_Contact__c, 
                                                          Shipping_Notif_Contact__c, SalesContact__c, PO_Contact_Email__c, 
                                                          Order_Confirmation_Email__c, Shipping_Notification_Email__c, 
                                                          Sales_Contact_First_Name__c, Sales_Contact_Last_Name__c
                                                          FROM EBS_Order__c 
                                                          WHERE Id IN :newEBSOrderList
                                                         ];            
                for (EBS_Order__c ebsRecord : ebsRecordsToProcess) {
                    
 /*if (ebsRecord.PO_Contact_Email__c != null) {
List<Contact> existingContacts = [SELECT Id, Email, AccountId
FROM Contact WHERE Email = :ebsRecord.PO_Contact_Email__c LIMIT 1];                    
if (!existingContacts.isEmpty()) {
ebsRecord.PO_Contact__c = existingContacts[0].Id;
} else {
newContactList.add(new Contact(
FirstName = 'Valued',LastName = 'Customer',
AccountId = ebsRecord.Account_Name__c != null
? ebsRecord.Account_Name__c
: koozieGroupAccountId,Email = ebsRecord.PO_Contact_Email__c,
RecordTypeId = recordTypeID
));
updateEBSOrdersRecordIds.add(ebsRecord.Id);
}
}*/
                    // Order Confirmation Contact Logic (Unchanged)
                    /* if (ebsRecord.Order_Confirmation_Email__c != null) {
List<Contact> existingContacts = [SELECT Id, Email, AccountId FROM Contact
WHERE Email = :ebsRecord.Order_Confirmation_Email__c LIMIT 1];                    
if (!existingContacts.isEmpty()) {
ebsRecord.Order_Confirm_Contact__c = existingContacts[0].Id;
} else {
newContactList.add(new Contact(
FirstName = 'Valued',LastName = 'Customer',
AccountId = ebsRecord.Account_Name__c != null
? ebsRecord.Account_Name__c
: koozieGroupAccountId,
Email = ebsRecord.Order_Confirmation_Email__c,RecordTypeId = recordTypeID));
updateEBSOrdersRecordIds.add(ebsRecord.Id);
}
}*/
                    // Shipping Notification Contact Logic (Unchanged)
                    /* if (ebsRecord.Shipping_Notification_Email__c != null) {
List<Contact> existingContacts = [SELECT Id, Email, AccountId
FROM Contact WHERE Email = :ebsRecord.Shipping_Notification_Email__c
LIMIT 1];                    
if (!existingContacts.isEmpty()) {
ebsRecord.Shipping_Notif_Contact__c = existingContacts[0].Id;
} else {
newContactList.add(new Contact(
FirstName = 'Valued',LastName = 'Customer',
AccountId = ebsRecord.Account_Name__c != null
? ebsRecord.Account_Name__c
: koozieGroupAccountId,
Email = ebsRecord.Shipping_Notification_Email__c, RecordTypeId = recordTypeID));
updateEBSOrdersRecordIds.add(ebsRecord.Id);
}
}*/
                    
                    Boolean isGolf = isGolfAccount(ebsRecord.Account_Name__c); 
                    
                    if( ebsRecord.Sales_Contact__c != null && !ebsRecord.Sales_Contact__c.contains('@kooziegroup.com')){
                        System.debug('Entered in 1');
                        if (!isGolf) {
                            Boolean distributorChanged = oldEBSOrderMap != null && oldEBSOrderMap.containsKey(ebsRecord.Id) &&
                                oldEBSOrderMap.get(ebsRecord.Id).Distributor_Account__c != ebsRecord.Distributor_Account__c;
                            if (distributorChanged) {
                                // Update the Sales Contact with the new Distributor Account
                                updateSalesContactToNewDistributor(ebsRecord);
                            }
                        }
                    }
                    if (ebsRecord.Sales_Contact__c != null) {
                        if (ebsRecord.Sales_Contact__c.contains('@kooziegroup.com')) {
                            System.debug('Entered in 2');
                            ebsRecord.SalesContact__c = null;
                            ebsOrderToSalesContactMap.put(ebsRecord.Id, null);
                            updateEBSOrdersRecordIds.add(ebsRecord.Id);
                            System.debug('updateEBSOrdersRecordIds'+updateEBSOrdersRecordIds);
                        } else {
                            System.debug('Entered in 3');
                            List<Contact> existingContacts = [SELECT Id, Email, AccountId FROM Contact
                                                              WHERE Email = :ebsRecord.Sales_Contact__c LIMIT 1];
                            if (!existingContacts.isEmpty()) {
                                Contact existingContact = existingContacts[0];
                                System.debug('isGolf--> '+ isGolf);
                                if (isGolf) {
                                    System.debug('Golf account – creating AccountContactRelation, NOT moving contact');
                                    ebsRecord.SalesContact__c = existingContact.Id;
                                    ebsOrderToSalesContactMap.put(ebsRecord.Id, existingContact.Id);
                                    updateEBSOrdersRecordIds.add(ebsRecord.Id);
                                    
                                    String acrKey = existingContact.Id + '|' + ebsRecord.Account_Name__c;
                                    if (!acrToInsertMap.containsKey(acrKey)) {
                                        acrToInsertMap.put(acrKey, new AccountContactRelation(
                                            ContactId = existingContact.Id,
                                            AccountId = ebsRecord.Account_Name__c,
                                            IsActive  = true
                                        ));
                                    }
                                } else {
                                     System.debug('Entered in 4');
                                    if (ebsRecord.Distributor_Account__c != null
                                        && existingContact.AccountId != ebsRecord.Distributor_Account__c) {
                                            existingContact.AccountId = ebsRecord.Distributor_Account__c;
                                            update existingContact;
                                        }
                                    ebsRecord.SalesContact__c = existingContact.Id;
                                    ebsOrderToSalesContactMap.put(ebsRecord.Id, existingContact.Id);
                                    updateEBSOrdersRecordIds.add(ebsRecord.Id);
                                }
                                
                            } else {
                                 System.debug('Entered in 5');
                                if (isGolf) {
                                    Contact newGolfContact = createGolfSalesContact(ebsRecord);
                                    newContactList.add(newGolfContact);
                                    ebsOrderToSalesContactMap.put(ebsRecord.Id, newGolfContact.Id);
                                    updateEBSOrdersRecordIds.add(ebsRecord.Id);
                                    
                                } else {
                                    Id salesContactAccountId = determineSalesContactAccount(ebsRecord);
                                    if (salesContactAccountId != null) {
                                        Contact newSalesContact = createSalesContact(ebsRecord, salesContactAccountId);
                                        newContactList.add(newSalesContact);
                                        ebsOrderToSalesContactMap.put(ebsRecord.Id, newSalesContact.Id);
                                        updateEBSOrdersRecordIds.add(ebsRecord.Id);
                                    }
                                }
                            }
                        }
                    }                    
                }
                
                if (!acrToInsertMap.isEmpty()) {
                    // Filter out already-existing relations
                    Set<String> alreadyExistingKeys = new Set<String>();
                    List<AccountContactRelation> acrValues = acrToInsertMap.values();
                    
                    Set<Id> acrContactIds = new Set<Id>();
                    Set<Id> acrAccountIds = new Set<Id>();
                    for (AccountContactRelation acr : acrValues) {
                        acrContactIds.add(acr.ContactId);
                        acrAccountIds.add(acr.AccountId);
                    }
                    for (AccountContactRelation existing : [
                        SELECT ContactId, AccountId
                        FROM   AccountContactRelation
                        WHERE  ContactId IN :acrContactIds
                        AND    AccountId IN :acrAccountIds
                    ]) {
                        alreadyExistingKeys.add(existing.ContactId + '|' + existing.AccountId);
                    }
                    
                    List<AccountContactRelation> acrToInsert = new List<AccountContactRelation>();
                    for (String key : acrToInsertMap.keySet()) {
                        if (!alreadyExistingKeys.contains(key)) {
                            acrToInsert.add(acrToInsertMap.get(key));
                        }
                    }
                    System.debug('====acrToInsert== '+acrToInsert);
                    if (!acrToInsert.isEmpty()) {
                        Database.insert(acrToInsert, false);
                    }
                }
                System.debug('====newContactList== '+newContactList);
                if (!newContactList.isEmpty() && !updateEBSOrdersRecordIds.isEmpty()) {
                    insertNewContactList(newContactList);
                }
                System.debug('====updateEBSOrdersRecordIds== '+updateEBSOrdersRecordIds);
                if (!updateEBSOrdersRecordIds.isEmpty()) {
                    isUpdated = true;
                    updateEBSRecords(updateEBSOrdersRecordIds, ebsOrderToSalesContactMap);
                }
            } catch (Exception e) {
                System.debug('======'+e);
                ApexLogUtill.createApexLog('EBSOrderTriggerUtility.populateContactsOnOrder', null, e.getMessage(), null, 'EBS_Order__c', e.getMessage(), 0);
                
            }
        }
    }
    
    public static Contact createGolfSalesContact(EBS_Order__c ebsRecord) {
        String firstName = String.isBlank(ebsRecord.Sales_Contact_First_Name__c)
            ? 'Valued' : ebsRecord.Sales_Contact_First_Name__c;
        String lastName  = String.isBlank(ebsRecord.Sales_Contact_Last_Name__c)
            ? 'Customer' : ebsRecord.Sales_Contact_Last_Name__c;
        return new Contact(
            FirstName        = firstName,
            LastName         = lastName,
            AccountId        = koozieGroupAccountId, // Default – NOT the golf course account
            Email            = ebsRecord.Sales_Contact__c,
            Is_Sales_Contact__c = true,
            RecordTypeId     = multiLineRepRecType   // Multi-Line Rep record type
        );
    }
    
    public static Boolean isGolfAccount(Id accountId) {
        if (accountId == null) { return false; }
        
        // Build cache on first call
        if (golfAccountIdCache == null) {
            golfAccountIdCache = new Set<Id>();
            
            // find the parent golf account
            List<Account> parentAccounts = [
                SELECT Id
                FROM   Account
                WHERE  AccountNumber = :GOLF_PARENT_ACCOUNT_NUMBER
                LIMIT  1
            ];
            
            if (!parentAccounts.isEmpty()) {
                Id parentGolfId = parentAccounts[0].Id;
                golfAccountIdCache.add(parentGolfId);  // parent itself is also golf
                
                // all direct children
                for (Account child : [
                    SELECT Id
                    FROM   Account
                    WHERE  ParentId = :parentGolfId
                ]) {
                    golfAccountIdCache.add(child.Id);
                }
            }
        }
        
        return golfAccountIdCache.contains(accountId);
    }
    
    public static void createAccountContactRelation(Id contactId, Id accountId) {
        if (contactId == null || accountId == null) { return; }
        
        // Check if relation already exists to prevent duplicate error
        List<AccountContactRelation> existing = [
            SELECT Id
            FROM   AccountContactRelation
            WHERE  ContactId = :contactId
            AND    AccountId = :accountId
            LIMIT  1
        ];
        
        if (existing.isEmpty()) {
            try {
                insert new AccountContactRelation(
                    ContactId = contactId,
                    AccountId = accountId,
                    IsActive  = true
                );
            } catch (Exception e) {
                ApexLogUtill.createApexLog( 'EBSOrderTriggerUtility.createAccountContactRelation', null, e.getMessage(), null, 'AccountContactRelation', e.getMessage(), 0 );
            }
        }
    }
    
    public static Id determineSalesContactAccount(EBS_Order__c ebsRecord) {
         // NEW: Golf accounts handled separately – skip this method
        if (isGolfAccount(ebsRecord.Account_Name__c)) {
            System.debug('Golf account – skipping determineSalesContactAccount');
            return null;
        }
        
        if (ebsRecord.Sales_Contact__c != null && ebsRecord.Sales_Contact__c.contains('@kooziegroup.com')) {
            System.debug('Entered in 6');
            return null; // Explicitly prevent creation for kooziegroup.com
        }
        if (ebsRecord.Account_Name__r.Customer_Class_Code__c == 'BDF' && ebsRecord.Sales_Contact__c != null && !ebsRecord.Sales_Contact__c.contains('@kooziegroup.com')) {
            System.debug('Entered in 7');
            if (ebsRecord.Distributor_Account__c != null) {
                return ebsRecord.Distributor_Account__c;
            } else{
                System.debug('Skipping Sales Contact creation for BDF due to missing Distributor_Account__c');
                return null;
            }            
        }
        if (ebsRecord.Account_Name__r.Customer_Class_Code__c != 'BDF') {
            return null;
        }
        if (ebsRecord.PO_Contact_Email__c == ebsRecord.Sales_Contact__c) {
            return null;  // Prevent PO Contact from being misused as Sales Contact
        }
        return ebsRecord.Account_Name__c != null ? ebsRecord.Account_Name__c : koozieGroupAccountId;
        //return null;
    }
    public static Contact createSalesContact(EBS_Order__c ebsRecord, Id accountId) {
        System.debug('Entered in createSalesContact');
        String contactFirstName = !String.isBlank(ebsRecord.Sales_Contact_First_Name__c)
            ? ebsRecord.Sales_Contact_First_Name__c : 'Valued';
        String contactLastName = !String.isBlank(ebsRecord.Sales_Contact_Last_Name__c)
            ? ebsRecord.Sales_Contact_Last_Name__c : 'Customer';
        // Sales Contact should get Distributor Account if available
        Id salesContactAccountId = ebsRecord.Distributor_Account__c != null ? ebsRecord.Distributor_Account__c : accountId;
        return new Contact(
            FirstName = contactFirstName,
            LastName = contactLastName,
            AccountId = salesContactAccountId, // Set only for Sales Contact
            Email = ebsRecord.Sales_Contact__c,
            Is_Sales_Contact__c = true,
            RecordTypeId = recordTypeID
        );
    }
    // Added: Method to update Sales Contact for the new Distributor Account
    public static void updateSalesContactToNewDistributor(EBS_Order__c ebsRecord) {
        try {
            if (newContactMap.containsKey(ebsRecord.Sales_Contact__c)) {
                String contactId = newContactMap.get(ebsRecord.Sales_Contact__c);
                Contact contactToUpdate = new Contact(Id = contactId,AccountId = ebsRecord.Distributor_Account__c // Update to new Distributor Account
                                                     );
                Database.update(contactToUpdate, false);
            } else {
                // If no existing contact is found in the map, query to find it and update
                List<Contact> existingContacts = [SELECT Id FROM Contact WHERE Email = :ebsRecord.Sales_Contact__c  LIMIT 1];
                if (!existingContacts.isEmpty()) {
                    Contact contactToUpdate = new Contact(Id = existingContacts[0].Id,AccountId = ebsRecord.Distributor_Account__c);
                    Database.update(contactToUpdate, false);
                    System.debug('Sales Contact re-tagged to new Distributor Account: ' + ebsRecord.Distributor_Account__c);
                }
            }
        } catch (Exception e) {
            ApexLogUtill.createApexLog('EBSOrderTriggerUtility.updateSalesContactToNewDistributor', null, e.getMessage(), ebsRecord.Id, 'EBS_Order__c', e.getMessage(), 0);
            System.debug('Exception in updateSalesContactToNewDistributor: ' + e.getMessage());
        }
    }
    /* Description : Inserting new Contacts and Poplutong map keeping email as a key.
*/
    public static void insertNewContactList(List<Contact> newContactList) {
        try {
            List<Contact> insertContactList = new List<Contact>();
            Map<String, Contact> existingContactMap = foundExistingContact(newContactList);
            Map<String, Contact> duplicateCheckMap = new Map<String, Contact>();             
            Set<String> emailSet = new Set<String>();
            
            // Collect emails for checking in EBS_Order__c
            for (Contact contactRecord : newContactList) {
                if (contactRecord.Email != null 
                    && !duplicateCheckMap.containsKey(recordTypeID + contactRecord.Email + contactRecord.AccountId)) {
                        duplicateCheckMap.put(recordTypeID + contactRecord.Email + contactRecord.AccountId, contactRecord);
                        emailSet.add(contactRecord.Email);
                    }
            }
            
            // Query EBS_Order__c to get emails used as Sales_Contact__c that contain '@kooziegroup.com'
            Set<String> salesContactExclusionSet = new Set<String>();
            Map<String, Id> emailToOrderIdMap = new Map<String, Id>(); // Store Order Ids for reference
            for (EBS_Order__c order : [SELECT Id, Sales_Contact__c FROM EBS_Order__c WHERE Sales_Contact__c IN :emailSet]) {
                if (order.Sales_Contact__c != null && order.Sales_Contact__c.contains('@kooziegroup.com')) {
                    salesContactExclusionSet.add(order.Sales_Contact__c);
                }
            }
            // Ensure only SalesContact__c exclusion applies and does not affect PO Contact, Order Confirmation, or Shipping Notification
            Set<String> nonSalesEmails = emailSet.clone();
            nonSalesEmails.removeAll(salesContactExclusionSet);
            
            for (Contact contactRecord : duplicateCheckMap.values()) {
                Boolean isSalesContactExcluded = salesContactExclusionSet.contains(contactRecord.Email);
                Boolean isNonSalesContact = nonSalesEmails.contains(contactRecord.Email);
                
                if (!(isSalesContactExcluded && contactRecord.Is_Sales_Contact__c)) { 
                    insertContactList.add(contactRecord);
                }
            }
            // Insert new contacts
            Database.SaveResult[] insertedContactResults = Database.insert(insertContactList, false);
            for (Integer i = 0; i < insertedContactResults.size(); i++) {
                if (insertedContactResults[i].isSuccess()) {
                    Contact insertedContact = insertContactList[i];
                    successfullyInsertedContactList.add(insertedContact);
                    newContactMap.put(insertedContact.Email, insertedContact.Id);
                }
            }
            
            // Ensure the inserted Contact is NOT tagged in SalesContact__c if it's in salesContactExclusionSet
            List<EBS_Order__c> ordersToUpdate = new List<EBS_Order__c>();
            for (String email : salesContactExclusionSet) {
                if (newContactMap.containsKey(email)) {
                    Id orderId = emailToOrderIdMap.get(email);
                    if (orderId != null) {
                        EBS_Order__c orderRecord = new EBS_Order__c(Id = orderId, SalesContact__c = null);
                        ordersToUpdate.add(orderRecord);
                    }
                }
            }
            if (!ordersToUpdate.isEmpty()) {
                update ordersToUpdate;
            }
            
        } catch (Exception e) {
            ApexLogUtill.createApexLog('EBSOrderTriggerUtility.insertNewContactList', 'insertContactList' , e.getMessage(), null, 'Contact', e.getMessage(), 0);
        }
    }
    
    /*	Description : populate the newly created contacts on all the 4 emails and update the EBS Order.*/
    public static void updateEBSRecords(Set<Id> updateEBSOrdersRecordIds,  Map<Id, Id> ebsOrderToSalesContactMap ) {
        try {
            List<EBS_Order__c> ebsRecordsToUpdate = [
                SELECT Id,
                Distributor_Account__c,
                Account_Name__r.Customer_Class_Code__c,
                Account_Name__c,
                PO_Contact__c,        PO_Contact_Email__c,
                Order_Confirm_Contact__c, Order_Confirmation_Email__c,
                Shipping_Notif_Contact__c, Shipping_Notification_Email__c,
                SalesContact__c, Sales_Contact__c
                FROM   EBS_Order__c
                WHERE  Id IN :updateEBSOrdersRecordIds
            ];
            System.debug('ebsRecordsToUpdate--> '+ ebsRecordsToUpdate);
            Set<Id> accountIds  = new Set<Id>();
            Set<Id> distributorAccountIds = new Set<Id>();
            
            for (EBS_Order__c r : ebsRecordsToUpdate) {
                System.debug('r.SalesContact__c--> '+ r.SalesContact__c);
                if (r.Distributor_Account__c != null) {
                    accountIds.add(r.Distributor_Account__c);
                    distributorAccountIds.add(r.Distributor_Account__c);
                }
                if (r.Account_Name__c != null) {
                    accountIds.add(r.Account_Name__c); 
                }
            }
            
            Map<String, Map<Id,Id>> contactEmailAccountMap = new Map<String, Map<Id,Id>>();
            Map<String,Id> distributorContactEmailMap = new Map<String,Id>();
            
            for (Contact c : [
                SELECT Id, Email, AccountId
                FROM Contact
                WHERE  AccountId IN :accountIds
                AND  Email != null
            ]) {
                if (!contactEmailAccountMap.containsKey(c.Email)) {
                    contactEmailAccountMap.put(c.Email, new Map<Id,Id>());
                }
                contactEmailAccountMap.get(c.Email).put(c.AccountId, c.Id);
                if (distributorAccountIds.contains(c.AccountId)) {
                    distributorContactEmailMap.put(c.Email, c.Id);
                }
            }
            
            for (EBS_Order__c r : ebsRecordsToUpdate) {
                Boolean isGolf = isGolfAccount(r.Account_Name__c);
                
                if (ebsOrderToSalesContactMap != null 
                    && ebsOrderToSalesContactMap.containsKey(r.Id)) {
                        r.SalesContact__c = ebsOrderToSalesContactMap.get(r.Id);
                    }
                 System.debug('Gr.else if--> '+ r.SalesContact__c); 
                // PO Contact
                if (String.isBlank(r.PO_Contact__c)
                    && contactEmailAccountMap.containsKey(r.PO_Contact_Email__c)
                    && contactEmailAccountMap.get(r.PO_Contact_Email__c).containsKey(r.Account_Name__c)) {
                        r.PO_Contact__c = contactEmailAccountMap.get(r.PO_Contact_Email__c).get(r.Account_Name__c);
                    }
                // Order Confirm Contact
                if (String.isBlank(r.Order_Confirm_Contact__c)
                    && contactEmailAccountMap.containsKey(r.Order_Confirmation_Email__c)
                    && contactEmailAccountMap.get(r.Order_Confirmation_Email__c).containsKey(r.Account_Name__c)) {
                        r.Order_Confirm_Contact__c = contactEmailAccountMap.get(r.Order_Confirmation_Email__c).get(r.Account_Name__c);
                    }
                // Shipping Contact
                if (String.isBlank(r.Shipping_Notif_Contact__c)
                    && contactEmailAccountMap.containsKey(r.Shipping_Notification_Email__c)
                    && contactEmailAccountMap.get(r.Shipping_Notification_Email__c).containsKey(r.Account_Name__c)) {
                        r.Shipping_Notif_Contact__c = contactEmailAccountMap.get(r.Shipping_Notification_Email__c).get(r.Account_Name__c);
                    }
                
                // ---- Sales Contact nullification logic ----
                if (r.Sales_Contact__c != null
                    && r.Sales_Contact__c.contains('@kooziegroup.com')) {
                        // Always nullify kooziegroup.com (golf or not)
                        r.SalesContact__c = null;
                        System.debug('Gr.r.SalesContact__c--> '+ r.Sales_Contact__c);
                        
                    } else if (isGolf) {
                        System.debug('Golf account – preserving SalesContact__c on EBS Order');  
                        System.debug('Gr.else if--> '+ r.SalesContact__c); 
                    } else if (r.Account_Name__r.Customer_Class_Code__c != 'BDF') {
                        // Non-golf, non-BDF: nullify (original logic)
                        r.SalesContact__c = null;                        
                    } else if (!String.isBlank(r.Sales_Contact__c)
                               && r.Distributor_Account__c != null
                               && distributorContactEmailMap.containsKey(r.Sales_Contact__c)) {
                                   // BDF: link to distributor contact (original logic)
                                   r.SalesContact__c = distributorContactEmailMap.get(r.Sales_Contact__c);
                               }
               
                updateEBSOrderList.add(r);
            }
            System.debug('updateEBSOrderList--> '+updateEBSOrderList);
            Database.update(updateEBSOrderList, false);
            
        } catch (Exception e) {
            ApexLogUtill.createApexLog(
                'EBSOrderTriggerUtility.updateEBSRecords',
                'updateEBSOrderList', e.getMessage(), null, 'EBS_Order__c', e.getMessage(), 0
            );
        }
    }
    
    public static Map<String,Contact> foundExistingContact(List<Contact> contactList){
        Map<String,Contact> foundExistingContactMap = new Map<String,Contact>();
        try{
            Set<Id> accountIds = new Set<Id>();
            Set<String> contactEmail = new Set<String>();
            for(Contact contactRecord : contactList){
                if(contactRecord.AccountId!=null && contactRecord.Email!=null){
                    accountIds.add(contactRecord.AccountId);
                    contactEmail.add(contactRecord.Email);
                }
            }
            if(!accountIds.isEmpty() && !contactEmail.isEmpty()){
                List<Contact> existingContactList = [SELECT Id,Email,AccountId FROM Contact WHERE AccountId IN: accountIds AND Email IN:contactEmail AND RecordTypeId =:recordTypeID];
                for(Contact contactRecord: existingContactList){
                    if(!foundExistingContactMap.containsKey(recordTypeID+contactRecord.Email+contactRecord.AccountId)){
                        foundExistingContactMap.put(recordTypeID+contactRecord.Email+contactRecord.AccountId,contactRecord);
                    }  } }
        }catch (Exception e) {
            System.debug('Exception in foundExistingContact: ' + e.getMessage());
            ApexLogUtill.createApexLog('EBSOrderTriggerUtility.foundExistingContact', 'contactList' , e.getMessage(), null, 'Contact', e.getMessage(), 0);
        }
        return foundExistingContactMap;
    }
}