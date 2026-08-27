global class EBSFinanceContactBatch  implements Database.Batchable<SObject>,  Database.AllowsCallouts,   Schedulable {    
    
    Id financeRTId;
    
    global EBSFinanceContactBatch() {
        financeRTId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Contact'
            AND Name = 'Finance Contact' 
            LIMIT 1
        ].Id;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Contact
            WHERE RecordTypeId = :financeRTId
            AND Contact_Status__c = 'Active'
            AND Account.Status__c = 'Active'
        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope) {    
        
        List<Id> contactIds = new List<Id>();
        for(Contact c : scope){
            contactIds.add(c.Id);
        }
        
        if(contactIds.isEmpty()) return;

        List<EBSFinanceContactBatch.EBSContactCalloutResult> results = EBSContactIntegrationService.sendContactDataBulk(contactIds, 'Create');
        
        List<Apex_Errors__c> logs = new List<Apex_Errors__c>();
        
        for(EBSFinanceContactBatch.EBSContactCalloutResult r : results){
            if(r != null && !r.isSuccess){
                logs.add(new Apex_Errors__c(
                    Error_Date_Time__c = System.today(),
                    Error_Message__c   = r.error,
                    Object_API_Name__c = r.objectName,
                    Record_ID__c       = r.contactId,
                    Response_Body__c   = r.responseBody,
                    Request_Body__c    = r.requestBody,
                    Source__c          = r.source,
                    Status_Code__c     = r.statusCode
                ));
            }
        }
        
        if(!logs.isEmpty()){
            insert logs;
        }       
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new EBSFinanceContactBatch(), 50);
    }
                   
    public class EBSContactCalloutResult {
        public String source;
        public String requestBody;
        public String responseBody;
        public Id contactId;
        public String objectName;
        public String error;
        public Integer statusCode;
        public Boolean isSuccess;
    }
}