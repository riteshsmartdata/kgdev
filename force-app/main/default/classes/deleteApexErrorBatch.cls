//Created by Kumar Saurav

public class deleteApexErrorBatch implements Database.Batchable<sObject>{
    /*public deleteApexErrorBatch() {
    }*/
    public Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'select id  from Apex_Errors__c where createdDate < LAST_N_DAYS:30';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Apex_Errors__c> apexErrorList){
        if(apexErrorList.size() > 0){
            delete apexErrorList;
        }
    }
    public void finish(Database.BatchableContext BC){
    }
    /*public void execute(SchedulableContext SC) {
 	database.executebatch(new deleteApexErrorBatch());
    }*/
}