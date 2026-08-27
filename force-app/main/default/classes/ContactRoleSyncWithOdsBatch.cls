/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 08-31-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-31-2023   Ritesh Kumar   JIRA SF-986
**/
public class ContactRoleSyncWithOdsBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful,Schedulable{

    public Database.QueryLocator start(Database.BatchableContext BC){

        DateTime todaysDataTime = System.now();
        DateTime beforeOneHour = System.now().addMinutes(-40); 
        String contactSOQL = '';
         
        contactSOQL += 'SELECT Id, Name, Account__c, CreatedById, Primary__c, LastModifiedById, Contact_Role_Name__c, LastModifiedDate, Customer_Account_Number__c, Contact__c, CreatedDate FROM Contact_Roles__c';
        contactSOQL += ' WHERE LastModifiedDate <=: todaysDataTime AND LastModifiedDate >=: beforeOneHour';
          
        return Database.getQueryLocator(contactSOQL);
    }

    public void execute(Database.BatchableContext BC, List<Contact_Roles__c> contactRoleList){

        /**
         * List hold the apex error log.
         */
        List<Apex_Errors__c> errorsList = new List<Apex_Errors__c>();

        /**
         * Get API key and End point from custom metadata
         */ 
       // Contact_And_Contact_Role_Settings__mdt apiSetting = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');
		Contact_And_Contact_Role_Settings__mdt apiSetting = Contact_And_Contact_Role_Settings__mdt.getInstance(KoozieUtility.isSandbox() ? 'Send_Contact_Role_Information_Full_Copy' : 'Send_Contact_Role_Information');

        if(!contactRoleList.isEmpty()){
            for(Contact_Roles__c record : contactRoleList){
                Apex_Errors__c temp = new Apex_Errors__c();
                temp = ContactRoleODSJson.syncContactRoleODS(record, apiSetting); 
                if(temp!= null ){
                    errorsList.add(temp);
                }
            }
            
            /**
             * Insert apex error if any
             */
            if(! errorsList.isEmpty()){
                Database.insert(errorsList, false);
            }
           
        }  
    }
    
    public void finish(Database.BatchableContext BC){  
    }

     

    public void execute(SchedulableContext sc) {
        ContactRoleSyncWithOdsBatch bth = new ContactRoleSyncWithOdsBatch();
        Database.executeBatch(bth, 1);
    }
   
}