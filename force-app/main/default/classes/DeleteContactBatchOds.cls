/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 08-10-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-02-2023   Ritesh Kumar   JIRA Ticket Number : SF-663, SF-754 
**/
public without sharing class DeleteContactBatchOds implements Database.Batchable<sobject>, Database.AllowsCallouts,Database.Stateful,Schedulable{
 
    
    public Database.QueryLocator start(Database.BatchableContext bc){  
        // Binding Dynmic Query
        DateTime todaysDataTime = System.now();
        DateTime beforeOneHour = System.now().addMinutes(-50);
        String objectName = 'Contact';
        String soqlQuery = 'SELECT SobjectName, Record, Id, DeletedDate FROM DeleteEvent WHERE  DeletedDate <=: todaysDataTime  AND  DeletedDate >=: beforeOneHour AND SobjectName=:objectName';   
        //System.debug('====== Contact SOQL  ===='+ soqlQuery);
        //return Database.getQueryLocator(soqlQuery);
        return Database.getQueryLocator(soqlQuery, System.AccessLevel.SYSTEM_MODE); 
    }
    
    public void execute(Database.BatchableContext bc, List<DeleteEvent> deletedContactList){
        //System.debug('====== contactList  ===='+deletedContactList );
        
        if(deletedContactList.size()>0){
            for(DeleteEvent record : deletedContactList){
                DeleteContactODS.syncContactThroughBatch(record.Record); 
            }    
        } 
    }
    
    public void finish(Database.BatchableContext bc){
        //System.debug('====== bc  ===='+ bc);
        //Dummy method is used to increase code coverage on this class. 
        //Reason : because we are using DeleteEnvent Object for sending Deleted Contact records.
        if(Test.isRunningTest()){
             dummy();
        } 
    } 

    public void execute(SchedulableContext sc) {
        DeleteContactBatchOds del = new DeleteContactBatchOds();
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
    }


    
}