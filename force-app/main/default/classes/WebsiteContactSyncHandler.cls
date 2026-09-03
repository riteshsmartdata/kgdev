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
public with sharing class WebsiteContactSyncHandler extends TriggerHandler  {
	private List<Contact> newRecords;
    private List<Contact> oldRecords;
    private Map<Id, Contact> newRecordsMap;
    private Map<Id, Contact> oldRecordsMap; 
	private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('Contact');
	private static final String CRM_CONTACT = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');
	private String WEB_USER = System.Label.WebsiteUserId;

public override void beforeDelete() {
    if (ContactMergeContext.isMergeInProgress || triggerSetting.Is_Active__c == FALSE) {
        System.debug('SendContactToEBS: Skipping BEFORE_DELETE');
        return;
    }
}

public override void afterDelete() {
    if (ContactMergeContext.isMergeInProgress || triggerSetting.Is_Active__c == FALSE) {
        System.debug('SendContactToEBS: Skipping AFTER_DELETE');
        return;
    }
}
    
    public WebsiteContactSyncHandler(String className ) {
         if (ContactMergeContext.isMergeInProgress) {
        System.debug('SendContactToEBS: HARD EXIT constructor during merge');
        return;
    }
		//System.debug(LoggingLevel.INFO,'===== ' + className + ': START =====');
		this.newRecords = (List<Contact>) Trigger.new;
        this.oldRecords = (List<Contact>) Trigger.old;
        this.newRecordsMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Contact>) Trigger.oldMap; 
    }

	public override void afterInsert(){
		//System.debug(LoggingLevel.INFO,'===== : START  afterInsert=====');
		List<Id> contactIds = new List<Id>(); 
		if(triggerSetting.Is_Active__c == FALSE){
            return;
        }

		for(Contact record : newRecords){
			if(record.RecordTypeId == CRM_CONTACT && record.LastModifiedById != WEB_USER){
				contactIds.add(record.id);
			}
		}
		
		if(contactIds.size()>0){  
			//System.enqueueJob(new WebsiteContactSync(contactIds)); 
			//System.debug(LoggingLevel.INFO,'===== : Event: WebsiteDataSync__e====='+contactIds.size());
			WebsiteDataSync__e  callout = new WebsiteDataSync__e (
				Record_Id__c =  JSON.serialize(contactIds)
			);
			EventBus.publish(callout);
		}
	}

public override void afterUpdate() {

    // Skip completely during merge
    if (ContactMergeContext.isMergeInProgress || triggerSetting.Is_Active__c == FALSE) {
        System.debug('WebsiteContactSyncHandler: Skipping afterUpdate during merge');
        return;
    }

    List<Id> contactIds = new List<Id>();

    for (Contact record : newRecords) {

        Contact oldRec = oldRecordsMap != null ? oldRecordsMap.get(record.Id) : null;
        if (oldRec == null) continue;

        Boolean hasDiff =
            ContactUtill.getFieldDifference(record, oldRec).size() > 0;

        if (
            record.RecordTypeId == CRM_CONTACT &&
            hasDiff &&
            record.LastModifiedById != WEB_USER
        ) {
            contactIds.add(record.Id);
        }
    }

    if (!contactIds.isEmpty()) {
        WebsiteDataSync__e evt = new WebsiteDataSync__e(
            Record_Id__c = JSON.serialize(contactIds)
        );
        EventBus.publish(evt);
    }
}



}