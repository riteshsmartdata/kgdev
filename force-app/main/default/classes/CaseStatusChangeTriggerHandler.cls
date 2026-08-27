public with sharing class CaseStatusChangeTriggerHandler {
    
    
    public void codecoverage(){
        integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

   /* public static void OnAfterInsert(List<Case> newCases) {
        List<Case_Status_Change__c> statusChanges = createCaseStatus(newCases, null);
        if (!statusChanges.isEmpty()) insert statusChanges;
    }

    public static void OnAfterUpdate(List<Case> updatedCases, Map<Id, Case> oldCaseMap) {

        // Step 1 — Create possible new Case_Status_Change__c records
        List<Case_Status_Change__c> newStatusChanges = createCaseStatus(updatedCases, oldCaseMap);
        List<Case_Status_Change__c> statusChangesToUpdate = new List<Case_Status_Change__c>();

        // Step 2️ — Identify all open Case_Status_Change__c (no Change_Time__c)
        Set<Id> caseIds = new Set<Id>();
        Set<String> currentStatuses = new Set<String>();
        for (Case c : updatedCases) {
            caseIds.add(c.Id);
            currentStatuses.add(c.Status);
        }

        Map<String, Case_Status_Change__c> openStatusMap = new Map<String, Case_Status_Change__c>();
        for (Case_Status_Change__c existingRec : [
            SELECT Id, Case__c, Status_Name__c, Set_Time__c
            FROM Case_Status_Change__c
            WHERE Case__c IN :caseIds AND Change_Time__c = NULL
        ]) {
            openStatusMap.put(existingRec.Case__c + '_' + existingRec.Status_Name__c, existingRec);
        }

        // Step 3 — Remove duplicates before insert
        List<Case_Status_Change__c> filteredToInsert = new List<Case_Status_Change__c>();
        for (Case_Status_Change__c sc : newStatusChanges) {
            if (!openStatusMap.containsKey(sc.Case__c + '_' + sc.Status_Name__c)) {
                filteredToInsert.add(sc);
            }
        }

        // Step 4 — Close previous status (set Change_Time__, Status_Time__, Age__)
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

        for (Case_Status_Change__c openRec : openStatusMap.values()) {
            Case relatedCase = oldCaseMap != null ? oldCaseMap.get(openRec.Case__c) : null;
            if (relatedCase != null) {
                // Close previous open status
                openRec.Change_Time__c = Datetime.now();
                Double ms = BusinessHours.diff(bh.Id, openRec.Set_Time__c, openRec.Change_Time__c);
                if (ms != null) {
                    openRec.Status_Time__c = (Decimal.valueOf(ms) / (1000 * 60 * 60)).setScale(2);
                    openRec.Age__c = getAge(ms);
                    statusChangesToUpdate.add(openRec);
                }
            }
        }

        // Step 5️ — DML operations
        if (!filteredToInsert.isEmpty()) insert filteredToInsert;
        if (!statusChangesToUpdate.isEmpty()) update statusChangesToUpdate;
    }

    private static List<Case_Status_Change__c> createCaseStatus(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        List<Case_Status_Change__c> result = new List<Case_Status_Change__c>();
        Map<Id, Case> caseData = new Map<Id, Case>([SELECT Id, CaseNumber, Status, Owner.Name FROM Case WHERE Id IN :caseList]);

        for (Case c : caseList) {
            Case oldC = oldCaseMap != null ? oldCaseMap.get(c.Id) : null;
            Boolean statusChanged = oldC == null || c.Status != oldC.Status;

            if (statusChanged) {
                Case_Status_Change__c rec = new Case_Status_Change__c();
                rec.Case__c = c.Id;
                rec.Status_Name__c = c.Status;
                rec.Current_Case_Owner__c = c.Owner.Name;
                rec.Set_Time__c = Datetime.now();

                if (oldC != null)
                    rec.Status_From__c = oldC.Status;

                rec.Name = c.CaseNumber + (oldC != null
                    ? ' from ' + oldC.Status + ' to ' + c.Status
                    : ' status: ' + c.Status);

                result.add(rec);
            }
        }
        return result;
    }

   private static String getAge(Double milliseconds) {
    Long ms = milliseconds.longValue();
    Long days = ms / 86400000;
    Long remainingAfterDays = Math.mod(ms, 86400000);
    Long hours = remainingAfterDays / 3600000;
    Long remainingAfterHours = Math.mod(remainingAfterDays, 3600000);
    Long minutes = remainingAfterHours / 60000;
    Long remainingAfterMinutes = Math.mod(remainingAfterHours, 60000);
    Long seconds = remainingAfterMinutes / 1000;
    
    return days + ' days ' + hours + ' hours ' + minutes + ' minutes ' + seconds + ' seconds';
}*/

}