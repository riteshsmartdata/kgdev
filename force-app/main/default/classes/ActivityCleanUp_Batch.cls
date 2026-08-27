/*
* @description       :  Batch class for cleaning old activities which are created by Integration Service users or the users which are deactivated
* @author            :  Kumar Saurav / Anubhav Saxena
* @group             :  DAMCO
* @created on        :  11/03/2024
* @last modified on  :
* @last modified by  : 
*/
public with sharing class ActivityCleanUp_Batch implements Database.Batchable<SObject>,Database.stateful,Schedulable{
    /*
    *	@description : Class variables
    */
    private static final Datetime LAST_60_DAYS = Date.today().addDays(-60);
    private static final String ACTIVITY_TYPE_EMAIL = 'E-mail';
    private static final String SUBJECT = '%' + 'Failed'+ '%';
    private static List<Id> successfullyDeletedActivityIds = new List<Id>();
    /*
    *	@description : Schedule the batch class, 
    *   Cron Experssion : 
    */
    public static void execute(SchedulableContext sc){
        Database.executeBatch(new ActivityCleanUp_Batch(),10);
    } 
    /*
    *	@description : Get all the old Actvities in the start method.
    *   @paramerters : accepts BatchableContext as parameter
    */
    public static Database.QueryLocator start(Database.BatchableContext bc){
        String oldActivityQuery = 'SELECT Id FROM Task ';
        oldActivityQuery = addFilter(oldActivityQuery);
        return Database.getQueryLocator(oldActivityQuery); 
    }
    /*
    *	@description : Delete all the old Activities in each batch.
    *   @paramerters : accepts BatchableContext as parameter, Activity list returned from start
    */
    public static void execute(Database.BatchableContext bc,List<Task> activityScope){
        List<Task> deleteOldActivityList = new List<Task>();
        for(Task activityRecords : activityScope){
            deleteOldActivityList.add(activityRecords);
        }
        Database.DeleteResult[] deleteActivityStatusList = Database.delete(deleteOldActivityList,false);
        if(!deleteActivityStatusList.isEmpty()){
            for(Database.DeleteResult dr : deleteActivityStatusList){
                if(dr.isSuccess()){
                    successfullyDeletedActivityIds.add(dr.getId());
                }
            }    
        }else {
            return;
        }
    }
    /*
    *	@description : Opeartions which needs to be perfromed when the batch has finished executing
    *   @paramerters : accepts BatchableContext as parameter
    */
    public static void finish(Database.BatchableContext bc){
        System.debug('Activity Clean up batch has finished executing');
    }
    /*
    *	@description : Apply filters in the start method of the Query to give only Activities which are created by the sales profile users
    *   @paramerters : accecpts query without where condition, last activity created days
    */
    private static String addFilter(String query){
        if(String.isNotBlank(query)){
            query += 'WHERE Subject LIKE :SUBJECT AND Activity_Type__c != :ACTIVITY_TYPE_EMAIL AND CreatedDate <:LAST_60_DAYS';
        }
        return query;
    } 
}