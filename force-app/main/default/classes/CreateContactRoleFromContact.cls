/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 12-28-2022
 * @last modified by  : Mohammad Arafat Ali
**/
public without sharing class CreateContactRoleFromContact {

    public static void CreateContactRole(List<Contact> conlist) {
        Set<Id> accId = new Set<Id>();
        Set<Id> conId = new Set<Id>();
        List<Contact> contList = new List<Contact>();
        Set<Contact_Roles__c> insertContactRoleList = new Set<Contact_Roles__c>();
        Map<String,Contact_Roles__c> mapOfContactRoleNameVsContactRole = new Map<String,Contact_Roles__c>();
        String recordTypeIB = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IB Contact').getRecordTypeId();
        String recordTypeFinance = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId();

        for(Contact con :conlist){
            if(con.AccountId != null){
                accId.add(con.AccountId);
                conId.add(con.Id);
                //System.debug('======= Account Id ===== ' +accId);
                //System.debug('======= Contact Id ===== ' +conId);

        contList = [Select Id, Name, AccountId, Acc_PO_Contact__c, Acc_Order_Acknowledgement__c, Acc_Shipping_Contact__c, Email FROM Contact 
        WHERE AccountId IN :accId AND Id IN :conId AND RecordTypeId != :recordTypeIB AND RecordTypeId != :recordTypeFinance];
        //System.debug('===== Contact List Size ======= ' + contList.size());

        for(Contact_Roles__c cr :[Select Id, Contact_Role_Name__c, Account__c, Contact__c, Email__c FROM Contact_Roles__c 
        WHERE Contact__c IN :conId AND (Contact_Role_Name__c = 'ACC PO CONTACT' OR Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT'
        OR Contact_Role_Name__c = 'ACC SHIPPING CONTACT')]){
            //System.debug('======= Contact Role Name ======= '+cr.Contact_Role_Name__c);
            mapOfContactRoleNameVsContactRole.put(cr.Contact_Role_Name__c,cr);
        }
        
        for(Contact cont : contList){
            //System.debug('====== Entered Loop ==========');
            if(cont.Acc_PO_Contact__c == true && (!mapOfContactRoleNameVsContactRole.containsKey('ACC PO CONTACT'))){
                Contact_Roles__c cr = new Contact_Roles__c();
                cr.Contact_Role_Name__c = 'ACC PO CONTACT';
                cr.Account__c = cont.AccountId;
                cr.Contact__c = cont.Id;
                cr.Contact_Status__c = 'ACTIVE';
                cr.Email__c = cont.Email;
                insertContactRoleList.add(cr);
                //System.debug('====== Contact Role ====== ' +insertContactRoleList);
            }

            if(cont.Acc_Order_Acknowledgement__c == true && (!mapOfContactRoleNameVsContactRole.containsKey('ACC ORDER ACKNOWLEDGEMENT'))){
                Contact_Roles__c cr = new Contact_Roles__c();
                cr.Contact_Role_Name__c = 'ACC ORDER ACKNOWLEDGEMENT';
                cr.Account__c = cont.AccountId;
                cr.Contact__c = cont.Id;
                cr.Contact_Status__c = 'ACTIVE';
                cr.Email__c = cont.Email;
                insertContactRoleList.add(cr);
                //System.debug('====== Contact Role ====== ' +insertContactRoleList);
            }

            if(cont.Acc_Shipping_Contact__c == true && (!mapOfContactRoleNameVsContactRole.containsKey('ACC SHIPPING CONTACT'))){
                Contact_Roles__c cr = new Contact_Roles__c();
                cr.Contact_Role_Name__c = 'ACC SHIPPING CONTACT';
                cr.Account__c = cont.AccountId;
                cr.Contact__c = cont.Id;
                cr.Contact_Status__c = 'ACTIVE';
                cr.Email__c = cont.Email;
                insertContactRoleList.add(cr);
                //System.debug('====== Contact Role ====== ' +insertContactRoleList);
            }  
        }
                if(!insertContactRoleList.isEmpty()){
                    List<Contact_Roles__c> tempList = new List<Contact_Roles__c>();
                    tempList.addAll(insertContactRoleList);
                    //System.debug('===== Temp Contact Role ====== '+tempList);
                    insert tempList;
                }
            }
        }
    }
}