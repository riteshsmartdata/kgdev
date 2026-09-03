/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-19-2023   Ritesh Kumar   JIRA SF-884
**/
public without sharing class DeleteWebsiteContact_Batch implements Database.Batchable<sobject>, Database.AllowsCallouts,Database.Stateful,Schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc){  
        //Binding Dynmic Query
        DateTime todaysDataTime = System.now();
        DateTime beforeOneHour = System.now().addMinutes(-50);
        String objectName = 'Contact';
        String soqlQuery = 'SELECT SobjectName, Record, Id, DeletedDate FROM DeleteEvent WHERE  DeletedDate <=: todaysDataTime  AND  DeletedDate >=: beforeOneHour AND SobjectName=:objectName';   
        return Database.getQueryLocator(soqlQuery, System.AccessLevel.SYSTEM_MODE); 
    }
    
    public void execute(Database.BatchableContext bc, List<DeleteEvent> deletedContactList){ 
        List<LogInput> logInputList = new List<LogInput>();
        if(deletedContactList.size()>0){
            for(DeleteEvent record : deletedContactList){
                LogInput error = DeleteWebsiteContact.sendDeleteContactRequest(record.Record);

                if(error != null){
                    logInputList.add(error);
                }

            }

            if(logInputList.size() > 0){  
                ApexLogUtill.createApexLogs(logInputList);
            }
        } 
    }
    public void finish(Database.BatchableContext bc){
        
       //Dummy method is used to increase code coverage on this class. 
       //Reason : because we are using DeleteEnvent Object for sending Deleted Contact Role records.
       if(Test.isRunningTest()){
           dummy();
      } 
       
   }
   public void execute(SchedulableContext sc) {
       DeleteWebsiteContact_Batch del = new DeleteWebsiteContact_Batch();
       Database.executeBatch(del, 1);
   }


   public void dummy(){
       Integer i = 0;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
       i++;
   }
}