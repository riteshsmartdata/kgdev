public with sharing class SalesContactBDF extends TriggerHandler {

    private static  final Set<String> RECORD_TYPES = new Set<String>{
		KoozieConstants.RECORD_TYPE_CRM_CONTACT,
		KoozieConstants.RECORD_TYPE_MULTI_LINE_REP
	};

    private List<EBS_Order__c> newRecords;
	private Map<Id,EBS_Order__c> oldRecords;
	private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EBS_Order');

	public SalesContactBDF(String className){
		this.newRecords = (List<EBS_Order__c>) Trigger.new;
		this.oldRecords = (Map<Id,EBS_Order__c>) Trigger.oldMap; 
	}

    public override void beforeInsert() {
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        upsertContactOnOrder(newRecords);
    
    }

    public override void beforeUpdate(){
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        upsertContactOnOrder(newRecords,oldRecords);
    }

    public override void afterInsert(){
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        reParentContacts(newRecords);
    }
     
    public override void afterUpdate() {
         if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        reParentContacts(newRecords,oldRecords);

    }

    //before insert
    public static void upsertContactOnOrder(List<EBS_Order__c> newOrders){
        System.debug(LoggingLevel.INFO,'***** Start upsertContactOnOrder *****');
        Set<String> emailIds = new Set<String>();
        Set<Id> accountIds = new Set<Id>(); 
        Map<Id,Account> accounts;
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 
        List<EBS_Order__c> processOrder = new List<EBS_Order__c>();

        for(EBS_Order__c record : newOrders){
            if(String.isNotBlank(record.Distributor_Account__c)){

                if(String.isNotBlank(record.Sales_Contact__c)){
                    emailIds.add(record.Sales_Contact__c);
                }

                if(String.isNotBlank(record.Account_Name__c)){
                    accountIds.add(record.Account_Name__c);
                }
            }
        } 
 
        System.debug(LoggingLevel.INFO,'***** emailIds *****'+emailIds);
        System.debug(LoggingLevel.INFO,'***** accountIds *****'+accountIds);
 
        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() :featchContact(emailIds);
        accounts = accountIds.isEmpty()? new Map<Id,Account>(): featchAccount(accountIds); 
        System.debug(LoggingLevel.INFO,'***** existingContacts *****'+existingContacts);
        System.debug(LoggingLevel.INFO,'***** accounts *****'+accounts);
 

       for(EBS_Order__c record : newOrders){
            if(String.isNotBlank(record.Distributor_Account__c) && defaultCheck(record, accounts)){
                processOrder.add(record);
            }
            if(String.isNotBlank(record.Distributor_Account__c) && (!defaultCheck(record, accounts))){
                record.SalesContact__c = null;
            }
        }

        if(processOrder.isEmpty()){
            return;
        }
        updateAndTagContact(processOrder, accounts, existingContacts);
    }

    //before Update
    public static void upsertContactOnOrder(List<EBS_Order__c> newOrders, Map<Id, EBS_Order__c> oldOrders){
        System.debug(LoggingLevel.INFO,'***** Start upsertContactOnOrder *****');
        Set<String> emailIds = new Set<String>();
        Set<Id> accountIds = new Set<Id>(); 
        Map<Id,Account> accounts;
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 
        List<EBS_Order__c> processOrder = new List<EBS_Order__c>();

        for(EBS_Order__c record : newOrders){
            if(String.isNotBlank(record.Distributor_Account__c) && record.Sales_Contact__c != oldOrders.get(record.Id).Sales_Contact__c){
                if(String.isNotBlank(record.Sales_Contact__c)){
                    emailIds.add(record.Sales_Contact__c);
                }

                if(String.isNotBlank(record.Account_Name__c)){
                    accountIds.add(record.Account_Name__c);
                }
            }
        }
 
        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() :featchContact(emailIds);
        accounts = accountIds.isEmpty()? new Map<Id,Account>(): featchAccount(accountIds); 
        System.debug(LoggingLevel.INFO,'***** existingContacts *****'+existingContacts);
        System.debug(LoggingLevel.INFO,'***** accounts *****'+accounts);

        
        for(EBS_Order__c record : newOrders){
            if(String.isNotBlank(record.Distributor_Account__c) && defaultCheck(record, accounts) && record.Sales_Contact__c != oldOrders.get(record.Id).Sales_Contact__c){
                 processOrder.add(record);
            }

            if(String.isNotBlank(record.Distributor_Account__c) && (!defaultCheck(record, accounts)) && record.Sales_Contact__c != oldOrders.get(record.Id).Sales_Contact__c){
                record.SalesContact__c = null;
            }
        }

        if(processOrder.isEmpty()){
            return;
        }
        updateAndTagContact(processOrder, accounts, existingContacts);
    }
    
    private static void updateAndTagContact(List<EBS_Order__c> processOrder, Map<Id,Account> accounts, Map<String, Contact> existingContacts){
        System.debug(LoggingLevel.INFO,'***** Start updateAndTagContact *****');
        System.debug(LoggingLevel.INFO,'***** processOrder *****'+processOrder);
        List<Contact> upsertContacts = new List<Contact>();
        List<EBS_Order__c> updateOrders = new List<EBS_Order__c>();

        for(EBS_Order__c record : processOrder){ 
            System.debug(LoggingLevel.INFO,'*****record.Sales_Contact__c *****'+record.Sales_Contact__c);
            System.debug(LoggingLevel.INFO,'***** existingContacts record *****'+existingContacts);
            
            //Chcek and creatre contacts
            if(String.isNotBlank(record.Sales_Contact__c) && (!existingContacts.containsKey(record.Sales_Contact__c))){               
                Contact temp = createContact(record.Sales_Contact__c, record.Distributor_Account__c, record);
                System.debug(LoggingLevel.INFO,'***** temp record *****'+temp);
                if(temp != null){
                    upsertContacts.add(temp);
                }
            }
            //Assigne existing Contacts
            if(String.isNotBlank(record.Sales_Contact__c) && (existingContacts.containsKey(record.Sales_Contact__c))){               
                record.SalesContact__c = existingContacts.get(record.Sales_Contact__c).Id;
            }   
        }

        if(upsertContacts.isEmpty()){
            return;
        }

        Map<String,Contact> upsertedContacts = upsertContact(upsertContacts);


        if(upsertedContacts.isEmpty() && upsertedContacts == null){
            return;
        }

        for(EBS_Order__c record : processOrder){  
            if(upsertedContacts.containsKey(record.Sales_Contact__c)){ 
                record.SalesContact__c = upsertedContacts.get(record.Sales_Contact__c).Id;                
            }

        }
        System.debug(LoggingLevel.INFO,'***** record.Sales_Contact__c *****'+processOrder.size());
    } 

    private static Map<String,Contact> upsertContact(List<Contact> upsertContacts){
         System.debug(LoggingLevel.INFO,'***** upsertContacts *****'+upsertContacts);
        Map<String, Contact> temp = new Map<String, Contact>();
        if(upsertContacts.isEmpty()){
            return new Map<String,Contact>();
        }

        Database.upsert(upsertContacts,false);
        for (Contact record : upsertContacts) {
            temp.put(record.email, record);
        }
        System.debug(LoggingLevel.INFO,'***** Upsert Contact *****'+temp);
        return temp;        
    }

    public static void reParentContacts( List<EBS_Order__c> newRecord){
        Set<String> emailIds = new Set<String>();
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 
        List<Contact> upsertContacts = new List<Contact>();
        // This method is currently not implemented.
        System.debug(LoggingLevel.INFO,'***** reParentContacts Called *****'+newRecord);
        if(newRecord.isEmpty()){
            return;
        }

        for (EBS_Order__c record : newRecord){ 
            // Implementation to be added if needed
            if( String.isNotBlank(record.SalesContact__c) &&  String.isNotBlank(record.Distributor_Account__c) && String.isNotBlank(record.Sales_Contact__c)){ 
                emailIds.add(record.Sales_Contact__c);
            }
        }

        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() :featchContact(emailIds);

        if(existingContacts.isEmpty()){
            return;
        }

        for(EBS_Order__c record : newRecord){
            if(existingContacts.containsKey(record.Sales_Contact__c)){
                Contact contactToReparent = checkAndReparentContact(record.Distributor_Account__c, existingContacts.get(record.Sales_Contact__c));
                if(contactToReparent != null){
                    upsertContacts.add(contactToReparent);
                }
            }
        }

        if(!upsertContacts.isEmpty()){
            Database.update(upsertContacts,false);
        } 
    }

    public static void reParentContacts( List<EBS_Order__c> newRecord , Map<Id, EBS_Order__c> oldRecord){
        Set<String> emailIds = new Set<String>();
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 
        List<Contact> upsertContacts = new List<Contact>();
        // This method is currently not implemented.
        System.debug(LoggingLevel.INFO,'***** reParentContacts Called *****'+newRecord);
        if(newRecord.isEmpty()){
            return;
        }

        for (EBS_Order__c record : newRecord){ 
            // Implementation to be added if needed
            if( String.isNotBlank(record.SalesContact__c) &&  
                String.isNotBlank(record.Distributor_Account__c) && 
                String.isNotBlank(record.Sales_Contact__c) &&
                record.Sales_Contact__c != oldRecord.get(record.Id).Sales_Contact__c){ 
                emailIds.add(record.Sales_Contact__c);
            }
        }

        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() :featchContact(emailIds);

        if(existingContacts.isEmpty()){
            return;
        }

        for(EBS_Order__c record : newRecord){
            if(existingContacts.containsKey(record.Sales_Contact__c)){
                Contact contactToReparent = checkAndReparentContact(record.Distributor_Account__c, existingContacts.get(record.Sales_Contact__c));
                if(contactToReparent != null){
                    upsertContacts.add(contactToReparent);
                }
            }
        }

        if(!upsertContacts.isEmpty()){
            Database.update(upsertContacts,false);
        } 
    }

    private static Contact checkAndReparentContact(String distributorAccountId , Contact contactRecord){
        Contact record = new contact();
        if((distributorAccountId != contactRecord.AccountId) && contactRecord.RecordTypeId != KoozieConstants.RECORD_TYPE_MULTI_LINE_REP){
            record.id = contactRecord.Id;
            record.AccountId = distributorAccountId;
        }
        System.debug(LoggingLevel.INFO,'***** Reparent Contact *****'+record);
        return record;
    }

    /**
     * @Description : defaultCheck: validate if the current account is BDF or Not and email contains koozie domain
     * @Param: @record: refresh the order record. @accounts: map of account records
     * @Returntype: Boolean  
     */
    private static Boolean defaultCheck(EBS_Order__c record, Map<Id,Account> accounts){
        Boolean isDafaultCheck = FALSE;
        if(accounts.containsKey(record.Account_Name__c) && String.isNotBlank(record.Sales_Contact__c)){
            isDafaultCheck = isAccountClassCodebdf(accounts.get(record.Account_Name__c)) &&  (!record.Sales_Contact__c.contains(KoozieConstants.KOOKIE_DOMAIN)) ? TRUE:FALSE;
        }

        System.debug(LoggingLevel.INFO,'***** defaultCheck  checkKoozieDomain*****'+(isDafaultCheck));
        return isDafaultCheck;
    }

    /**
     * @Description : isAccountClassCodebdf: validate if the current account is BDF or Not
     * @Param: @record: refresh the account record.
     * @Returntype: Boolean  
     */
    private static Boolean isAccountClassCodebdf(Account record){
         System.debug(LoggingLevel.INFO,'***** defaultCheck Customer_Class_Code__c *****'+(record.Customer_Class_Code__c));
        return record.Customer_Class_Code__c == KoozieConstants.ACCOUNT_CLASS_CODE_BDF? TRUE:FALSE;
    }

    /**
     * @Description : featchContact: Featch the contact record from the Salesfroce based on emails
     * @Param: @emailIds: refresh the set of String which contains email ids
     * @Returntype: Map<Id,Contact>  
     */
    private static Map<String, Contact> featchContact(Set<String> emailIds){
        System.debug(LoggingLevel.INFO,'***** Featch Contact By Emails *****'+emailIds);
        if(emailIds.isEmpty()){
            return new Map<String, Contact>();
        }

        Map<String, Contact> contactData = new Map<String, Contact>();

        for(contact record :[
            SELECT 
                Id, Email, AccountId, RecordTypeId
            FROM 
                contact 
            WHERE 
                RecordTypeId IN: RECORD_TYPES AND
                Email In: emailIds 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate 
            LIMIT 50000
        ]){
            contactData.put(record.Email, record);
        }

        return contactData;
    }

    /**
     * @Description : featchContactById: Featch the contact record from the Salesfroce based on contactids
     * @Param: @contactIds: refresh the set of contact ids
     * @Returntype: Map<Id,Contact>  
     */
    private static Map<Id, Contact> featchContactById(Set<Id> contactIds){
        System.debug(LoggingLevel.INFO,'***** Featch Contact By Id *****'+contactIds);
        if(contactIds.isEmpty()){
            return new Map<Id, Contact>();
        }

        Map<Id, Contact> contactData = new Map<Id, Contact>();

        for(contact record :[
            SELECT 
                Id, Email, AccountId, RecordTypeId
            FROM 
                contact 
            WHERE 
                RecordTypeId IN: RECORD_TYPES AND
                Id In: contactIds 
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate 
            LIMIT 50000
        ]){
            contactData.put(record.Id, record);
        }

        return contactData;
    }

    /**
     * @Description : featchAccount: Featch the account record from the Salesfroce based on accountIds
     * @Param: @accountIds: refresh the set of account ids
     * @Returntype: Map<Id,Account>  
     */
    private static Map<Id, Account> featchAccount(Set<Id> accountIds){
        System.debug(LoggingLevel.INFO,'***** Featch Account *****'+accountIds);
        if(accountIds.isEmpty()){
            return new Map<Id, Account>();
        }

         return new Map<Id, Account>([
            SELECT 
                Id, Customer_Class_Code__c, Customer_Account_Number__c 
            FROM 
                Account 
            WHERE 
                Id In: accountIds
            WITH 
                SECURITY_ENFORCED
            ORDER BY 
                CreatedDate 
            LIMIT 50000
        ]); 
    }

    /**
     * @Description : createcontact : use to create contact when contact is not present in salesforce
     * @Param: @email: refres the sales contact email , @accountId: refres the distributor account Id and @orderRecord : refresh the EBS record
     * @retrun type is contact record (object)
     */
    private static Contact createContact(String email, String accountId,EBS_Order__c orderRecord){
		Contact record = new Contact ();
		record.FirstName = String.isNotBlank(orderRecord.Sales_Contact_First_Name__c)? orderRecord.Sales_Contact_First_Name__c : KoozieConstants.CONTACT_FIRST_NAME_VALUED;
		record.LastName = String.isNotBlank(orderRecord.Sales_Contact_Last_Name__c)? orderRecord.Sales_Contact_Last_Name__c :KoozieConstants.CONTACT_LAST_NAME_CUSTOMER;
		record.RecordTypeId = KoozieConstants.RECORD_TYPE_CRM_CONTACT;
		record.Email = email;
		record.AccountId = accountId;
        System.debug(LoggingLevel.INFO,'***** create Contact *****'+record);
		return record;
	} 
}