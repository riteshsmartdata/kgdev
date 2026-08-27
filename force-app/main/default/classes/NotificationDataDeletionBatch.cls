global class NotificationDataDeletionBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [SELECT Id 
             FROM Notification__c 
             WHERE EBS_Order__r.Status__c IN ('Closed', 'Cancelled') 
             AND EBS_Order__r.CreatedDate <= :System.now().addDays(-30)]
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Notification__c> scope) {
        try {
            Database.delete(scope, false);
        } catch (Exception e) {
            System.debug('Error while deleting notifications: ' + e.getMessage());
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}