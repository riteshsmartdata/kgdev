/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-07-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   01-17-2024   Ritesh Kumar   SF-1330
**/
public with sharing class CreateContactHistoryEmail {

    final static String FORMS = 'Forms';
    final static String SERVICE_REQUEST = 'Service Request';
    final static String CARE_KREW_SF_REQUEST = 'Care Krew SF Request';
    final static String CHANGE_REQUEST = 'Change Request';    
    final static String SF_MAINTENANCE_DATA_REQUEST = 'SF Maintenance/Data/Request';
    final static String CASE_OBJECT = 'Case';
    final static String KOOZIEGROUP_COM_DOMAIN = '@kooziegroup.com';
    final static String CS_INFO_EMAIL = 'csinfo@calendarcs.com';
    final static String TYPE_EMAIL = 'Email';
    final static Set<String> EMAIL_STATUS = new Set<String>{'0','1','5'};
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EmailMessage');


    public static Boolean emailMessageHandler(List<EmailMessage> newEmail, Map<Id, EmailMessage> oldEmail){
        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler ===== : ');
        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : newEmail ===== : '+newEmail);
        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : oldEmail ===== : '+oldEmail);
         if(triggerSetting.Is_Active__c == FALSE){
            return FALSE;
        }

        Map<Id, String> caseWithEmail = new Map<Id, String>();
        Set<String> caseRecordType = new Set<String>{FORMS,SERVICE_REQUEST,CARE_KREW_SF_REQUEST,CHANGE_REQUEST,SF_MAINTENANCE_DATA_REQUEST};
        Map<Id, Case> caseRecords = new Map<Id, Case>();
        Map<Id,ContactHistory__c> insertContactHistorys = new Map<Id,ContactHistory__c>();
        Map<Id, Case> updateCaseRecords = new Map<Id, Case>();

        for(EmailMessage message : newEmail){
            System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : RelatedToId ===== : '+message.RelatedToId);
            System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : Status ===== : '+message.Status);
            if( message.RelatedToId != null && KoozieUtility.getObjectNameById(message.RelatedToId) == CASE_OBJECT && (! EMAIL_STATUS.contains(message.Status))){
                caseWithEmail.put(message.Id, message.RelatedToId);
            }
        }

        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : caseWithEmail ===== : '+caseWithEmail);
        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : caseRecordType ===== : '+caseRecordType);

        caseRecords = new Map<Id, Case>([SELECT Id , ContactLogged__c, Case_Record_Type__c FROM Case WHERE Id IN: caseWithEmail.values() AND Case_Record_Type__c NOT IN : caseRecordType LIMIT 50000 ]);

        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : caseRecords ===== : '+caseRecords);

        for(EmailMessage emailRecord : newEmail ){
            System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : emailRecord ===== : '+emailRecord.FromAddress);
            System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : caseRecords ===== : '+emailRecord.ToAddress);

            if(
                checkString(emailRecord.FromAddress)&& 
                checkString(emailRecord.ToAddress) &&
                (emailRecord.FromAddress.contains(KOOZIEGROUP_COM_DOMAIN) || emailRecord.FromAddress == CS_INFO_EMAIL) && 
                (!emailRecord.ToAddress.contains(KOOZIEGROUP_COM_DOMAIN))  && 
                emailRecord.ToAddress != CS_INFO_EMAIL 
            ){
                System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : caseRecords ===== : '+emailRecord);
                if(caseWithEmail.containsKey(emailRecord.Id)){

                    insertContactHistorys.put(emailRecord.Id,createContactHistory(emailRecord.RelatedToId));
                    if(caseRecords.containsKey(emailRecord.RelatedToId)){
                        updateCaseRecords.put(emailRecord.RelatedToId,updateContactLog(emailRecord.RelatedToId));
                    }
                }
            }
        }

        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : insertContactHistorys ===== : '+insertContactHistorys);
        if(!insertContactHistorys.isEmpty()){
            System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : insertContactHistorys Size ===== : '+insertContactHistorys.values().size());
            Database.insert(insertContactHistorys.values(),FALSE);
        }

        System.debug(LoggingLevel.INFO,'===== CreateContactHistoryEmail : emailMessageHandler : updateCaseRecords ===== : '+updateCaseRecords.values());
        if(!updateCaseRecords.isEmpty()){
            Database.Update(updateCaseRecords.values(),FALSE);
        }

        return FALSE;
    }

    private static ContactHistory__c createContactHistory(String caseId){
        ContactHistory__c record = new ContactHistory__c();
        record.Case__c = caseId;
        record.Type__c = TYPE_EMAIL;
        return record;  
    }
    
    private static Boolean checkString(String email){
        return email != NULL && email != '' ? TRUE : FALSE;  
    }

    private static Case updateContactLog(String caseId){
        Case record = new Case();
        record.Id = caseId;
        record.ContactLogged__c = TRUE;
        return record;  
    }

}