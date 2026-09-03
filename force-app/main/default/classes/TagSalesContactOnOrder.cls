public without sharing class TagSalesContactOnOrder extends TriggerHandler {

    private static  final Set<String> RECORD_TYPES = new Set<String>{
		KoozieConstants.RECORD_TYPE_CRM_CONTACT
	};
    //, KoozieConstants.RECORD_TYPE_MULTI_LINE_REP

    private List<EBS_Order__c> newRecords;
	private Map<Id,EBS_Order__c> oldRecords;
	private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EBS_Order');

	public TagSalesContactOnOrder(String className){
		this.newRecords = (List<EBS_Order__c>) Trigger.new;
		this.oldRecords = (Map<Id,EBS_Order__c>) Trigger.oldMap; 
	}

    public override void beforeInsert() {
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        tagContactOnOrder(newRecords);
    
    }

    public override void beforeUpdate(){
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        tagContactOnOrder(newRecords,oldRecords);
    } 



    //before insert
    public static void tagContactOnOrder(List<EBS_Order__c> newOrders){
        System.debug(LoggingLevel.INFO,'##### Start upsertContactOnOrder #####');
        Set<String> emailIds = new Set<String>();
        Set<Id> accountIds = new Set<Id>(); 
        Map<Id,Account> accounts;
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 

        for(EBS_Order__c record : newOrders){            
            if(String.isNotBlank(record.Sales_Contact__c)){
                emailIds.add(record.Sales_Contact__c);
            } 
        } 
  
        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() :featchContact(emailIds);
        System.debug(LoggingLevel.INFO,'##### existingContacts #####'+existingContacts);
         

       for(EBS_Order__c record : newOrders){
             
            if(String.isNotBlank(record.Sales_Contact__c) && existingContacts.containsKey(record.Sales_Contact__c) && String.isBlank(record.SalesContact__c)){
                record.SalesContact__c = existingContacts.get(record.Sales_Contact__c).Id;
            }
        }
 
    }

    //before Update
    public static void tagContactOnOrder(List<EBS_Order__c> newOrders, Map<Id, EBS_Order__c> oldOrders){
        System.debug(LoggingLevel.INFO,'##### Start upsertContactOnOrder #####');
        Set<String> emailIds = new Set<String>(); 
        Map<String, Contact> existingContacts = new Map<String,Contact>(); 

        for(EBS_Order__c record : newOrders){
            
                if(String.isNotBlank(record.Sales_Contact__c)){
                    emailIds.add(record.Sales_Contact__c);
                } 
        }
        
        existingContacts = emailIds.isEmpty()? new Map<String,Contact>() : featchContact(emailIds); 
        System.debug(LoggingLevel.INFO,'##### existingContacts #####'+existingContacts);

        
        for(EBS_Order__c record : newOrders){
            if( record.Sales_Contact__c != oldOrders.get(record.Id).Sales_Contact__c && String.isNotBlank(record.Sales_Contact__c) && existingContacts.containsKey(record.Sales_Contact__c)){
                record.SalesContact__c = existingContacts.get(record.Sales_Contact__c).Id;
            }
 
        }
 
    }
     
    /**
     * @Description : featchContact: Featch the contact record from the Salesfroce based on emails
     * @Param: @emailIds: refresh the set of String which contains email ids
     * @Returntype: Map<Id,Contact>  
     */
    private static Map<String, Contact> featchContact(Set<String> emailIds){
        System.debug(LoggingLevel.INFO,'##### Featch Contact By Emails #####'+emailIds);
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
            ORDER BY CreatedDate DESC
            LIMIT 50000
        ]){
            contactData.put(record.Email, record);
        }
         System.debug(LoggingLevel.INFO,'##### Featch Contact By Emails Result #####'+contactData);
        return contactData;
    }

}