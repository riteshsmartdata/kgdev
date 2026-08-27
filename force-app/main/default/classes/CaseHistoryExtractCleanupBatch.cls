global class CaseHistoryExtractCleanupBatch  implements  Database.Batchable<SObject>{
    
global CaseHistoryExtractCleanupBatch() {
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query ='';
        if(test.isRunningTest()){
            query = 'SELECT Id, CreatedDate FROM Case_History_Extract__c';
        }
        else{
            //query = 'SELECT Id FROM AgentWork WHERE CreatedDate <= 2020-12-31T00:00:00Z ORDER BY CreatedDate asc';
            query = 'SELECT Id,CreatedDate FROM Case_History_Extract__c WHERE CreatedDate < THIS_YEAR';
            
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Case_History_Extract__c> CaseExlist) {
        
        List<Case_History_Extract__c> ToBeDeletedCaseHistoryExtract = new List<Case_History_Extract__c>();
        for(Case_History_Extract__c  casexl:CaseExlist){
            ToBeDeletedCaseHistoryExtract.add(casexl);
        } 

        if(ToBeDeletedCaseHistoryExtract.size()>0){
            delete ToBeDeletedCaseHistoryExtract;
        }
    }
        
       
    global void finish(Database.BatchableContext bc) {
        
    }

}