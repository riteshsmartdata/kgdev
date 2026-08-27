public with sharing class CaseEmailExportController {
    @AuraEnabled(cacheable=false)
    public static List<EmailMessage> getEmailBatch(
        Id lastId, 
        Datetime lastCreatedDate, 
        Integer limitValue,
        String recordTypeName
    ) {
        List<Case> caseList = [
            SELECT Id
            FROM Case
            WHERE RecordType.Name = :recordTypeName
            AND CreatedDate > 2025-05-01T00:00:00Z
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
        
        if (caseList.isEmpty()) {
            return new List<EmailMessage>();
        }
        
        Set<Id> caseIds = new Map<Id, Case>(caseList).keySet();
        
        String query = 
            'SELECT ' +
            'ActivityId, AttachmentIds, AutomationType, BccAddress, Case_ThreadID_FK__c, ' +
            'CcAddress, ClientThreadIdentifier, CreatedById, CreatedDate, EBS_Account_ID__c, ' +
            'EBS_Contact_ID__c, EmailRoutingAddressId, EmailTemplateId, Email_Summary__c, ' +
            'FirstOpenedDate, FromAddress, FromId, FromName, HasAttachment, Headers, ' +
            'Id, Incoming, IsBounced, IsClientManaged, IsDeleted, IsExternallyVisible, ' +
            'IsOpened, IsPrivateDraft, IsTracked, LastModifiedById, LastModifiedDate, ' +
            'LastOpenedDate, MessageDate, MessageIdentifier, Message_ID__c, Name, ParentId, ' +
            'Parent.CaseNumber, RelatedToId, ReplyToEmailMessageId, Source, Status, Subject, ' +
            'SystemModstamp, ThreadIdentifier, ToAddress, Unique_ID__c, ValidatedFromAddress, TextBody ' +
            'FROM EmailMessage ' +
            'WHERE ParentId IN :caseIds ';
        
        if (lastCreatedDate != null && lastId != null) {
            query += 'AND (CreatedDate > :lastCreatedDate OR (CreatedDate = :lastCreatedDate AND Id > :lastId)) ';
        }
        
        query += 'ORDER BY CreatedDate ASC, Id ASC LIMIT :limitValue';
        
        return Database.query(query);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getEmailFieldLabels() {
        Map<String, String> fieldLabels = new Map<String, String>();
        
        Schema.DescribeSObjectResult describe = EmailMessage.SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = describe.fields.getMap();
        for (String apiName : fields.keySet()) {
            fieldLabels.put(apiName.toLowerCase(), fields.get(apiName).getDescribe().getLabel());
        }
        
        fieldLabels.put('casenumber', 'Case Number');
        fieldLabels.put('parentid', 'Parent Case Id');
        
        return fieldLabels;
    }
    
    
}