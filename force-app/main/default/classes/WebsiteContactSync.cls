/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-13-2025   Ritesh Kumar   Initial Version
**/
public class WebsiteContactSync implements Queueable, Database.AllowsCallouts {
	List<Id> contactIds = new List<Id>();
	private static final Integer BATCH_SIZE = 50;
	private WebsiteDataSync__e eventRecord;

	public WebsiteContactSync(List<Id> contactIds ){
		//System.debug(LoggingLevel.INFO,'===== : START  WebsiteContactSync contactIds=====');
		this.contactIds = contactIds; 
	}

	public WebsiteContactSync(WebsiteDataSync__e eventRecord ){
		//System.debug(LoggingLevel.INFO,'===== : START  WebsiteContactSync eventRecord=====');
		this.contactIds = (List<Id>) JSON.deserialize(eventRecord.Record_Id__c, List<Id>.class); 
	}


	public void execute(QueueableContext context) {
		//System.debug(LoggingLevel.INFO,'===== : START  execute====='+contactIds);
		//System.debug(LoggingLevel.INFO,'===== : contactIds Size====='+contactIds.size());
		List<LogInput> logInputList = new List<LogInput>();
		List<Id> remainingContacts = new List<Id>();
		if(!contactIds.isEmpty()){
			for(Integer i = 0; i < contactIds.size(); i++){
				if (i < BATCH_SIZE) {
					String contactJson = ContactUtill.contactRequest(contactIds[i], 'CUSTOMER', 'DML').getAsString();
					logInputList.addAll(GrandNodeContactSync.contactSync(contactJson, contactIds[i]));
				}else{
					remainingContacts.add(contactIds[i]);
				}
				
			}
		}
		if(logInputList.size() > 0){
            ApexLogUtill.createApexLogs(logInputList);
        }

		if (!remainingContacts.isEmpty()) {
            System.enqueueJob(new WebsiteContactSync(remainingContacts));
        }
	} 
}