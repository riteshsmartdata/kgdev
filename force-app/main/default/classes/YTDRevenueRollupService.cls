public without sharing class YTDRevenueRollupService {
    /*
     * Calculate YTD Revenue for a list of Accounts by summing Invoice__c amount
     * for invoices in the current calendar year, grouped by Invoice__c.Account__c.
     * chunk the Account Ids into small lists and aggregate per chunk.
     */
    public static void updateYTDRevenue(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        // Aggregate invoices per Account for THIS_YEAR using CHUNKED GROUP BY by Account scope.
        Map<Id, Decimal> accountRevenueMap = new Map<Id, Decimal>();

        // Chunk the incoming Account Ids to keep each aggregate query small and under limits.
        // Chunk size chosen conservatively; batch scope is typically ~200, but we guard anyway.
        final Integer CHUNK_SIZE = 200;
        List<Id> allIds = new List<Id>(accountIds);
        Integer i = 0;
        while (i < allIds.size()) {
            // Build chunk manually to avoid subList signature issues
            List<Id> chunk = new List<Id>();
            Integer endIdx = Math.min(i + CHUNK_SIZE, allIds.size());
            for (Integer k = i; k < endIdx; k++) {
                chunk.add(allIds[k]);
            }
          
            for (AggregateResult ar : [
                SELECT Account__c acctId, SUM(Line_Total__c) totalAmt
                FROM Invoice__c
                WHERE Account__c IN :chunk
                AND Invoice_Date__c = THIS_YEAR
                AND Account__c != null
                AND Type__c = 'INVOICE'
                GROUP BY Account__c
            ]) {
                Id acctId = (Id) ar.get('acctId');
                Decimal total = (Decimal) ar.get('totalAmt');
                if (acctId != null) {
                    accountRevenueMap.put(acctId, total == null ? 0 : total);
                }
            }
            i += CHUNK_SIZE;
        }

        if (accountRevenueMap.isEmpty()) {
            return;
        }

        // Bulk update Accounts with YTD totals with partial success and error logging via ApexLogUtill
        List<Account> toUpdate = new List<Account>();
        for (Id accId : accountRevenueMap.keySet()) {
            toUpdate.add(new Account(
                Id = accId,
                YTD_Revenue__c = accountRevenueMap.get(accId)
            ));
        }
        if (!toUpdate.isEmpty()) {
            Database.SaveResult[] srList = Database.update(toUpdate, false);
            system.debug('updated List'+srlist);
            List<Apex_Errors__c> errorLogs = new List<Apex_Errors__c>();
            for (Integer j = 0; j < srList.size(); j++) {
                if (!srList[j].isSuccess()) {
                    system.debug('Error List'+srList[j]);
                    Database.Error err = srList[j].getErrors().isEmpty() ? null : srList[j].getErrors()[0];
                    String errMsg = err == null ? 'Unknown error' : err.getMessage();
                    system.debug('error message - '+errMsg);
                    errorLogs.add(ApexLogUtill.assignApexLog(
                        'YTDRevenueRollupService.updateYTDRevenue',
                        null,
                        null,
                        toUpdate[j].Id,
                        'Account',
                        errMsg,
                        500
                    ));
                }
            }
            if (!errorLogs.isEmpty()) {
                Database.insert(errorLogs, false);
            }
        }
    }
    
    //method to filter and return AccountIds for Customers record type from a given set
    public static Set<Id> getCustomerAccountIds(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return new Set<Id>();
        }
        
        Set<Id> customerIds = new Set<Id>();
        for (Account acc : [
            SELECT Id, RecordType.DeveloperName 
            FROM Account 
            WHERE Id IN :accountIds 
            AND RecordType.DeveloperName = 'Customers'
        ]) {
            customerIds.add(acc.Id);
        }
        return customerIds;
    }
}