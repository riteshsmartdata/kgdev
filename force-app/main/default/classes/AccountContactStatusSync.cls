/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   02-27-2025      Initial Version
**/
public with sharing class AccountContactStatusSync implements Queueable, Database.AllowsCallouts {
    Map<Id,String> accountStatus = new Map<Id,String>();
	final private String INACTIVE = 'Inactive';
	final private String ACTIVE = 'Active';
	final private String CRM_CONTACT = KoozieUtility.getRecordTypeId('Contact','CRM Contact');
	
	public AccountContactStatusSync(Map<Id,String> accountStatus) {
		this.accountStatus = accountStatus;
    }

	public void execute(QueueableContext context) {
		//System.debug(LoggingLevel.INFO,'===== : START  execute====='+accountStatus);
		List<Contact> updateContacts = new List<Contact>();

		for(Contact con : [
			SELECT 
				Id, AccountId, Account.Status__c, Contact_Status__c 
			FROM 
				Contact 
			WHERE 
				AccountId IN :accountStatus.keySet() AND
				Web_Id__c = null AND
				RecordTypeId =: CRM_CONTACT AND
				Contact_Status__c = : ACTIVE 
			]){

				if(accountStatus.containsKey(con.AccountId)){
					updateContacts.add(
						new Contact(
							Id = con.Id,
							Contact_Status__c = INACTIVE
						)	
					);
				}
		}

		//System.debug(LoggingLevel.INFO,'===== : updateContacts ====='+updateContacts);
		if(updateContacts.size() > 0){
			Database.update(updateContacts,false);
		}
		//System.debug(LoggingLevel.INFO,'===== : END  execute=====');
		
	}
}