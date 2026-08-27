/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ritesh Kumar
**/
global with sharing class SendContactRoleInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String contactRoleSOQL =  'SELECT Id, OwnerId, IsDeleted, Name, CreatedDate,Primary__c, CreatedById, LastModifiedDate, LastModifiedById, Account__c, Contact__c, Customer_Account_Number__c, Contact_Role_Name__c FROM Contact_Roles__c';
        //contactRoleSOQL += ' LIMIT 10';
        return Database.getQueryLocator(contactRoleSOQL);
    } 

    global void execute(Database.BatchableContext BC, List<Contact_Roles__c> contactRolelist){
        if(contactRolelist.size() > 0){
            for(Contact_Roles__c data : contactRolelist){
                GenerateContactRoleJSONData.sendContactRoleData(GenerateContactRoleJSONData.insertManyContactRoleJSON(data), 'INSERT');
            }
        }
    }


    global void finish(Database.BatchableContext BC){
        
    }     
}