/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 03-13-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public with sharing class CommunicationServices {

	private static final List<String> ROLES_NAME = new List<String>{'ACC PO CONTACT','ACC ORDER ACKNOWLEDGEMENT','ACC SHIPPING CONTACT'};
	private static final String STATUS_ACTIVE = 'Active';
    public static Boolean FIRST_RUN = TRUE;
	
	public Map <String, String> communicationEmails = new Map<String, String>();

	public CommunicationServices(List<Id> accountIds) {

		Map<Id,Contact_Roles__c> contactRoles = getContactRoles(accountIds);
		if(contactRoles.size() > 0){
			this.communicationEmails = groupRolesWithRoleNames(contactRoles);
		}
	}

	public Map<String, String> getCommunicationEmails(){
		return communicationEmails;
	}

	public Map<Id,Contact_Roles__c> getContactRoles(List<Id> accountIds){

		Map<Id,Contact_Roles__c> contactRoleMap = new Map<Id,Contact_Roles__c>();

		contactRoleMap = new Map<Id,Contact_Roles__c>([
			SELECT 
				Account__c, Contact__c, Email__c, Contact_Role_Name__c, Contact_Status__c , Contact__r.Contact_Status__c
  			FROM 
				Contact_Roles__c
			WHERE 
				Account__c IN :accountIds AND
				Contact_Role_Name__c IN :ROLES_NAME AND 
				Contact__r.Contact_Status__c =: STATUS_ACTIVE
  			ORDER BY 
				CreatedDate 
			DESC
		]); 
		return contactRoleMap; 
	}

	public Map<String,String> groupRolesWithRoleNames(Map<Id,Contact_Roles__c> contactRoles){
		Map<String,String> groupRolesWithRoleNames = new Map<String,String>();
		for(Contact_Roles__c contactRole  : contactRoles.values()){
			String key = contactRole.Account__c + '-' + contactRole.Contact_Role_Name__c;
			if(groupRolesWithRoleNames.containsKey(key)){
				groupRolesWithRoleNames.put(key,groupRolesWithRoleNames.get(key) +','+ contactRole.Email__c);
			}else{
				groupRolesWithRoleNames.put(key,contactRole.Email__c);
			}
			//System.debug('####### groupRolesWithRoleNames: '+groupRolesWithRoleNames);
		}
		return groupRolesWithRoleNames;
	}

}