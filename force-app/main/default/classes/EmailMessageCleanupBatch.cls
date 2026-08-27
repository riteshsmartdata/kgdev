global class EmailMessageCleanupBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // fetch older then 90 days related to ebs order object and on ebd order we have field order status - closed ,Cancelled
        set<id> EBSOrderSet = new set<id>();
        list<EBS_Order__c> Orderlist = [SELECT Id FROM EBS_Order__c WHERE (Order_Header_Status__c = 'Cancelled' OR Order_Header_Status__c = 'Closed') 
                                           AND Id IN (SELECT RelatedToId From EmailMessage Where CreatedDate >=LAST_N_DAYS:60)LIMIT 50000];
                
            
               
                
            
      system.debug('Orderlist@@@@@@@@@@@@@'+Orderlist.size());
        if(!Orderlist.isempty()){
            for(EBS_Order__c ord:Orderlist){
                EBSOrderSet.add(ord.id);
            }
        }
        String query = '';
        if(Test.isRunningTest()){
            query = 'SELECT Id, CreatedDate, Parent.RecordType.Name FROM EmailMessage';
        }
        else{
         //   query = 'SELECT Id, CreatedDate, Parent.RecordType.Name FROM EmailMessage WHERE CreatedDate < LAST_N_DAYS:60 AND  RelatedToId IN :EBSOrderSet ';
            query = 'SELECT Id, CreatedDate, Parent.RecordType.Name FROM EmailMessage WHERE RelatedToId IN :EBSOrderSet ';

        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<EmailMessage> messages) {
        system.debug('messages@@@@@@@@@@@@@@'+messages.size());
        List<EmailMessage> messagesToDelete = new List<EmailMessage>();
        for (EmailMessage message : messages) {
            messagesToDelete.add(message);
        }
        System.debug('message to delete@@@@@@'+messagesToDelete.size());
        delete messagesToDelete;
    }
    
    global void finish(Database.BatchableContext bc) {
        // Schedule the next batch job here if needed
    }
}