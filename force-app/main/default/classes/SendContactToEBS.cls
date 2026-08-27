/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-18-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-08-2024   Ritesh Kumar   Initial Version
**/

public with sharing class SendContactToEBS extends TriggerHandler {
    
    private List<Contact> newRecords;
    private List<Contact> oldRecords;
    private Map<Id, Contact> newRecordsMap;
    private Map<Id, Contact> oldRecordsMap; 
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('Contact');
    private static final String WEBSITE ='WEBSITE';
    private static final String FINANCE_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId();
    private static final String INTEGRATION_SERVICE = System.Label.INTEGRATION_SERVICE;
    
    Enum DML_MODE {
        INSERT_DATA,
            UPDATE_DATA
            }
    //testing
        public override void beforeDelete() {
    if (ContactMergeContext.isMergeInProgress) {
        System.debug('SendContactToEBS: Skipping BEFORE_DELETE during merge');
        return;
    }
}

public override void afterDelete() {
    if (ContactMergeContext.isMergeInProgress) {
        System.debug('SendContactToEBS: Skipping AFTER_DELETE during merge');
        return;
    }
}
    
    public SendContactToEBS(String className){
          if (ContactMergeContext.isMergeInProgress) {
        System.debug('SendContactToEBS: HARD EXIT constructor during merge');
        return;
    }
        this.newRecords = (List<Contact>) Trigger.new;
        this.oldRecords = (List<Contact>) Trigger.old;
        this.newRecordsMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldRecordsMap = (Map<Id, Contact>) Trigger.oldMap; 
    } 
    
    public override void afterInsert() {
        System.debug(LoggingLevel.INFO,'===== SendContactToEBS: START afterInsert ====='+triggerSetting.Is_Active__c);
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        } 
        
        if(KoozieUtility.isRecursion){
            for(Contact record : newRecords){
                if( record.Responsibility_Type__c != WEBSITE && record.RecordTypeId == FINANCE_CONTACT){
                    EBSContactCallout.sendContactData(record.Id,'CREATE');
                    KoozieUtility.isRecursion = FALSE;
                }
            }    
        }
        
    } 
    
 public override void afterUpdate() {

    // CRITICAL: never run integration logic during merge
    if (ContactMergeContext.isMergeInProgress) {
        System.debug('SendContactToEBS: Skipping afterUpdate during merge');
        return;
    }

    System.debug(LoggingLevel.INFO,
        '===== SendContactToEBS : START afterUpdate ===== ' +
        triggerSetting.Is_Active__c
    );

    if (triggerSetting.Is_Active__c == false) {
        return;
    }

    if (!KoozieUtility.isRecursion) {
        return;
    }

    for (Contact record : newRecords) {

        Contact oldRec = oldRecordsMap != null
            ? oldRecordsMap.get(record.Id)
            : null;

        // SAFETY: old record can be NULL during merge/update system ops
        if (oldRec == null) {
            System.debug(
                'SendContactToEBS: old record is null, skipping Id=' + record.Id
            );
            continue;
        }

        if (
            record.Responsibility_Type__c != WEBSITE &&
            record.RecordTypeId == FINANCE_CONTACT &&
            fieldChange(record, oldRec)
        ) {

            if (record.Contact_ID__c != null) {
                EBSContactCallout.sendContactData(record.Id, 'UPDATE');
            } else {
                EBSContactCallout.sendContactData(record.Id, 'CREATE');
            }

            KoozieUtility.isRecursion = false;
        }
    }
}

    
    private static Boolean fieldChange(Contact newVersion ,Contact oldVersion){
        System.debug(LoggingLevel.INFO,'===== SendContactToEBS :fieldChange =====');
        if(newVersion.Email != oldVersion.Email){
            return TRUE;
        }
        
        if(newVersion.Other_Email__c != oldVersion.Other_Email__c){
            return TRUE;
        }
        
        if(newVersion.Phone != oldVersion.Phone){
            return TRUE;
        }
        
        if(newVersion.OtherPhone != oldVersion.OtherPhone){
            return TRUE;
        }
        
        if(newVersion.Fax != oldVersion.Fax){
            return TRUE;
        }
        
        if(newVersion.Primary_Responsibility_Flag__c != oldVersion.Primary_Responsibility_Flag__c){
            return TRUE;
        }
        
        if(newVersion.Responsibility_Type__c != oldVersion.Responsibility_Type__c){
            return TRUE;
        }
        
        if(newVersion.Contact_Status__c != oldVersion.Contact_Status__c){
            return TRUE;
        }
        
        return FALSE;
    }


}