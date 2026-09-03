/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 11-04-2025
* @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
* Ver   Date         Author         Modification
* 1.0   10-19-2023   Ritesh Kumar   
* 1.1   10-19-2023   Ritesh Kumar   JIRA SF-469 Code Line 
**/
@RestResource(urlMapping='/UpdateContact/*')
global class UpdateContact {
    
    @HttpPost
    global static void getContactRequest(){
        String recordID = '';
        UpdateContactRequest records = new UpdateContactRequest();
        Set<Contact> tempContact = new Set<Contact>();
        RestResponse response = RestContext.response;
        RestRequest request = RestContext.Request; 
        String Requestpayload = request.Requestbody.toString();
        String eventType = 'DML'; 
        Map<String,Callout_Handler_Setting__mdt> calloutSettingMap = new Map<String,Callout_Handler_Setting__mdt>() ; 
        
        for(Callout_Handler_Setting__mdt calloutSetting : [SELECT API_Method_Name__c,Is_Active__c FROM Callout_Handler_Setting__mdt]){
            calloutSettingMap.put(calloutSetting.API_Method_Name__c,calloutSetting); 
        }
        if(calloutSettingMap.containsKey('getContactRequest') && calloutSettingMap.get('getContactRequest').Is_Active__c){
            if(Requestpayload != '{}' && Requestpayload != null && Requestpayload!= ''){
                records =  UpdateContactRequest.parse(Requestpayload); 
            } 
        }
        
        //System.debug('===== UpdateContact records ======'+records);
        response.addHeader('Content-Type', 'application/json');  
        if(records != null && records.EventRequest != null ){
            try{
                Contact contactRecord = new Contact(); 
				String contactId  = tagContact(records.EventRequest.CustomerData.sf_Id,records.EventRequest.CustomerData.accountNumber,records.EventRequest.CustomerData.emailId);
				contactRecord.Id = contactId != '' ? contactId: null;
                                
                if(String.isBlank(contactRecord.Id)){
                    contactRecord.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
                }
                
                contactRecord.LastName = records.EventRequest.CustomerData.LastName;
                contactRecord.FirstName = records.EventRequest.CustomerData.FirstName ;
                contactRecord.User_Name__c = records.EventRequest.CustomerData.userName; 
                contactRecord.Email = records.EventRequest.CustomerData.emailId ;
                contactRecord.Web_Id__c = records.EventRequest.CustomerData.web_Id ;     
                contactRecord.Phone = records.EventRequest.CustomerData.primaryPhone;
                contactRecord.Contact_Type__c = records.EventRequest.CustomerData.contactType;
                contactRecord.User_Name__c = records.EventRequest.CustomerData.userName;
                contactRecord.MobilePhone = records.EventRequest.CustomerData.Mobile; 
                contactRecord.Industry_Type__c = records.EventRequest.CustomerData.industryType;

                if(records.EventRequest.CustomerData.lastLoginDate != null){
                    contactRecord.Last_Login_Date__c = records.EventRequest.CustomerData.lastLoginDate;
                }

                contactRecord.Contact_Status__c = records.EventRequest.CustomerData.contactActiveStatus == TRUE ? 'Active':'Inactive';
                
                if(String.isNotBlank(records.EventRequest.CustomerData.accountNumber)){
                    contactRecord.AccountId = fetchAccountIdViaAccNumber(records.EventRequest.CustomerData.accountNumber);
                }
                
                PickListValues pickListValue =  new PickListValues(); 
                pickListValue = fillPicklist(records);
                if(pickListValue != null){
                    if(String.isNotBlank(pickListValue.poConfirmation)){
                        contactRecord.PO_Confirmation__c = pickListValue.poConfirmation;
                    }
                    
                    if(String.isNotBlank(pickListValue.shipmentConfirmation)){                        
                        contactRecord.Shipment_Confirmation__c = pickListValue.shipmentConfirmation;
                    } 
                    
                    
                    if(String.isNotBlank(pickListValue.proofConfirmation)){                        
                        contactRecord.Proof_Confirmation__c = pickListValue.proofConfirmation;
                    } 
                    
                    if(String.isNotBlank(pickListValue.orderAcknowledgement)){                        
                        contactRecord.Order_Acknowledgement__c = pickListValue.orderAcknowledgement;
                    }
                    
                    if(String.isNotBlank(pickListValue.clarificationConfirmation)){                        
                        contactRecord.Clarification_Confirmation__c = pickListValue.clarificationConfirmation;
                    }
                    
                    if(String.isNotBlank(pickListValue.whenStatuschanges)){                        
                        contactRecord.When_Status_changes__c = pickListValue.whenStatuschanges;
                    } 
					
					if(String.isNotBlank(pickListValue.reorderReminders)){                        
                        contactRecord.Reorder_Reminder__c = pickListValue.reorderReminders;
                    }

          			if(String.isNotBlank(pickListValue.sampleOrderFollowsUps)){                        
                        contactRecord.Sample_Order_Reminder__c = pickListValue.sampleOrderFollowsUps;
                    }
                    
                    if(String.isNotBlank(pickListValue.specSampleOrderReminder)){                        
                        contactRecord.Spec_Sample_Order_Reminder__c = pickListValue.specSampleOrderReminder;
                    }
                }

                if( records.EventRequest.CustomerData.AccountPreferences != null){  
					UpdateContactRequest.AccountPreferences preferences =records.EventRequest.CustomerData.AccountPreferences;
					contactRecord.Acc_PO_Contact__c = preferences.Acc_poConfirmation; 
					contactRecord.Acc_Order_Acknowledgement__c = preferences.Acc_orderAcceptance;
					contactRecord.Acc_Shipping_Contact__c = preferences.Acc_shipmentConfirmation; 
					contactRecord.Acc_Proof_Confirmation__c = preferences.Acc_proofConfirmation;
					contactRecord.Acc_Clarification_Confirmation__c = preferences.Acc_clarificationConfirmation; 
                }  
                
                if(contactRecord != null){  
                    Database.UpsertResult results =  Database.Upsert(contactRecord,false);
                    recordID = results.getId();
                    if(results.isSuccess()){ 
                        response.addHeader('Content-Type', 'application/json');                
                        response.statusCode = 200;                       
                        String responseData = ContactUtill.contactResponseForm(recordID, 'SUCCESS',eventType).getAsString();                         
                        response.responseBody =  Blob.valueOf(responseData);

                    }else{ 
                        response.addHeader('Content-Type', 'text/plain');
                        response.statusCode = 400;
                        response.responseBody =  Blob.valueOf(JSON.serialize(results.getErrors()));
                        ApexLogUtill.createApexLog('Website', Requestpayload, response.responseBody.toString(), recordID, 'Contact', JSON.serialize(results.getErrors()), response.statusCode);
                   }                      
                }
                
            }catch (DmlException crudException ){
                response.addHeader('Content-Type', 'text/plain');
                response.statusCode = 400;
                response.responseBody =  Blob.valueOf(JSON.serialize(crudException.getMessage()));
                ApexLogUtill.createApexLog('Website', Requestpayload, response.responseBody.toString(), recordID, 'Contact', crudException.getMessage(), response.statusCode);
            }
        }
    }

    @TestVisible
    private static id fetchAccountIdViaAccNumber(String accountNumber){
        return [SELECT Id, Name FROM Account WHERE Customer_Account_Number__c =:accountNumber LIMIT 1]?.Id;
    }

    public static PickListValues fillPicklist(UpdateContactRequest jsonData){
        
        //System.debug('====== PreferancesMethod ======'+jsonData.EventRequest.CustomerData.PreferanceTypes);
        PickListValues selectedValues = new PickListValues();
        UpdateContactRequest recordData = new UpdateContactRequest();
        
        if(jsonData != null){
            for(UpdateContactRequest.PreferanceTypes data : jsonData.EventRequest.CustomerData.PreferanceTypes){
                //System.debug('====== PreferanceTypes data ======'+data);
                for(UpdateContactRequest.Preferances  preferance: data.Preferances){
                    
                    //System.debug('====== Preferances preferanceName ======'+preferance.preferanceName);
                    if(preferance.preferanceName == 'PO Confirmation'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.poConfirmation = value.Value;
                                //System.debug('====== selectedValues.poConfirmation data ======'+selectedValues.poConfirmation);
                            }
                        }
                    }
                    
                    if(preferance.preferanceName == 'Order Acknowledgement'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.orderAcknowledgement = value.Value;
                                //System.debug('====== selectedValues.orderAcknowledgement data ======'+selectedValues.orderAcknowledgement);
                            }
                        }
                    }
                    
                    if(preferance.preferanceName == 'Shipment Confirmation'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.shipmentConfirmation = value.Value;
                                //System.debug('====== selectedValues.shipmentConfirmation data ======'+selectedValues.shipmentConfirmation);
                            }
                        }
                    }
                    
                    if(preferance.preferanceName == 'Proof Confirmation'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.proofConfirmation = value.Value;
                                //System.debug('====== selectedValues.proofConfirmation data ======'+selectedValues.proofConfirmation);
                            }
                        }
                    }
                    
                    if(preferance.preferanceName == 'When Status changes'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.whenStatuschanges = value.Value;
                                //System.debug('====== selectedValues.whenStatuschanges data ======'+selectedValues.whenStatuschanges);
                            }
                        }
                    }
                    
                    if(preferance.preferanceName == 'Clarification Confirmation'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.clarificationConfirmation = value.Value;
                                //System.debug('====== selectedValues.clarificationConfirmation data ======'+selectedValues.clarificationConfirmation);
                            }
                        }
                    }

					if(preferance.preferanceName == 'Sample Order Follows Ups'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.sampleOrderFollowsUps = value.Value;
                                //System.debug('====== selectedValues.sampleOrderFollowsUps data ======'+selectedValues.clarificationConfirmation);
                            }
                        }
                    }

                    if(preferance.preferanceName == 'Spec Sample Order Reminder'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.specSampleOrderReminder = value.Value;
                                //System.debug('====== selectedValues.specSampleOrderReminder data ======'+selectedValues.specSampleOrderReminder);
                            }
                        }
                    } 

          			if(preferance.preferanceName == 'Reorder Reminders'){
                        for(UpdateContactRequest.PreferancesMethod value : preferance.PreferancesMethod){
                            if(value.Selected == 'true'){
                                selectedValues.reorderReminders = value.Value;
                                //System.debug('====== selectedValues.reorderReminders data ======'+selectedValues.clarificationConfirmation);
                            }
                        }
                    } 


                } 
                
            }
        }
        
        return selectedValues;
    } 

	private static String tagContact(String recordId, String accountNumber, String email){
		//System.debug(LoggingLevel.WARN,'===== recordId ===== '+recordId);
		//System.debug(LoggingLevel.WARN,'=====  accountNumber ===== '+accountNumber);
		//System.debug(LoggingLevel.WARN,'=====  email ===== '+email);	

		String contactId = '';
		if(String.isNotBlank(recordId) && recordId != 'null'){
			return recordId;
		} 
		
		if(String.isNotBlank(accountNumber) && String.isNotBlank(email)){
			contactId = ContactUtill.checkContact(email.trim(),accountNumber.trim());
		}

		System.debug(LoggingLevel.WARN,'=====  contactId ===== '+contactId);
		return contactId;
	}
    
    public class PickListValues {
        public String clarificationConfirmation = '';
        public String whenStatuschanges = '';
        public String proofConfirmation = '';
        public String shipmentConfirmation = '';
        public String orderAcknowledgement = '';
        public String poConfirmation = '';
		public String reorderReminders = '';
    	public String sampleOrderFollowsUps = '';
        public String specSampleOrderReminder = '';
		
    }
    
}