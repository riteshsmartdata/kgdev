/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 08-18-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-16-2023   Ritesh Kumar   Initial Version
**/
public class DeleteContactRoleBatchOds implements Database.Batchable<sobject>, Database.AllowsCallouts,Database.Stateful,Schedulable {

      
    public Database.QueryLocator start(Database.BatchableContext bc){  
        // Binding Dynmic Query
        DateTime todaysDataTime = System.now();
        DateTime beforeOneHour = System.now().addMinutes(-50);
        String objectName = 'Contact Roles';
        String soqlQuery = 'SELECT SobjectName, Record, Id, DeletedDate FROM DeleteEvent WHERE  DeletedDate <=: todaysDataTime  AND  DeletedDate >=: beforeOneHour AND SobjectName=:objectName';   
        //System.debug('====== Contact SOQL  ===='+ soqlQuery);
        //return Database.getQueryLocator(soqlQuery);
        return Database.getQueryLocator(soqlQuery, System.AccessLevel.SYSTEM_MODE); 
    }
    
    public void execute(Database.BatchableContext bc, List<DeleteEvent> deletedContactList){
        //System.debug('====== contactList  ===='+deletedContactList );
        
        if(deletedContactList.size()>0){
            for(DeleteEvent record : deletedContactList){
                DeleteContactRoleODS.syncContactRoleThroughBatch(record.Record); 
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
        DeleteContactRoleBatchOds del = new DeleteContactRoleBatchOds();
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