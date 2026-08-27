global class DeleteOldNotificationsBatch implements Database.Batchable<SObject>, Schedulable {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([ SELECT Id FROM Notification__c WHERE Status__c = 'delivered' AND CreatedDate < LAST_N_DAYS:90]);
    }
    
    global void execute(Database.BatchableContext bc, List<Notification__c> scope) {
        if(!scope.isEmpty()){
            delete scope;
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }

    global void execute(SchedulableContext sc) {

        // Batch call from scheduler
        Database.executeBatch(new DeleteOldNotificationsBatch(), 200);
    }
}