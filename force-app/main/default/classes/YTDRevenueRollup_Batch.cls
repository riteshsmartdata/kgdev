public with sharing class YTDRevenueRollup_Batch implements Database.Batchable<SObject>, Database.Stateful {
    
    private Id customerRecordTypeId;
    private Set<Id> specificAccountIds;
    
        // Constructor to run for all Accounts
    public YTDRevenueRollup_Batch() {
        this.specificAccountIds = new Set<Id>();
    }
    // Constructor for selective Accounts
    public YTDRevenueRollup_Batch(Set<Id> accountIds) {
        this.specificAccountIds = accountIds != null ? accountIds : new Set<Id>();
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customers').getRecordTypeId();

        if (!specificAccountIds.isEmpty()) {
            return Database.getQueryLocator([
                SELECT Id FROM Account WHERE Id IN :specificAccountIds
            ]);
        }
        return Database.getQueryLocator([
            SELECT Id FROM Account WHERE Status__c= 'Active' AND
            RecordTypeId = :customerRecordTypeId
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Set<Id> accIds = new Map<Id, Account>(scope).keySet();
        YTDRevenueRollupService.updateYTDRevenue(accIds);
    }
    
    public void finish(Database.BatchableContext bc) {
    }
}