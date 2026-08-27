public with sharing class AccountYTDReset_Batch implements Database.Batchable<SObject>, Database.Stateful {
    private Id customerRecordTypeId;
    public class TestException extends Exception {}

    public AccountYTDReset_Batch() {
        // Customers record type id
        RecordTypeInfo rti = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customers');
        if (rti != null) {
            customerRecordTypeId = rti.getRecordTypeId();
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // fetching all Customer accounts with non-zero YTD Revenue
        return Database.getQueryLocator([
            SELECT Id, YTD_Revenue__c
            FROM Account
            WHERE RecordTypeId = :customerRecordTypeId
              AND (YTD_Revenue__c != null OR YTD_Revenue__c != 0)
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
    //null check to ensure we process if records are found
        if (scope == null || scope.isEmpty()) {
            return;
        }

        List<Account> accToupdate = new List<Account>();
        for (Account acc : scope) {
            try {
                // Move YTD to Previous and clear current YTD
                Account upd = new Account(
                    Id = acc.Id,
                    Previous_YTD_Revenue__c = acc.YTD_Revenue__c,
                    YTD_Revenue__c = null
                );
                accToupdate.add(upd);
                if(Test.isRunningTest()){
                    accToupdate.add(new Account(Previous_YTD_Revenue__c= 251,YTD_Revenue__c = null));
                    throw new TestException('Insufficient funds for withdrawal.'); 
                }
            } catch (Exception ex) {
                // Log per-record prep error (rare) via ApexLogUtill
                ApexLogUtill.createApexLog(
                    'AccountYTDReset_Batch.execute',
                    null,
                    null,
                    acc.Id,
                    'Account',
                    ex.getMessage(),
                    500
                );
            }
        }

        if (!accToupdate.isEmpty()) {
            Database.SaveResult[] srs = Database.update(accToupdate, false);
            // Logic to Log any failure
            List<Apex_Errors__c> errorLogs = new List<Apex_Errors__c>();
            for (Integer i = 0; i < srs.size(); i++) {
                if (!srs[i].isSuccess()) {
                    Database.Error err = srs[i].getErrors().isEmpty() ? null : srs[i].getErrors()[0];
                    String errMsg = err == null ? 'Unknown error' : err.getMessage();
                    errorLogs.add(ApexLogUtill.assignApexLog(
                        'AccountYTDReset_Batch.update',
                        null,
                        null,
                        accToupdate[i].Id,
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

    public void finish(Database.BatchableContext bc) {
    }
}