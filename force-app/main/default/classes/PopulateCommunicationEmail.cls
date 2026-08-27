/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 03-11-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public with sharing class PopulateCommunicationEmail extends TriggerHandler {

	//Variable to hold string values
    private static final List<String> ROLES_NAME = new List<String>{'ACC PO CONTACT','ACC ORDER ACKNOWLEDGEMENT','ACC SHIPPING CONTACT'};
    private static final String EMAIL = 'Email';
    private static final String BOTH = 'Both';
    private static final String STATUS_ACTIVE = 'Active';
	private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EBS_Order');
	private List<EBS_Order__c> newRecords;
	private Map<Id,EBS_Order__c> oldRecords;
    
    // Variable to hold email type.
    public enum EmailType{
        PO_CONTACT,
		ORDER_ACKNOWLEDGEMENT,
		SHIPPING_CONTACT 
	}

	public PopulateCommunicationEmail(String className){
		this.newRecords = (List<EBS_Order__c>) Trigger.new;
		this.oldRecords = (Map<Id,EBS_Order__c>) Trigger.oldMap; 
	}

	public override void beforeUpdate() { 

		// Autofill the Order Confirmation and Shipping Notification email when PO COntact is present and both the fields are blank.
		assigneEmails(newRecords);

        // Tag Existing Contact
		OrderContact tagContact = new OrderContact();
		tagContact.tagExistingContact(newRecords, oldRecords);

		// Populate Acc Email fileds 
		tagEmailOnOrder();

	}

	public override void beforeInsert() { 
		// Autofill the Order Confirmation and Shipping Notification email when PO COntact is present and both the fields are blank.
		assigneEmails(newRecords);

		// Tag Existing Contact
		OrderContact tagContact = new OrderContact();
		tagContact.tagExistingContact(newRecords, oldRecords);

		// Populate Acc Email fileds 
		tagEmailOnOrder();

	}

	public void tagEmailOnOrder(){
        
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        
		//System.debug(LoggingLevel.INFO,'===== START tagEmailOnOrder ====='); 
		List<Id> accountIds = new List<Id>(); 
		for(EBS_Order__c record : newRecords){	
			if(String.isNotBlank(record.Account_Name__c)){ 
				accountIds.Add(record.Account_Name__c);
			}
		}

		CommunicationServices emailWithRoles = new CommunicationServices(accountIds);
		//System.debug(LoggingLevel.INFO, 'Contact Role Map Data : '+emailWithRoles.communicationEmails);

		for(EBS_Order__c record : newRecords){
			//System.debug(LoggingLevel.INFO,'===== EBS_Order__c - record:' + record);
			if(String.isNotBlank(record.Account_Name__c)){ 

				// Populact Acc PO Email 
                if(!String.isNotBlank(record.PO_Contact_Email__c)){
                    record.Acc_PO_Contact_To_Email__c = '';
                }else{
					record.Acc_PO_Contact_To_Email__c = record.PO_Contact_Email__c;
                }
                
                String accPoEmail = record.Account_Name__c+ '-'+ROLES_NAME[0];
                if(emailWithRoles.communicationEmails.containsKey(accPoEmail)){
                    record.Acc_PO_Contact_To_Email__c = checkEmail(record.PO_Contact_Email__c, emailWithRoles.communicationEmails.get(accPoEmail)); 
                }
                
				
				// Populact Acc Order Email
				if(!String.isNotBlank(record.Order_Confirmation_Email__c)){
					record.Order_Confirmation_Email__c = record.PO_Contact_Email__c;
				}else{
					record.Acc_Order_Confirm_Contact_To_Email__c = record.Order_Confirmation_Email__c;
                }

				String accOrderEmail = record.Account_Name__c+ '-'+ROLES_NAME[1];
				if(emailWithRoles.communicationEmails.containsKey(accOrderEmail)){
					record.Acc_Order_Confirm_Contact_To_Email__c = checkEmail(record.Order_Confirmation_Email__c, emailWithRoles.communicationEmails.get(accOrderEmail));
				}

				// Populact Acc   Shipping Email
				if(!String.isNotBlank(record.Shipping_Notification_Email__c)){
					record.Shipping_Notification_Email__c = record.PO_Contact_Email__c;
				}else{
					record.Acc_Shipping_Notif_Contact_To_Email__c = record.Shipping_Notification_Email__c;
                }

				String accShippingEmail = record.Account_Name__c+ '-'+ROLES_NAME[2];
				if(emailWithRoles.communicationEmails.containsKey(accShippingEmail)){
					record.Acc_Shipping_Notif_Contact_To_Email__c = checkEmail(record.Shipping_Notification_Email__c, emailWithRoles.communicationEmails.get(accShippingEmail)); 
				}

				//System.debug(LoggingLevel.INFO,'===== Acc_PO_Contact_To_Email ====='+record.Acc_PO_Contact_To_Email__c);
				//System.debug(LoggingLevel.INFO,'===== Acc_Order_Confirm_Contact_To_Email ====='+record.Acc_Order_Confirm_Contact_To_Email__c);
				//System.debug(LoggingLevel.INFO,'===== Acc_Shipping_Notif_Contact_To_Email__c ====='+record.Acc_Shipping_Notif_Contact_To_Email__c);
				 
			} 
		}
		//System.debug(LoggingLevel.INFO,'===== END tagEmailOnOrder ====='); 
	}

	private String checkEmail(String email, String currentEmails){

		String tempEmail = '';
		
			if(String.isNotBlank(currentEmails) && String.isNotBlank(email)){
				tempEmail = currentEmails.contains(email) ? currentEmails : currentEmails + ',' + email;
			}else{
				tempEmail = email;
			}

			return tempEmail; 
	}

	private void assigneEmails(List<EBS_Order__c> newRecords){
		System.debug(LoggingLevel.DEBUG, '**** Assigne Emails ****');
		for(EBS_Order__c record : newRecords){
			if(String.isNotBlank(record.PO_Contact_Email__c)){
				if(String.isBlank(record.Order_Confirmation_Email__c)){
					record.Order_Confirmation_Email__c = record.PO_Contact_Email__c;
				}

				if(String.isBlank(record.Shipping_Notification_Email__c)){
					record.Shipping_Notification_Email__c = record.PO_Contact_Email__c;
				}
			}
		}
	}
	
}