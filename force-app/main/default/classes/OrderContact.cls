/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 03-13-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public with sharing class OrderContact { 
	private static  final Set<String> RECORD_TYPES = new Set<String>{
		KoozieConstants.RECORD_TYPE_CRM_CONTACT,
		KoozieConstants.RECORD_TYPE_MULTI_LINE_REP
	};

	public void tagExistingContact(List<EBS_Order__c> newRecord, Map<Id, EBS_Order__c> oldRecord){
		Set<String> emailIds = new Set<String>();
		Map<String,Contact> existingContacts = new Map<String,Contact>();
		List<EBS_Order__c> orderWithMissingContacts = new List<EBS_Order__c>();

		// Get eamil Id and Stroe in variable
		emailIds = this.getEmailFromOrder(newRecord);

		//Get contact based on emailIds
		existingContacts = this.findContact(emailIds);
		
		for (EBS_Order__c record : newRecord) { 
			if( String.isNotBlank(record.PO_Contact_Email__c) && existingContacts.containsKey(record.PO_Contact_Email__c)){ 
				record.PO_Contact__c = existingContacts.get(record.PO_Contact_Email__c).Id; 
			}

			if( String.isNotBlank(record.Order_Confirmation_Email__c) && existingContacts.containsKey(record.Order_Confirmation_Email__c)){
				record.Order_Confirm_Contact__c = existingContacts.get(record.Order_Confirmation_Email__c).Id;
			}

			if (String.isNotBlank(record.Shipping_Notification_Email__c) && existingContacts.containsKey(record.Shipping_Notification_Email__c)) {
				record.Shipping_Notif_Contact__c = existingContacts.get(record.Shipping_Notification_Email__c).Id;
			} 
		} 
		 
		// Creating the missing Contact
		Map<String,Id> createdContacts = this.createMissingContact(newRecord,existingContacts);

		// tag the missing Contact
		this.recheckContact(newRecord, createdContacts); 

		// Update the Contact Status 
		if((!existingContacts.isEmpty()) && existingContacts.size() > 0){
			
			this.updateContactStatus(existingContacts);
		}
	}

	private Map<String,Id> createMissingContact( List<EBS_Order__c> newOrders,Map<String,Contact> existingContacts){
		Map<String, Contact> newContact = new Map<String, Contact>();
		Map<String,Id>contactIds = new Map<String,Id>();
		 
		System.debug('ordersWithMissingContact ======'+ newOrders);
		for(EBS_Order__c record :newOrders){
			Boolean isPoContact = String.isNotBlank(record.PO_Contact_Email__c) && (!existingContacts.containsKey(record.PO_Contact_Email__c));
			Boolean isOrderConfirmation = String.isNotBlank(record.Order_Confirmation_Email__c) && (!existingContacts.containsKey(record.Order_Confirmation_Email__c));
			Boolean isShippingNotification = String.isNotBlank(record.Shipping_Notification_Email__c) && (!existingContacts.containsKey(record.Shipping_Notification_Email__c));

			//PO Contact
			if(String.isNotBlank(record.PO_Contact_Email__c) && (!newContact.containsKey(record.PO_Contact_Email__c)) && isPoContact){
				newContact.put(record.PO_Contact_Email__c,this.createValuedCustomer(record.PO_Contact_Email__c,record.Account_Name__c ));				  
			}

			//Order Confirmation
			if(String.isNotBlank(record.Order_Confirmation_Email__c) && (!newContact.containsKey(record.Order_Confirmation_Email__c)) && isOrderConfirmation){
				newContact.put(record.Order_Confirmation_Email__c,this.createValuedCustomer(record.Order_Confirmation_Email__c,record.Account_Name__c ));
			}

			//Shipping Notification
			if (String.isNotBlank(record.Shipping_Notification_Email__c) && (!newContact.containsKey(record.Shipping_Notification_Email__c)) && isShippingNotification) {
				newContact.put(record.Shipping_Notification_Email__c,this.createValuedCustomer(record.Shipping_Notification_Email__c,record.Account_Name__c));
			} 
		}

		
		System.debug('newContact ======'+newContact);
		//Insert Contact  
		if(newContact.values().size() > 0){
			List<Contact> tempContact = new List<Contact>();
			tempContact.addAll(newContact.values()); 
			System.debug('tempContact ======'+ tempContact);
			Insert tempContact;
			for (Contact record : tempContact) {
				contactIds.put(record.Email,Record.Id);
			}
		} 

		return contactIds;
	}

	private void recheckContact(List<EBS_Order__c> newRecords, Map<String,Id> createdContacts){
		for (EBS_Order__c record : newRecords) { 
			if(String.isNotBlank(record.PO_Contact_Email__c) && createdContacts.containsKey(record.PO_Contact_Email__c)){ 
				record.PO_Contact__c = createdContacts.get(record.PO_Contact_Email__c); 
			}

			if(String.isNotBlank(record.Order_Confirmation_Email__c) && createdContacts.containsKey(record.Order_Confirmation_Email__c)){
				record.Order_Confirm_Contact__c = createdContacts.get(record.Order_Confirmation_Email__c);
			}

			if ( String.isNotBlank(record.Shipping_Notification_Email__c) && createdContacts.containsKey(record.Shipping_Notification_Email__c)) {
				record.Shipping_Notif_Contact__c = createdContacts.get(record.Shipping_Notification_Email__c);
			}

		}
	}

	private void updateContactStatus(Map<String,Contact> existingContacts){
		List< Contact> oldContact = new List< Contact>();
		for (Contact record : existingContacts.values()) {
			if(record.Contact_Status__c == KoozieConstants.CONTACT_INACTIVE_STATUS){
				oldContact.add(new Contact(Id =record.Id, Contact_Status__c = KoozieConstants.CONTACT_ACTIVE_STATUS));
			} 
		}
		
		//Update Contact  
		if(oldContact.size() > 0){ 
			Update oldContact; 
		} 
	}

	private Set<String> getEmailFromOrder(List<EBS_Order__c> orders){
		Set<String> emailIds = new Set<String>();
		for (EBS_Order__c record : orders) {
			if(String.isNotBlank(record.PO_Contact_Email__c)){
				emailIds.add(record.PO_Contact_Email__c);
			}

			if(String.isNotBlank(record.Order_Confirmation_Email__c)){
				emailIds.add(record.Order_Confirmation_Email__c);
			}

			if(String.isNotBlank(record.Shipping_Notification_Email__c)) {
				emailIds.add(record.Shipping_Notification_Email__c);
			}
		}

		return emailIds; 
	}

	private Map<String,Contact> findContact(Set<String> emailIds){ 
		Map<String,Contact> records = new Map<String,Contact>(); 
		for(Contact record : [
			SELECT Id, Email, Contact_Status__c FROM Contact WHERE Email IN : emailIds AND RecordTypeId IN: RECORD_TYPES  ORDER BY RecordType.Name ASC, CreatedDate DESC  LIMIT 50000
		]){
			if(! records.containsKey(record.email)){
				records.put(record.Email,record);
			}
		}
		return records;
	}

	private Contact createValuedCustomer(String email, String accountId){
		Contact record = new Contact ();
		record.FirstName = KoozieConstants.CONTACT_FIRST_NAME_VALUED;
		record.LastName = KoozieConstants.CONTACT_LAST_NAME_CUSTOMER;
		record.RecordTypeId = KoozieConstants.RECORD_TYPE_CRM_CONTACT;
		record.Email = email;
		record.AccountId = accountId;
		return record;
	}

}