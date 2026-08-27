Public class deleteEmailLink implements Database.batchable<sObject> {
    Public Database.QueryLocator Start(Database.BatchableContext BC){
        string query = 'Select Id,name From Email_Link__c Where CreatedDate < LAST_N_YEARS:2 ';
        return Database.getQueryLocator(query); 
        
    }
    Public void execute(Database.BatchableContext BC,List<Email_Link__c> EmailLinklist){
        try{
            system.debug('emaillinklist1'+ EmailLinklist);
            if(EmailLinklist!=null){
                system.debug('emaillinklist2'+ EmailLinklist);
                Database.Delete(EmailLinklist);
                system.debug('emaillinklist3'+ EmailLinklist);
            }
            
        }
        catch(Exception e){
            system.debug('An error occured during delete operation'+ e.getmessage());
            
        }
        
        
    }
    
    
    Public void  finish(Database.BatchableContext BC){
        
    }
    
    
}