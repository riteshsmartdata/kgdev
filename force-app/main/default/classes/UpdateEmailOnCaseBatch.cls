global class UpdateEmailOnCaseBatch Implements Database.Batchable<sObject> {
 global  Id clarificationRecordTypeId;
    global UpdateEmailOnCaseBatch(){
         clarificationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
         String query ='';
        if(test.isRunningTest()){
            query = 'Select id ,Customer_To_Email__c,createddate from case limit 1';

        }else{
            query = 'Select id ,Customer_To_Email__c,createddate from case  where createddate = today and Customer_To_Email__c =null';
            //query = 'Select id ,Customer_To_Email__c,createddate from case  where Customer_To_Email__c =null';

        }
      system.debug('query@@@@@'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Case> CaseList) {
        List<id> CaseIdList = new List<id>();
        for(case cse:CaseList){
            CaseIdList.add(cse.id);
            
        }
        system.debug('CaseIdList@@@@@@@@@@@@'+CaseIdList);
        if(!CaseIdList.isEmpty()){
             UpdateEmailOnCase.UpdateEmailFieldOnCase (CaseIdList);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}