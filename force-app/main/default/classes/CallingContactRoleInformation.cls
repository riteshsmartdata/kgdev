/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ritesh Kumar
**/
global without sharing class CallingContactRoleInformation {
    @InvocableMethod(label='Send Contact Role Information' description='Send contact role information to third party system.' category='Contact Role')
    global static void sendContactRoleInformation(List<ContactRoleRequest> ContactRoleRequestList){ 
        System.debug('======= sendContactRoleInformation ====== ');
        System.debug('======= ContactRoleRequestList ====== '+ContactRoleRequestList);
        
        for( ContactRoleRequest contactRoleDataWrapper : ContactRoleRequestList){ 

            if(contactRoleDataWrapper.oldContactRole != null && contactRoleDataWrapper.newContactRole != null){
                //Update Operaation
                System.debug('======= Old Contact Role ====== '+contactRoleDataWrapper.oldContactRole);
                Set<String> fieldDifference = new Set<String>();
                fieldDifference = getFieldDifference(contactRoleDataWrapper.newContactRole, contactRoleDataWrapper.oldContactRole);               
                GenerateContactRoleJSONData.sendContactRoleInformation( GenerateContactRoleJSONData.UpdateoneContactRoleJSON(contactRoleDataWrapper.newContactRole, fieldDifference),'UPDATE');
    
            }else{
                //Insert operation 
                System.debug('======= New Contact Role ====== '+contactRoleDataWrapper.newContactRole);
                if(contactRoleDataWrapper.newContactRole != null){    
                   GenerateContactRoleJSONData.sendContactRoleInformation( GenerateContactRoleJSONData.insertManyContactRoleJSON(contactRoleDataWrapper.newContactRole),'INSERT');
                }
            } 
        }
        System.debug('@@@@@@@@@@ sendContactRoleInformation @@@@@@@@@@');
        
    } 

    public static Set<String> getFieldDifference(Contact_Roles__c newContactRole, Contact_Roles__c oldContactRole){

        Set<String> fieldDifferenc = new Set<String>();
        if(newContactRole.Account__c != oldContactRole.Account__c ){
            fieldDifferenc.add('Account__c');
        } 

        if(newContactRole.CreatedById != oldContactRole.CreatedById ){
            fieldDifferenc.add('CreatedById');
        }

        if(newContactRole.Primary__c != oldContactRole.Primary__c ){
            fieldDifferenc.add('Primary__c');
        }

        if(newContactRole.LastModifiedById != oldContactRole.LastModifiedById ){
            fieldDifferenc.add('LastModifiedById');
        }

        if(newContactRole.Contact_Role_Name__c != oldContactRole.Contact_Role_Name__c ){
            fieldDifferenc.add('Contact_Role_Name__c');
        }

        if(newContactRole.LastModifiedDate != oldContactRole.LastModifiedDate ){
            fieldDifferenc.add('LastModifiedDate');
        }

        if(newContactRole.Customer_Account_Number__c != oldContactRole.Customer_Account_Number__c ){
            fieldDifferenc.add('Customer_Account_Number__c');
        }

        if(newContactRole.LastModifiedDate != oldContactRole.LastModifiedDate ){
            fieldDifferenc.add('LastModifiedDate');
        } 
        
        return fieldDifferenc;
    }


    global class ContactRoleRequest {

        @InvocableVariable(required=true description='New Contact Role List' label='new Contact role')
        public Contact_Roles__c newContactRole;

        @InvocableVariable(required=false description='Old Contact Role List' label='old contact role')
        public Contact_Roles__c oldContactRole; 
        
        public ContactRoleRequest(){
            oldContactRole = new Contact_Roles__c();
            newContactRole = new Contact_Roles__c();
        }

    }
}