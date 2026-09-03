/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 08-03-2023
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   07-31-2023   Ritesh Kumar   JIRA-TICKET - SF-754
**/
public with sharing class ContactRoleHandler {
    static final String PO_CONTACT = 'ACC PO CONTACT';
    static final String ORDER_CONTACT = 'ACC ORDER ACKNOWLEDGEMENT';
    static final String SHIPPING_CONTACT = 'ACC SHIPPING CONTACT';
    public static void handelRole(List<Contact> contactList){ 
        Filter data = new Filter();
        List<Contact_Roles__c> roleInsert = new List<Contact_Roles__c>();
        Map<String,Id> deletContactRoleMap = new Map<String,Id>();
        Map<String, Contact_Roles__c> roleMap = new Map<String, Contact_Roles__c>(); 
        if(contactList.size() > 0){
            roleMap = getContactRole(contactList);
            roleInsert.clear();
            for(Contact record : contactList){
                if(!data.recordTypeSet.contains(record.RecordTypeId)){
                    /*
                    * @description : Create Contact Roles
                    */
                    if(record.Acc_PO_Contact__c == TRUE && !(roleMap.containsKey(PO_CONTACT +':'+record.Id))){ 
                        roleInsert.add(createRole(record,PO_CONTACT));
                    }
                    if(record.Acc_Order_Acknowledgement__c == TRUE && !(roleMap.containsKey(ORDER_CONTACT +':'+record.Id))){
                        roleInsert.add(createRole(record,ORDER_CONTACT));
                    }
                    if(record.Acc_Shipping_Contact__c == TRUE && !(roleMap.containsKey(SHIPPING_CONTACT +':'+record.Id))){
                        roleInsert.add(createRole(record,SHIPPING_CONTACT));
                    }
                    /*
                    * @description : Delete Contact Roles
                    */
                    if(record.Acc_PO_Contact__c == FALSE && (roleMap.containsKey(PO_CONTACT +':'+record.Id))){
                        deletContactRoleMap.put(record.Id+PO_CONTACT,record.Id);
                    }
                    if(record.Acc_Order_Acknowledgement__c == FALSE && (roleMap.containsKey(ORDER_CONTACT +':'+record.Id) )){ 
                        deletContactRoleMap.put(record.Id+ORDER_CONTACT,record.Id);
                    }
                    if(record.Acc_Shipping_Contact__c == FALSE && (roleMap.containsKey(SHIPPING_CONTACT +':'+record.Id) )){ 
                        deletContactRoleMap.put(record.Id+SHIPPING_CONTACT,record.Id);
                    }
                }
            } 
        }
        if(roleInsert.size()>0){ 
            Database.Insert(roleInsert);
        }
        if(deletContactRoleMap.values().size()>0){
            List<Contact_Roles__c> lstDeleteContactRoles = new List<Contact_Roles__c>();
            List<Contact_Roles__c> lstContactRoles = [SELECT Id,Contact__c,Contact_Role_Name__c FROM Contact_Roles__c WHERE Contact__c IN : deletContactRoleMap.values() LIMIT 50000];
            for(Contact_Roles__c cr : lstContactRoles){
                if(deletContactRoleMap.containsKey(cr.Contact__c+cr.Contact_Role_Name__c)){
                    lstDeleteContactRoles.add(cr);
                }
            }
            Database.Delete(lstDeleteContactRoles);
        }
    }
    private static Filter getRecordId(List<Contact> contactList){
        Filter data = new Filter();
        if(contactList.size() > 0){
            for(Contact record : contactList){
                if(String.isNotBlank(record.Id)){
                    data.contactIdSet.add(record.Id);
                } 
                
                if(String.isNotBlank(record.AccountId)){
                    data.accountIdSet.add(record.AccountId);
                }
            }
        }
        return data; 
    }
    private static Map<String, Contact_Roles__c> getContactRole(List<Contact> contactList){
        Map<String, Contact_Roles__c> contactRoleMap = new Map<String, Contact_Roles__c>();
        Filter sqlFilter = getRecordId(contactList);
        Contact_Roles__c [] contactRoleList = [
            SELECT Id, Contact_Role_Name__c, Account__c, Contact__c, Email__c 
            FROM Contact_Roles__c 
            WHERE Contact__c IN :sqlFilter.contactIdSet AND 
            (
                Contact_Role_Name__c = 'ACC PO CONTACT' OR 
                Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT' OR 
                Contact_Role_Name__c = 'ACC SHIPPING CONTACT'
            )
            LIMIT 50000
        ];
        if(contactRoleList.size() > 0){
            for(Contact_Roles__c role : contactRoleList){
                String mapKey = role.Contact_Role_Name__c +':'+role.Contact__c;
                contactRoleMap.put(mapKey ,role);
            }
        }
        return contactRoleMap;
    }
    private static Contact_Roles__c createRole(Contact record, String roleName){
        Contact_Roles__c role = new Contact_Roles__c();
        role.Contact_Role_Name__c = roleName;
        role.Account__c = record.AccountId;
        role.Contact__c = record.Id;
        role.Contact_Status__c = 'ACTIVE';
        role.Email__c = record.Email; 
        return role; 
    }
    class Filter{
        Set<Id> contactIdSet;
        Set<Id> accountIdSet;
        Set<Id> recordTypeSet;
        public Filter(){
            contactIdSet = new  Set<Id>();
            accountIdSet = new  Set<Id>();
            recordTypeSet = new Set<Id>();
            recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IB Contact').getRecordTypeId());
            recordTypeSet.add(Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId());
        }
    }
}