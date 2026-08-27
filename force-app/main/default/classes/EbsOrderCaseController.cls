public with sharing class EbsOrderCaseController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCasesForEbsOrder(Id caseId) {
        List<Case> relatedCases = new List<Case>();
        try {
            // Query the case based on the given Case Id
            Case cs = [SELECT Id, CaseNumber, Subject, Status, Priority, EBS_Order__c 
                       FROM Case 
                       WHERE Id = :caseId LIMIT 1];
            
            // Check if EBS_Order__c is populated to fetch related cases
            if (cs != null && cs.EBS_Order__c != null) {
                // Query all related cases using the EBS Order from the Case record,
                // excluding the case with the given caseId
                relatedCases = [SELECT Id, CaseNumber, Subject, Status, Case_Reason_Type__c, RecordType.Name  
                                FROM Case 
                                WHERE EBS_Order__c = :cs.EBS_Order__c 
                                AND Id != :caseId 
                                ORDER BY CreatedDate DESC];
                System.debug('relatedCases===> ' + relatedCases.size());
            }
        } catch (Exception e) {
            ApexLogUtill.createApexLog('EbsOrderCaseController.getCasesForEbsOrder', 'relatedCases' , e.getMessage(), caseId, 'Case', e.getMessage(), 0);
        }
        return relatedCases;
    }
}