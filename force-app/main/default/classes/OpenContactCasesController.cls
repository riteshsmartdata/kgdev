public with sharing class OpenContactCasesController  {
    @AuraEnabled(cacheable=true)
    public static List<Case> getOpenCases(Id recordId) {
        try {
            Case currentCase = [
                SELECT AccountId, ContactId 
                FROM Case 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (currentCase.ContactId == null) {
                return new List<Case>();
            }
            
            return [
                SELECT Id, CaseNumber, Subject, Status, RecordType.Name, Case_Reason_Type__c, EBS_Order_Number__c, PO_Number__c
                FROM Case
                WHERE Status NOT IN ('Closed', 'Merged - Duplicate', 'Merged','Awaiting Response (Internal)', 'Awaiting Response (External)', 
                                     'Awaiting Response from IT', 
                                     'Awaiting Business Response'
                                    )
                AND ContactId != null
                AND ContactId = :currentCase.ContactId
                AND Id != :recordId
                ORDER BY CreatedDate DESC
                LIMIT 50000
            ];
            
            
        } catch (Exception e) {
            System.debug('Error in getRejectedOpenCases: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());
            return new List<Case>();
        }
    }
}