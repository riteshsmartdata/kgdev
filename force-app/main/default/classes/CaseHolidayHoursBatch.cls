global class CaseHolidayHoursBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Batch Start Method Invoked');
        Date startDate = Date.newInstance(2023, 1, 1);
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, ReOpen_Date__c 
            FROM Case
            WHERE Case_Record_Type__c NOT IN ('xForms', 'xChange Request', 'SF Maintenance/Data/Request', 'xService Request', 'Care Krew SF Request')
            AND Status != 'Closed'
            AND (CreatedDate >= :startDate OR ReOpen_Date__c >= :startDate)
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        
        if (scope.isEmpty()) {
            return;
        }
        System.debug('scope==>.'+ scope.Size());
        
        // Fetch all holiday records once
        Map<Date, Integer> holidayMap = new Map<Date, Integer>();
        for (Holidays_2__c h : [SELECT Holiday_Date__c FROM Holidays_2__c WHERE Holiday_Date__c <= :Date.today()]) {
            holidayMap.put(h.Holiday_Date__c, 1);
        }
        
        List<Case> casesToUpdate = new List<Case>();
        
        for (SObject sObj : scope) {
            Case c = (Case) sObj;
            Date caseStartDate = (c.ReOpen_Date__c != null) ? c.ReOpen_Date__c.date() : c.CreatedDate.date();
            
            // Count holidays in the case's date range
            Integer holidayCount = 0;
            for (Date holidayDate : holidayMap.keySet()) {
                if (holidayDate >= caseStartDate) {
                    holidayCount++;
                }
            }
            
            c.Holiday_Hours__c = holidayCount * 12.5; 
            c.Holiday_Count__c = holidayCount;
            casesToUpdate.add(c);
            
        }
        
        // Perform update
        if (!casesToUpdate.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(casesToUpdate, false);
            for (Database.SaveResult result : saveResults) {
                if (!result.isSuccess()) {
                } else {
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Process Completed.');
    }
}