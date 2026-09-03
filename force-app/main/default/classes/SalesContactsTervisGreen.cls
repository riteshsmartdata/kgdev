/**
 * @description: Tervis Green Sales Contacts handler on ebs order
 * @author: ritesh.kumar@kooziegroup.com
 * **/


public with sharing class SalesContactsTervisGreen extends TriggerHandler {

    private static final String LOG_PREFIX = '====SalesContactsTervisGreen:';
    private static  final Set<String> RECORD_TYPES = new Set<String>{
		KoozieConstants.RECORD_TYPE_CRM_CONTACT,
		KoozieConstants.RECORD_TYPE_MULTI_LINE_REP
	};

    //Final Valiables 
    private static final Trigger_Settings__mdt TRIGGER_SETTING = Trigger_Settings__mdt.getInstance('EBS_Order');
    private static final String TERVIS_GREEN_ACCOUNT_NUMNER = KoozieConstants.TERVIS_GREEN_GRASS;

    //Trigger variable
    private List<EBS_Order__c> newRecords;
	private Map<Id,EBS_Order__c> oldRecords;

    public SalesContactsTervisGreen(String className) {
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'Constructor start. className=' + className);
        this.newRecords = (List<EBS_Order__c>) Trigger.new;
        this.oldRecords = (Map<Id, EBS_Order__c>) Trigger.oldMap;        
    }
    
    public override void beforeInsert() {
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'beforeInsert start. newRecords size=' + (newRecords != null ? newRecords.size() : 0));
        Map<String,String> emailWithAccount = new Map<String,String>();
        List<Id> tervisAccounts = new List<Id>();
        Map<String, Id> emailWithContactId = new Map<String,Id>();
        if(TRIGGER_SETTING.Is_Active__c == false) {
            return;
        }
        
        for(EBS_Order__c record : newRecords){
            if( String.isNotBlank(record.Account_Name__c) && String.isNotEmpty(record.Sales_Contact__c)){
                emailWithAccount.put(record.Sales_Contact__c,record.Account_Name__c);
            }
        }
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'Built emailWithAccount size=' + emailWithAccount.size() + ' contents=' + emailWithAccount);

        if(emailWithAccount.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'No qualifying orders (missing Account or Sales_Contact). Exiting beforeInsert.');
            return;
        }
        tervisAccounts = tervisGreenAccounts( emailWithAccount.values());
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'tervisAccounts (Tervis Green) count=' + tervisAccounts.size() + ' ids=' + tervisAccounts);
        
        if(tervisAccounts.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'Records already belong to Tervis Green accounts. Exiting beforeInsert.');
            return;
        }
        
        emailWithContactId = featchContacts(emailWithAccount.keySet(), emailWithAccount.values());
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'emailWithContactId size=' + (emailWithContactId != null ? emailWithContactId.size() : 0));

        if(emailWithContactId.isEmpty() ) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'No matching contacts found. Exiting beforeInsert.');
            return;
        }

		        
        for(EBS_Order__c record : newRecords){
            System.debug(LoggingLevel.FINE, LOG_PREFIX + 'Set SalesContact__c for Order Id=' + record.Account_Name__c + ' -> Account =' + tervisAccounts.contains(record.Account_Name__c));            
            if(String.isNotBlank(record.Account_Name__c) && tervisAccounts.contains(record.Account_Name__c)){ 
                if(emailWithContactId.containsKey(record.Sales_Contact__c)){ 
                    record.SalesContact__c = emailWithContactId.get(record.Sales_Contact__c);                  
                }else{
                    record.SalesContact__c = null;
                }
            }
        } 
         
    }
 
    public override void beforeUpdate(){
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'beforeUpdate start. newRecords size=' + (newRecords != null ? newRecords.size() : 0));
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'beforeInsert start. newRecords size=' + (newRecords != null ? newRecords.size() : 0));
        Map<String,String> emailWithAccount = new Map<String,String>();
        List<Id> tervisAccounts = new List<Id>();
        Map<String, Id> emailWithContactId = new Map<String,Id>();
        if(TRIGGER_SETTING.Is_Active__c == false) {
            return;
        }
        
        for(EBS_Order__c record : newRecords){
           System.debug(LoggingLevel.DEBUG, LOG_PREFIX+'New Value : '+record.Sales_Contact__c+ ' and Old Value'+oldRecords.get(record.id).Sales_Contact__c);
            if( String.isNotBlank(record.Account_Name__c) && record.Sales_Contact__c != oldRecords.get(record.id).Sales_Contact__c            
            ){
                emailWithAccount.put(record.Sales_Contact__c,record.Account_Name__c);
            }
        }
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'Built emailWithAccount size=' + emailWithAccount.size() + ' contents=' + emailWithAccount);

        if(emailWithAccount.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'No qualifying orders (missing Account or Sales_Contact). Exiting beforeInsert.');
            return;
        }
        tervisAccounts = tervisGreenAccounts( emailWithAccount.values());
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'tervisAccounts (Tervis Green) count=' + tervisAccounts.size() + ' ids=' + tervisAccounts);
        
        if(tervisAccounts.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'Records already belong to Tervis Green accounts. Exiting beforeInsert.');
            return;
        }
        
        emailWithContactId = featchContacts(emailWithAccount.keySet(), emailWithAccount.values());
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'emailWithContactId size=' + (emailWithContactId != null ? emailWithContactId.size() : 0)); 

        for(EBS_Order__c record : newRecords){
            if(record.Sales_Contact__c == oldRecords.get(record.id).Sales_Contact__c){
                continue;
            } 
            
            if(String.isNotBlank(record.Account_Name__c) && tervisAccounts.contains(record.Account_Name__c)){ 
                if(emailWithContactId.containsKey(record.Sales_Contact__c)){
                    record.SalesContact__c = emailWithContactId.get(record.Sales_Contact__c);
                }else{
                    record.SalesContact__c = null;
                }
            }
        }
        
    }

    /**
     * Returns the most recently created Contact Id matching the given email (case-insensitive)
     * and Account.AccountNumber. Returns null if no match.
     *     *
     * @param email Contact email to match
     * @param accountNumber Account.AccountNumber to match
     */
    public static  Map<String, Id> featchContacts(Set<String> emails, List<String> accountIds) {
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'featchContacts start. emails size=' + (emails != null ? emails.size() : 0) + ', accountIds size=' + (accountIds != null ? accountIds.size() : 0));
        Map<String, Id> emailWithContactId = new Map<String, Id>();
        if (emails.isEmpty() &&  accountIds.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'No inputs provided to featchContacts. Exiting with null.');
            return null;
        }

        for(Contact record : [
            SELECT 
                Id, Email, AccountId
            FROM 
                Contact
            WHERE
                Email IN :emails AND
                RecordTypeId IN: RECORD_TYPES  
            ORDER BY 
                RecordType.Name ASC, 
                CreatedDate DESC            
            LIMIT 50000     
        ]){ 
            emailWithContactId.put( record.Email, record.Id);
        }
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'featchContacts end. Result size=' + emailWithContactId.size());
        return emailWithContactId;
    }
    /*
    * @Description: Return the Tervis Green Grass Account Ids
    * @param : pass the set of account numbers
    */
    public static List<Id> tervisGreenAccounts (List<Id> accountIds){
       System.debug(LoggingLevel.INFO, LOG_PREFIX + 'tervisGreenAccounts start. accountIds size=' + (accountIds != null ? accountIds.size() : 0));
        List<Id> accountId = new List<Id>();
        if(accountIds.isEmpty()) {
           System.debug(LoggingLevel.INFO, LOG_PREFIX + 'No accountIds passed. Returning empty list.');
            return new List<Id>();
        }
    	
        System.debug(LoggingLevel.INFO, LOG_PREFIX + TERVIS_GREEN_ACCOUNT_NUMNER);
        for(Account record : [
            SELECT 
                id, Account.Parent.Customer_Account_Number__c 
            FROM 
                Account 
            WHERE 
                Id IN : accountIds AND 
                Account.Parent.Customer_Account_Number__c =: TERVIS_GREEN_ACCOUNT_NUMNER
        ]){
            accountId.add(record.Id);
        }
        
       System.debug(LoggingLevel.DEBUG, LOG_PREFIX + 'tervisGreenAccounts end. Matched count=' + AccountId.size() + ' ids=' + AccountId);
        return accountId;
    }    

}