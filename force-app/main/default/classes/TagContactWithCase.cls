/**
* @description       : 
* @group             : 
* @last modified on  : 12-17-2025
* @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public without sharing class TagContactWithCase extends TriggerHandler {    
    private List<Case> newRecords;
    private final static String CLARIFICATIONS = 'CLARIFICATIONS';
    private final static String CLARIFICATIONS_RT = 'Clarification';
    private final static String SALES_SERVICE = 'SALES_SERVICE';
    private final static String KOOZIE_ACOUNT_ID = System.Label.Koozie_Group_Account_Id;
    private final static String ORPHAN_ACOUNT_ID = System.Label.Orphan_Account_Id;
    private final static String KOOZIE_DOMAIN = 'kooziegroup.com';
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('Case');    
    enum CASE_RECORDTYPE{
        CLARIFICATIONS,
            OTHER
            }
    @TestVisible
    private static Boolean isTriggerActiveForTests = false;    
    public TagContactWithCase(String className){
        this.newRecords = (List<Case>) Trigger.new;
        System.debug('==== START tagContactWithCase ====');
    }    
    public static String getMapKey(Set<String> keys, String email){
        for(String key : keys){
            // if(key.contains(email)){
            if(key.startsWith(email)){ 
                return key;    
            }
        }
        return null; 
    }    
    public static Contact_Roles__c createContactRole(String contactId, String accountId, TagContactWithCase.CASE_RECORDTYPE recordType){
        Contact_Roles__c contactRoleRecord = new Contact_Roles__c();
        contactRoleRecord.Contact__c = contactId;
        contactRoleRecord.Account__c = accountId; 
        if(TagContactWithCase.CASE_RECORDTYPE.CLARIFICATIONS == recordType){
            contactRoleRecord.Contact_Role_Name__c = CLARIFICATIONS;
        }else{
            contactRoleRecord.Contact_Role_Name__c = SALES_SERVICE;
        }
        return contactRoleRecord;
    }    
    public static Map<String,Contact_Roles__c> checkContactRole(Set<String> contactIds){        
        Map<String,Contact_Roles__c> contactRoleRecord = new Map<String,Contact_Roles__c>();        
        for(Contact_Roles__c record : [SELECT Contact__c, Contact__r.AccountId, Id,Contact_Role_Name__c 
                                       FROM Contact_Roles__c WHERE Contact__c =: contactIds AND 
                                       (Contact_Role_Name__c = : CLARIFICATIONS OR Contact_Role_Name__c = :SALES_SERVICE) 
                                       ORDER BY CreatedDate ]){
                                           contactRoleRecord.put(record.Contact__c+ record.Contact_Role_Name__c,record);
                                       }        
        return contactRoleRecord;
    }    
    public static Contact createContact(String email, String accountId, String accountNumber){
        System.debug(LoggingLevel.INFO,' ======= Create Contact  -> Input Email : '+ email + ', Input Account ID : '+accountId+', Input Account Number'+ accountNumber);
        Contact contactRecord = new Contact();
        contactRecord.LastName = 'Customer';
        contactRecord.FirstName = 'Valued';
        contactRecord.Email = email;
        contactRecord.Contact_Status__c = 'Active'; 
        contactRecord.AccountId = accountId;
        Id rtId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');
        System.debug('Contact RTID returned: ' + rtId);
        
        contactRecord.RecordTypeId = rtId;
        contactRecord.Source__c = 'TagContactWithCase'; 
        return contactRecord;
    }    
    public static Map<String,Account> searchAccount(Set<String> accountNumbers ){
        System.debug(LoggingLevel.INFO,' ======= Search Accunt -> Input Account Numbers : '+accountNumbers );
        Map<String,Account> accountRecords = new Map<String,Account>();        
        for( Account record : [
            SELECT 
            Id,  Customer_Account_Number__c, Account_Domain__c, Account_Email_Domain__c
            FROM Account 
            WHERE Customer_Account_Number__c = :accountNumbers Order By CreatedDate DESC
        ]){
            accountRecords.put(record.Customer_Account_Number__c,record);
        }        
        System.debug(LoggingLevel.INFO,' ======= Search Contact -> Output Accounts : '+ accountRecords);
        return accountRecords;
    }    
    public static Map<String, Account> searchAccountByDomain(Set<String> domians ){
        System.debug(LoggingLevel.INFO,' ======= Search Accunt -> Input Domians : '+domians );
        Map<String, Account> accounts = new Map<String, Account>();
        for( Account record : [SELECT Id, Account_Domain__c, Customer_Account_Number__c FROM Account WHERE Account_Domain__c IN :domians]){
            accounts.put(record.Account_Domain__c, record);
        }
        System.debug(LoggingLevel.INFO,' ======= Search Contact -> Output Accounts : '+accounts);
        return accounts;
    }    
    public static string getAccountId(Map<String, Account> domains, String email){        
        String currentDomain = email.split('@')[1];
        if(domains != null){            
            if(domains.containsKey(currentDomain)){
                return domains.get(currentDomain).Id;
            }else{
                return currentDomain == KOOZIE_DOMAIN ? KOOZIE_ACOUNT_ID : ORPHAN_ACOUNT_ID;
            }
        }else{
            return currentDomain == KOOZIE_DOMAIN ? KOOZIE_ACOUNT_ID : ORPHAN_ACOUNT_ID;
        }
    }    
    public static Map<String, List<Contact>> searchContact(Set<String> emails) {
    Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();

    List<Contact> contacts = [
        SELECT Id, Email, AccountId, Contact_Status__c
        FROM Contact
        WHERE RecordType.Name = 'CRM Contact'
        AND Email IN :emails
        ORDER BY CreatedDate DESC
    ];

    for (Contact c : contacts) {
        if (c.Email != null) {
            String emailKey = c.Email.toLowerCase();
            if (!contactMap.containsKey(emailKey)) {
                contactMap.put(emailKey, new List<Contact>());
            }
            contactMap.get(emailKey).add(c);
        }
    }

    return contactMap;
}

    private static Set<String> getDomainsFromEmails(Set<String> emails) {
        Set<String> domains = new Set<String>();
        for (String email : emails) {
            if (email != null && email.contains('@')) {
                domains.add(email.split('@')[1]);
            }
        }
        return domains;
    }
    public static CreateContactWrapper insertContact(List<Contact> contactList, List<case> caseList, Map<String,Account> accounts_DB ){
        CreateContactWrapper insertedContact = new CreateContactWrapper();
        List<Contact_Roles__c> insertContactoles = new List<Contact_Roles__c>();
        if(contactList.size() > 0){
            Insert contactList;            
            for(Contact record : contactList){
                insertedContact.contactMap.put(record.Email+record.AccountId, record);
            }            
            for(Case record : caseList){
                String  mapKey = '';
                if(record.EBS_Account_Number__c != null){
                    
                    if(accounts_DB.containsKey(record.EBS_Account_Number__c))
                        mapKey = record.SuppliedEmail + accounts_DB.get(record.EBS_Account_Number__c).Id;
                    if(insertedContact.contactMap.containsKey(mapKey)){
                        if(record.RecordTypeId != null){
                            insertContactoles.add(
                                createContactRole(
                                    insertedContact.contactMap.get(mapKey).Id, 
                                    insertedContact.contactMap.get(mapKey).AccountId,
                                    KoozieUtility.getRecordTypeName('Case', record.RecordTypeId) == CLARIFICATIONS_RT ? TagContactWithCase.CASE_RECORDTYPE.CLARIFICATIONS : TagContactWithCase.CASE_RECORDTYPE.OTHER
                                )
                            );
                        }
                    }
                } else {
                    mapKey = getMapKey( insertedContact.contactMap.keySet(), record.SuppliedEmail);
                    insertContactoles.add(
                        createContactRole(insertedContact.contactMap.get(mapKey).Id, 
                                          insertedContact.contactMap.get(mapKey).AccountId,
                                          KoozieUtility.getRecordTypeName('Case', record.RecordTypeId) == CLARIFICATIONS_RT ? TagContactWithCase.CASE_RECORDTYPE.CLARIFICATIONS : TagContactWithCase.CASE_RECORDTYPE.OTHER
                                         )
                    );
                }
            }            
            if(insertContactoles.size() > 0){
                Insert insertContactoles;
            }
            
        }
        return insertedContact; 
    }    
    public static void insertContactRole(Set<String> contactIds, List<case> caseList){ 
        List<Contact_Roles__c> insertContactoles = new List<Contact_Roles__c>(); 
        Map<String,Contact_Roles__c> contactRole_DB = checkContactRole(contactIds);
        if(contactIds.size() > 0){            
            for(Case record : caseList){
                if(record.RecordTypeId != null){
                    String caseRecordType = KoozieUtility.getRecordTypeName('Case', record.RecordTypeId) == CLARIFICATIONS_RT ? CLARIFICATIONS : SALES_SERVICE;
                    if(record.ContactId != null){
                        if(!contactRole_DB.containsKey(record.ContactId+caseRecordType)){
                            insertContactoles.add(
                                createContactRole(record.ContactId, record.AccountId,
                                                  KoozieUtility.getRecordTypeName('Case', record.RecordTypeId) == CLARIFICATIONS_RT ? TagContactWithCase.CASE_RECORDTYPE.CLARIFICATIONS : TagContactWithCase.CASE_RECORDTYPE.OTHER
                                                 )
                            );
                        }
                    }
                }
            }            
            if(insertContactoles.size() > 0){
                Insert insertContactoles;
            }
        }
    }    
    public static void tagContactWithCase(List<Case> caseList) {
        System.debug('==== START tagContactWithCase ====');
        Set<Id> contactIDs = new Set<Id>();
        Set<String> emails = new Set<String>();
        Set<String> ebsAccountNumbers = new Set<String>();
        
        for (Case c : caseList) {
            if (c.SuppliedEmail != null) emails.add(c.SuppliedEmail.toLowerCase());
            if (c.EBS_Account_Number__c != null) ebsAccountNumbers.add(c.EBS_Account_Number__c);
        }
        
        Map<String, List<Contact>> contacts_DB = searchContact(emails);
        Map<String, Account> accounts_DB = searchAccount(ebsAccountNumbers);
        Map<String, Account> domain_DB = searchAccountByDomain(getDomainsFromEmails(emails));
        
        List<Contact> contactsToInsert = new List<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Set<Id> contactIdsForCaseContactRoles = new Set<Id>();
        for (Case c : caseList) {
            if (String.isBlank(c.SuppliedEmail)) {
                continue;
            }
            
            String email = c.SuppliedEmail.toLowerCase();
            String domain = email.contains('@') ? email.split('@')[1] : null;
            String emailAccountKey = email + (c.EBS_Account_Number__c != null ? c.EBS_Account_Number__c : '');
            
            Boolean contactFound = false;
            
// Step 1: Match Email + EBS
if (!String.isBlank(c.EBS_Account_Number__c) && contacts_DB.containsKey(emailAccountKey)) {
    List<Contact> matches = contacts_DB.get(emailAccountKey);

    if (!matches.isEmpty()) {
        Contact match = matches[0];
        c.ContactId = match.Id;

        // Force Case.AccountId from EBS if it exists
        if (accounts_DB.containsKey(c.EBS_Account_Number__c)) {
            c.AccountId = accounts_DB.get(c.EBS_Account_Number__c).Id;
        } else {
            c.AccountId = match.AccountId;
        }

        contactFound = true;
        contactIdsForCaseContactRoles.add(match.Id);
    }
}

// Step 2: Match Email Only (now allowing multiple matches for same email)
if (!contactFound) {
    List<Contact> matches = contacts_DB.containsKey(email) ? contacts_DB.get(email) : new List<Contact>();

    if (!matches.isEmpty()) {
        Contact match = matches[0]; // You can apply prioritization here later
        c.ContactId = match.Id;

        // Assign Case.AccountId
        if (!String.isBlank(c.EBS_Account_Number__c) && accounts_DB.containsKey(c.EBS_Account_Number__c)) {
            c.AccountId = accounts_DB.get(c.EBS_Account_Number__c).Id; // Use EBS if supplied
        } else {
            c.AccountId = match.AccountId; // Use Contact’s Account if EBS not supplied
        }

        // Set Contact to Active if needed
        if (match.Contact_Status__c != 'Active') {
            contactsToUpdate.add(new Contact(
                Id = match.Id,
                Contact_Status__c = 'Active',
                Source__c = 'TagContactWithCase'
            ));
        }

        contactFound = true;
        contactIdsForCaseContactRoles.add(match.Id);
    }
}


  // Step 3: Try global search before creating
// Step 3: Global search before creating a new Contact
if (!contactFound) {
    List<Contact> existingList = [
        SELECT Id, Email, AccountId
        FROM Contact
        WHERE Email = :c.SuppliedEmail
          AND RecordType.Name = 'CRM Contact'
        ORDER BY CreatedDate DESC
        LIMIT 1
    ];

    if (!existingList.isEmpty()) {
        Contact existingContact = existingList[0];
        c.ContactId = existingContact.Id;
        // Don't overwrite Contact.AccountId
        contactIdsForCaseContactRoles.add(existingContact.Id);
        contactFound = true;
    }
}
            
            // Only create a new Contact if nothing is found above
            if (!contactFound) {
                Id accountIdToUse;
                if (!String.isBlank(c.EBS_Account_Number__c) && accounts_DB.containsKey(c.EBS_Account_Number__c)) {
                    accountIdToUse = accounts_DB.get(c.EBS_Account_Number__c).Id;
                } else if (domain != null && domain_DB.containsKey(domain)) {
                    accountIdToUse = domain_DB.get(domain).Id;
                } else {
                    accountIdToUse = ORPHAN_ACOUNT_ID;
                }
                
                c.AccountId = accountIdToUse;
                Contact newContact = createContact(c.SuppliedEmail, accountIdToUse, c.EBS_Account_Number__c);
                contactsToInsert.add(newContact);
            }     
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
            for (Case c : caseList) {
                if (c.ContactId == null && c.SuppliedEmail != null) {
                    for (Contact con : contactsToInsert) {
                        if (con.Email != null && con.Email.equalsIgnoreCase(c.SuppliedEmail)) {
                            c.ContactId = con.Id;
                            c.AccountId = con.AccountId;
                            contactIdsForCaseContactRoles.add(con.Id);
                            break;
                        }
                    }
                }
            }
        }
        if (!contactsToUpdate.isEmpty()) {
            update contactsToUpdate;
        }
        if (!contactIdsForCaseContactRoles.isEmpty()) {
            insertContactRole(new Set<String>( (List<String>) new List<Id>(contactIdsForCaseContactRoles) ), caseList);
        }
        System.debug('==== END tagContactWithCase ====');
    }
    public override void beforeInsert() {
        if (isTriggerActiveForTests || (triggerSetting != null && triggerSetting.Is_Active__c)) {
            tagContactWithCase(newRecords);
        }
    }
    public class CreateContactWrapper{
        public Map<String, Contact> contactMap;
        public Map<String, Contact_Roles__c> contactRoleMap;        
        public CreateContactWrapper(){
            contactMap = new Map<String, Contact>();
            contactRoleMap = new Map<String, Contact_Roles__c>();
        }
    }    
    public class CaseFilter{
        public Set<String> emailID ;
        public Set<String> accountNumber;
        public Set<String> domains;        
        public caseFilter(){
            emailID = new Set<String>();
            accountNumber = new Set<String>();
            domains = new Set<String>();
        }
    }
}