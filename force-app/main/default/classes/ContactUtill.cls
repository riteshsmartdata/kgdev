/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 11-04-2025
* @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
* Ver   Date         Author         Modification
* 1.0   09-19-2023   Ritesh Kumar   JIRA SF-SF-782 (Code lines 261 to 379 and 640 to 749)
* 1.1   10-19-2023   Ritesh Kumar   JIRA SF-469 ( Code lines 426 to 430 to 805 to 809)
**/
public without sharing class ContactUtill { 
    
    public static JSONGenerator getPOConfirmation( JSONGenerator gen, String defaultValue){  
        List<Schema.PicklistEntry> picklistEntryList = Contact.PO_Confirmation__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
            }
            
        }
        
        return gen;
    }
    
    public static JSONGenerator getOrderAcknowledgeme( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Order_Acknowledgement__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                } 
                gen.writeEndObject();
            }
            
        }
        
        return gen;
    }
    
    public static JSONGenerator getShipmentConfirmation( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Shipment_Confirmation__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject(); 
            }
            
            
        }
        
        return gen;
    }
    
    public static JSONGenerator getProofConfirmation( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Proof_Confirmation__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                } 
                gen.writeEndObject();
            }
            
            
        }
        
        return gen;
    }
    
    public static JSONGenerator getWhenStatuschanges( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.When_Status_changes__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
                
            }
            
            
        }
        
        return gen;
    } 
    
    public static JSONGenerator getClarificationConfirmation( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Clarification_Confirmation__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
            } 
            
        }
        
        return gen;
    } 

	public static JSONGenerator getReorderReminders( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Reorder_Reminder__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
            } 
            
        }
        
        return gen;
    }

	public static JSONGenerator getSampleOrder( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Sample_Order_Reminder__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
            } 
            
        }
        
        return gen;
    }

    public static JSONGenerator getSpecSampleOrder( JSONGenerator gen, String defaultValue){ 
        
        List<Schema.PicklistEntry> picklistEntryList = Contact.Spec_Sample_Order_Reminder__c.getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickList : picklistEntryList) {
            
            if(pickList.getValue() != 'Text' &&  pickList.getValue() != 'Both'){
                gen.writeStartObject();
                gen.writeStringField('Text', pickList.getLabel());
                gen.writeStringField('Value', pickList.getValue()); 
                
                if(defaultValue == pickList.getValue()){
                    gen.writeStringField('Selected', 'true');
                }else{
                    gen.writeStringField('Selected', 'false');
                }
                gen.writeEndObject();
            } 
            
        }
        
        return gen;
    }
    
    public static JSONGenerator accountPreferences( JSONGenerator gen, Contact record){ 
        Contact recordData = record;
        if(String.isNotBlank(record.AccountId)){
		
			gen.writeStartObject();  
			gen.writeBooleanField('Acc_poConfirmation', recordData.Acc_PO_Contact__c); 
			gen.writeBooleanField('Acc_orderAcceptance', recordData.Acc_Order_Acknowledgement__c); 
			gen.writeBooleanField('Acc_shipmentConfirmation', recordData.Acc_Shipping_Contact__c); 
			gen.writeBooleanField('Acc_proofConfirmation', recordData.Acc_Proof_Confirmation__c); 
			gen.writeBooleanField('Acc_clarificationConfirmation', recordData.Acc_Clarification_Confirmation__c); 
			
			if(recordData.Acc_PO_Contact__c == true || recordData.Acc_Order_Acknowledgement__c == true || recordData.Acc_Shipping_Contact__c == true  || recordData.Acc_Proof_Confirmation__c == true  || record.Acc_Clarification_Confirmation__c == true ){
				gen.writeStringField('selectedMethod', 'Email');
			}else{
				gen.writeStringField('selectedMethod', 'None');
			}
			gen.writeEndObject(); 

        }else{
            gen.writeStartObject(); 
            gen.writeBooleanField('Acc_poConfirmation', false);
            gen.writeBooleanField('Acc_orderAcceptance', false);
            gen.writeBooleanField('Acc_shipmentConfirmation', false);
            gen.writeBooleanField('Acc_proofConfirmation', false);
            gen.writeBooleanField('Acc_clarificationConfirmation', false);
            gen.writeStringField('selectedMethod', 'None');
            gen.writeEndObject();
        }
        return gen;
    }
    
    // When CreateContact API Called - Response Send
    public static JSONGenerator contactResponse(String contactId, String status, String dmlType){ 
        Contact contactRecord = [ 
            SELECT id, User_Name__c, Account_Number__c, FirstName, LastName, Contact_Type__c, Email, Phone, MobilePhone, Account.Name, 
            AccountId, RecordTypeId, Recordtype.Name, CreatedDate, Order_Acknowledgement__c,  PO_Confirmation__c, Shipment_Confirmation__c, 
            Proof_Confirmation__c, When_Status_changes__c, Clarification_Confirmation__c, Acc_PO_Contact__c, Acc_Shipping_Contact__c, 
            Acc_Clarification_Confirmation__c, Acc_Order_Acknowledgement__c, Acc_Proof_Confirmation__c ,Web_Id__c,Mktg_comm_preference__c,
            Account.Koozie_Group_Tracker_Link__c, Account.Primary_Team_Member2__c, Account.Primary_Team_Member_Email__c, Account.Primary_Sales_Rep_Region__c,
            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Account.ShippingStreet, 
            Account.ShippingCity, Account.ShippingState, Account.ShippingCountry, Account.ShippingPostalCode, Account.Primary_Team_Member2__r.Name, 
            Account.ASI_Number__c , Account.PPAI_Number__c, Industry_Type__c,Contact_Status__c, Sample_Order_Reminder__c, Reorder_Reminder__c, Spec_Sample_Order_Reminder__c
            FROM Contact 
            WHERE Id=: contactId
            LIMIT 1];
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventResponse');
        gen.writeStartObject();
        
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('EventBusinessID', contactRecord.Email);
        }else{
            gen.writeNullField('EventBusinessID');
        }
        gen.writeStringField('EventStatus', status);
        gen.writeStringField('EventType', dmlType);
        gen.writeStringField('EventStatusMessage', 'Successfully Completed'); 

        gen.writeFieldName('CustomerData');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(contactRecord.Id)){
            gen.writeStringField('sf_Id', contactRecord.Id);
        }else{
            gen.writeNullField('sf_Id');
        }
        
        if(String.isNotBlank(contactRecord.Web_Id__c)){
            gen.writeStringField('web_Id', contactRecord.Web_Id__c);
        }else{
            gen.writeNullField('web_Id');
        }
        
        if(String.isNotBlank(contactRecord.User_Name__c)){
            gen.writeStringField('userName', contactRecord.User_Name__c);
        }else{
            gen.writeNullField('userName');
        }
        
        if(String.isNotBlank(contactRecord.Account_Number__c)){
            gen.writeStringField('accountNumber', contactRecord.Account_Number__c);
        }else{
            gen.writeNullField('accountNumber');
        }
        
        if(String.isNotBlank(contactRecord.FirstName)){
            gen.writeStringField('firstName', contactRecord.FirstName);
        }else{
            gen.writeNullField('firstName');
        }
        
        if(String.isNotBlank(contactRecord.LastName)){
            gen.writeStringField('lastName',  contactRecord.LastName);
        }else{
            gen.writeNullField('lastName');
        } 
        
        if(String.isNotBlank(contactRecord.Contact_Type__c)){
            gen.writeStringField('contactType',  contactRecord.Contact_Type__c);
        }else{
            gen.writeNullField('contactType');
        }
        
        //JIRA SF-469 
        if(String.isNotBlank(contactRecord.Industry_Type__c)){
            gen.writeStringField('industryType',  contactRecord.Industry_Type__c);
        }else{
            gen.writeNullField('industryType');
        }

        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('emailId', contactRecord.Email);
        }else{
            gen.writeNullField('emailId');
        }
        
        if(String.isNotBlank(contactRecord.Phone)){
            gen.writeStringField('primaryPhone', contactRecord.Phone);
        }else{
            gen.writeNullField('primaryPhone');
        }
        
        if(String.isNotBlank(contactRecord.MobilePhone)){
            gen.writeStringField('Mobile', contactRecord.MobilePhone);
        }else{
            gen.writeNullField('Mobile');
        }
        
        if(String.isNotBlank(contactRecord.Account.Name)){
            gen.writeStringField('accountName', contactRecord.Account.Name);
        }else{
            gen.writeNullField('accountName');
        }
        
        if(String.isNotBlank(contactRecord.AccountId)){
            gen.writeStringField('sfAccountId', contactRecord.AccountId);
        }else{
            gen.writeNullField('sfAccountId');
        }
        
        if(String.isNotBlank(contactRecord.RecordType.Name)){
            gen.writeStringField('sfRecordTypeName', contactRecord.RecordType.Name);
        }else{
            gen.writeNullField('sfRecordTypeName');
        }
        
        if(String.isNotBlank(contactRecord.RecordTypeId)){
            gen.writeStringField('sfRecordTypeId', contactRecord.RecordTypeId);
        }else{
            gen.writeNullField('sfRecordTypeId');
        }

        if(contactRecord.Contact_Status__c != null){
            gen.writeBooleanField('contactActiveStatus', contactRecord.Contact_Status__c == 'Active' ? TRUE:FALSE);
        }else{
            gen.writeNullField('contactActiveStatus');
        }

        
        gen.writeDateTimeField('contactCreatedDate',contactRecord.CreatedDate);  
        
        gen.writeFieldName('preferanceTypes');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('preferanceTypeName',  Label.preferanceTypeName);
        gen.writeStringField('preferanceTypeId',  Label.preferanceTypeId); 
        gen.writeNullField('preferanceTypeDetails');
        gen.writeNullField('preferanceTypeDetailsId');
        gen.writeFieldName('preferances');
        gen.writeStartArray();
        gen.writeStartObject();

        gen.writeStringField('preferanceType', 'PO_Confirmation');
        gen.writeStringField('preferanceName', 'PO Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getPOConfirmation(gen,contactRecord.PO_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Order_Acknowledgement');
        gen.writeStringField('preferanceName', 'Order Acknowledgement');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getOrderAcknowledgeme(gen, contactRecord.Order_Acknowledgement__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Shipment_Confirmation');
        gen.writeStringField('preferanceName', 'Shipment Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray(); 
        getShipmentConfirmation(gen,contactRecord.Shipment_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Proof_Confirmation');
        gen.writeStringField('preferanceName', 'Proof Confirmation'); 
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getProofConfirmation(gen,contactRecord.Proof_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'When_Status_changes');
        gen.writeStringField('preferanceName', 'When Status changes'); 
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getWhenStatuschanges(gen,contactRecord.When_Status_changes__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Clarification_Confirmation');
        gen.writeStringField('preferanceName', 'Clarification Confirmation'); 
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getClarificationConfirmation(gen,contactRecord.Clarification_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

		gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Reorder_Reminders');
        gen.writeStringField('preferanceName', 'Reorder Reminders');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getReorderReminders(gen,contactRecord.Reorder_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject();

		gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Sample_Order_Follows_Ups');
        gen.writeStringField('preferanceName', 'Sample Order Follows Ups');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getSampleOrder(gen,contactRecord.Sample_Order_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject(); 

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Spec_Sample_Order_Reminder');
        gen.writeStringField('preferanceName', 'Spec Sample Order Reminder');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getSpecSampleOrder(gen,contactRecord.Spec_Sample_Order_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject(); 

        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('accountPreferences'); 
        accountPreferences(gen,contactRecord); 
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject(); 
        System.debug('===== contactResponse ====='+gen.getAsString());
        return gen;
    }
    
    // When UpdateContact API Called - Response Send
    public static JSONGenerator contactResponseForm(String contactId, String status, String dmlType){ 
        Contact contactRecord = [ SELECT id, Email, Web_Id__c FROM Contact WHERE Id=: contactId  LIMIT 1]; 
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventResponse');
        gen.writeStartObject();
        
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('EventBusinessID', contactRecord.Email);
        }else{
            gen.writeNullField('EventBusinessID');
        }
        gen.writeStringField('EventStatus', status);
        gen.writeStringField('EventStatusMessage', 'Successfully Completed');
        gen.writeFieldName('CustomerData');
        gen.writeStartObject();
        gen.writeStringField('SFId', contactRecord.Id);
        
        if(String.isNotBlank(contactRecord.Web_Id__c) &&   contactRecord.Web_Id__c != 'null'){
            gen.writeStringField('web_Id', contactRecord.Web_Id__c);
        }else{
            gen.writeNullField('web_Id');
        }
        
        if(String.isNotBlank(contactRecord.Email) && contactRecord.Email != 'null' ){
            gen.writeStringField('emailId', contactRecord.Email);
        }else{
            gen.writeNullField('emailId');
        }
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject(); 
        return gen; 
    }
    
    // When we push data from Salesfroce to webstie
    public static JSONGenerator contactRequest(String contactId, String objectName, String dmlType){ 
        Contact contactRecord = new Contact();
        
        Contact [] recordData = [ 
            SELECT id, User_Name__c, Account_Number__c, FirstName, LastName, Contact_Type__c, Email, Phone, MobilePhone, Account.Name, 
            AccountId, RecordTypeId, Recordtype.Name, CreatedDate, Order_Acknowledgement__c,  PO_Confirmation__c, Shipment_Confirmation__c, 
            Proof_Confirmation__c, When_Status_changes__c, Clarification_Confirmation__c, Acc_PO_Contact__c, Acc_Shipping_Contact__c, 
            Acc_Clarification_Confirmation__c, Acc_Order_Acknowledgement__c, Acc_Proof_Confirmation__c, Web_Id__c,Mktg_comm_preference__c,
            Account.Koozie_Group_Tracker_Link__c, Account.Primary_Team_Member2__c, Account.Primary_Team_Member_Email__c, Account.Primary_Sales_Rep_Region__c,
            Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, Account.ShippingStreet, 
            Account.ShippingCity, Account.ShippingState, Account.ShippingCountry, Account.ShippingPostalCode, Account.Primary_Team_Member2__r.Name, 
            Account.ASI_Number__c , Account.PPAI_Number__c, Industry_Type__c,Contact_Status__c, Sample_Order_Reminder__c, Reorder_Reminder__c,Spec_Sample_Order_Reminder__c
            FROM Contact
            WHERE Id=: contactId
            LIMIT 1
        ];
        
        if(recordData.size() > 0){
            contactRecord = recordData[0];
        }
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventRequest');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('EventBusinessID',contactRecord.Email);  
        }else{
            gen.writeNullField('EventBusinessID');
        } 
        
        if(contactRecord.CreatedDate != null){
            gen.writeDateTimeField('EventDateTime', contactRecord.CreatedDate);
        }else{
            gen.writeNullField('EventObject');
        }
        
        if(String.isNotBlank(objectName)){
            gen.writeStringField('EventObject',objectName);  
        }else{
            gen.writeNullField('EventObject');
        } 
        
        gen.writeStringField('EventSourceSystem','Salesforce'); 
        
        if(String.isNotBlank(dmlType)){
            gen.writeStringField('EventType',dmlType);  
        }else{
            gen.writeNullField('EventType');
        } 
         
        gen.writeFieldName('CustomerData');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(contactRecord.Id)){
            gen.writeStringField('sf_Id', contactRecord.Id);
        }else{
            gen.writeNullField('sf_Id');
        }
        
        if(String.isNotBlank(contactRecord.Web_Id__c)){
            gen.writeStringField('web_Id', contactRecord.Web_Id__c);
        }else{
            gen.writeNullField('web_Id');
        }
        
        if(String.isNotBlank(contactRecord.User_Name__c)){
            gen.writeStringField('userName', contactRecord.User_Name__c);
        }else{
            gen.writeNullField('userName');
        }
        
        if(String.isNotBlank(contactRecord.Account_Number__c)){
            gen.writeStringField('accountNumber', contactRecord.Account_Number__c);
        }else{
            gen.writeNullField('accountNumber');
        }
        
        if(String.isNotBlank(contactRecord.FirstName)){
            gen.writeStringField('firstName', contactRecord.FirstName);
        }else{
            gen.writeNullField('firstName');
        }
        
        if(String.isNotBlank(contactRecord.LastName)){
            gen.writeStringField('lastName',  contactRecord.LastName);
        }else{
            gen.writeNullField('lastName');
        } 
        
        if(String.isNotBlank(contactRecord.Contact_Type__c)){
            gen.writeStringField('contactType',  contactRecord.Contact_Type__c);
        }else{
            gen.writeNullField('contactType');
        }
 
        if(String.isNotBlank(contactRecord.Industry_Type__c)){
            gen.writeStringField('industryType',  contactRecord.Industry_Type__c);
        }else{
            gen.writeNullField('industryType');
        }
        
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('emailId', contactRecord.Email);
        }else{
            gen.writeNullField('emailId');
        }
        
        if(String.isNotBlank(contactRecord.Phone)){
            gen.writeStringField('primaryPhone', contactRecord.Phone);
        }else{
            gen.writeNullField('primaryPhone');
        }
        
        if(String.isNotBlank(contactRecord.MobilePhone)){
            gen.writeStringField('Mobile', contactRecord.MobilePhone);
        }else{
            gen.writeNullField('Mobile');
        }
        
        if(String.isNotBlank(contactRecord.Account.Name)){
            gen.writeStringField('accountName', contactRecord.Account.Name);
        }else{
            gen.writeNullField('accountName');
        }
        
        if(String.isNotBlank(contactRecord.AccountId)){
            gen.writeStringField('sfAccountId', contactRecord.AccountId);
        }else{
            gen.writeNullField('sfAccountId');
        }
        
        if(String.isNotBlank(contactRecord.RecordType.Name)){
            gen.writeStringField('sfRecordTypeName', contactRecord.RecordType.Name);
        }else{
            gen.writeNullField('sfRecordTypeName');
        }
        
        if(contactRecord.RecordTypeId != null){
            gen.writeStringField('sfRecordTypeId', contactRecord.RecordTypeId);
        }else{
            gen.writeNullField('sfRecordTypeId');
        }
        
        if(contactRecord.Mktg_comm_preference__c != null){
            gen.writeStringField('marketingLink', contactRecord.Mktg_comm_preference__c );
        }else{
            gen.writeNullField('marketingLink');
        }
        
        if(contactRecord.CreatedDate != null){
            gen.writeDateTimeField('contactCreatedDate', contactRecord.CreatedDate);
        }else{
            gen.writeNullField('contactCreatedDate');
        }
        
        if(contactRecord.Contact_Status__c != null){
            gen.writeBooleanField('contactActiveStatus', contactRecord.Contact_Status__c == 'Active' ? TRUE:FALSE);
        }else{
            gen.writeNullField('contactActiveStatus');
        }
        
        gen.writeFieldName('preferanceTypes');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('preferanceTypeName',  Label.preferanceTypeName);
        gen.writeStringField('preferanceTypeId',  Label.preferanceTypeId); 
        gen.writeNullField('preferanceTypeDetails');
        gen.writeNullField('preferanceTypeDetailsId');
        gen.writeFieldName('preferances');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'PO_Confirmation');
        gen.writeStringField('preferanceName', 'PO Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getPOConfirmation(gen,contactRecord.PO_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Order_Acknowledgement');
        gen.writeStringField('preferanceName', 'Order Acknowledgement'); 
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getOrderAcknowledgeme(gen, contactRecord.Order_Acknowledgement__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Shipment_Confirmation');
        gen.writeStringField('preferanceName', 'Shipment Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray(); 
        getShipmentConfirmation(gen,contactRecord.Shipment_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Proof_Confirmation');
        gen.writeStringField('preferanceName', 'Proof Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getProofConfirmation(gen,contactRecord.Proof_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'When_Status_changes');
        gen.writeStringField('preferanceName', 'When Status changes');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getWhenStatuschanges(gen,contactRecord.When_Status_changes__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Clarification_Confirmation');
        gen.writeStringField('preferanceName', 'Clarification Confirmation');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getClarificationConfirmation(gen,contactRecord.Clarification_Confirmation__c);
        gen.writeEndArray();
        gen.writeEndObject();

		gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Reorder_Reminders');
        gen.writeStringField('preferanceName', 'Reorder Reminders');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getProofConfirmation(gen,contactRecord.Reorder_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject();

		gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Sample_Order_Follows_Ups');
        gen.writeStringField('preferanceName', 'Sample Order Follows Ups');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getProofConfirmation(gen,contactRecord.Sample_Order_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('preferanceType', 'Spec_Sample_Order_Reminder');
        gen.writeStringField('preferanceName', 'Spec Sample Order Reminder');
        gen.writeFieldName('preferancesMethod');
        gen.writeStartArray();
        getSpecSampleOrder(gen,contactRecord.Spec_Sample_Order_Reminder__c);
        gen.writeEndArray();
        gen.writeEndObject(); 

        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeFieldName('accountPreferences'); 
        accountPreferences(gen,contactRecord); 
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject(); 
        System.debug('===== contactRequest ====='+gen.getAsString());
        return gen;
    }
    
    public static String checkContact(String emailId, String accountNumber){  
        System.debug('====== checkContact emailId : '+ emailId +' ===== accountNumber : '+accountNumber);
        String contactId =''; 
        Contact [] record = [
            SELECT id, Email,Account.Customer_Account_Number__c 
            FROM Contact 
            WHERE Email =: emailId AND
            RecordType.Name = 'CRM Contact' AND 
            Account.Customer_Account_Number__c =:accountNumber ORDER BY CreatedDate DESC LIMIT 1];
 			System.debug('======checkContact  record : '+ record);
        if(record.size() > 0){
            contactId = record[0].Id;
        }
        
        return contactId;
    } 
    
    public static Set<String> getFieldDifference_D(Contact newContact,Contact oldContact){ 
        Set<String> fieldDifferenc = new Set<String>();
        if(newContact.PO_Confirmation__c != oldContact.PO_Confirmation__c ){
            fieldDifferenc.add('PO_Confirmation__c');
        }
        
        if(newContact.Order_Acknowledgement__c != oldContact.Order_Acknowledgement__c ){
            fieldDifferenc.add('Order_Acknowledgement__c');
        }
        
        if(newContact.Shipment_Confirmation__c != oldContact.Shipment_Confirmation__c ){
            fieldDifferenc.add('Shipment_Confirmation__c');
        }
        
        if(newContact.Proof_Confirmation__c != oldContact.Proof_Confirmation__c ){
            fieldDifferenc.add('Proof_Confirmation__c');
        } 
        
        if(newContact.When_Status_changes__c != oldContact.When_Status_changes__c ){
            fieldDifferenc.add('When_Status_changes__c');
        }

        if(newContact.Spec_Sample_Order_Reminder__c != oldContact.Spec_Sample_Order_Reminder__c ){
            fieldDifferenc.add('Spec_Sample_Order_Reminder__c');
        }
        
        if(newContact.Clarification_Confirmation__c != oldContact.Clarification_Confirmation__c ){
            fieldDifferenc.add('Clarification_Confirmation__c');
        }
        
        if(newContact.Acc_PO_Contact__c != oldContact.Acc_PO_Contact__c ){
            fieldDifferenc.add('Acc_PO_Contact__c');
        }
        
        if(newContact.Acc_Order_Acknowledgement__c != oldContact.Acc_Order_Acknowledgement__c ){
            fieldDifferenc.add('Acc_Order_Acknowledgement__c');
        }
        
        if(newContact.Acc_Shipping_Contact__c != oldContact.Acc_Shipping_Contact__c){
            fieldDifferenc.add('Acc_Shipping_Contact__c');
        }
        
        
        if(newContact.Acc_Proof_Confirmation__c != oldContact.Acc_Proof_Confirmation__c ){
            fieldDifferenc.add('Acc_Proof_Confirmation__c');
        }
        
        if(newContact.Acc_Clarification_Confirmation__c != oldContact.Acc_Clarification_Confirmation__c ){
            fieldDifferenc.add('Acc_Clarification_Confirmation__c');
        }
        
        if(newContact.FirstName != oldContact.FirstName ){
            fieldDifferenc.add('FirstName');
        }
        
        if(newContact.LastName != oldContact.LastName ){
            fieldDifferenc.add('LastName');
        }
        
        if(newContact.MobilePhone != oldContact.MobilePhone ){
            fieldDifferenc.add('MobilePhone');
        }

        if(newContact.Phone != oldContact.Phone ){
            fieldDifferenc.add('Phone');
        }

        if(newContact.AccountId != oldContact.AccountId ){
            fieldDifferenc.add('AccountId');
        }
        
        if(newContact.Email != oldContact.Email ){
            fieldDifferenc.add('Email');
        }
        
        if(newContact.Web_Id__c != oldContact.Web_Id__c ){
            fieldDifferenc.add('Web_Id__c');
        }
        
        if(newContact.User_Name__c != oldContact.User_Name__c ){
            fieldDifferenc.add('User_Name__c');
        }
        
        if(newContact.Contact_Type__c != oldContact.Contact_Type__c ){
            fieldDifferenc.add('Contact_Type__c');
        }
        
        if(newContact.RecordTypeId != oldContact.RecordTypeId ){
            fieldDifferenc.add('RecordTypeId');
        } 

        if(newContact.Industry_Type__c != oldContact.Industry_Type__c ){
            fieldDifferenc.add('Industry_Type__c');
        } 

        if(newContact.Mktg_comm_preference__c != oldContact.Mktg_comm_preference__c ){
            fieldDifferenc.add('Mktg_comm_preference__c');
        } 

        if(newContact.Contact_Status__c != oldContact.Contact_Status__c ){
            fieldDifferenc.add('Contact_Status__c');
        } 
        
        return fieldDifferenc; 
    }  
    
    public static Set<String> getFieldDifference(Contact newContact, Contact oldContact) { 
    Set<String> fieldDifference = new Set<String>();
    
    // Define the fields you want to compare
    List<String> fieldsToCompare = new List<String>{
        'PO_Confirmation__c', 'Order_Acknowledgement__c', 'Shipment_Confirmation__c', 
        'Proof_Confirmation__c', 'When_Status_changes__c', 'Clarification_Confirmation__c', 
        'Acc_PO_Contact__c', 'Acc_Order_Acknowledgement__c', 'Acc_Shipping_Contact__c', 
        'Acc_Proof_Confirmation__c', 'Acc_Clarification_Confirmation__c', 
        'FirstName', 'LastName', 'MobilePhone', 'Phone', 'AccountId', 'Email', 
        'Web_Id__c', 'User_Name__c', 'Contact_Type__c', 'RecordTypeId', 'Industry_Type__c', 
        'Mktg_comm_preference__c', 'Contact_Status__c', 'Reorder_Reminder__c', 'Sample_Order_Reminder__c'
    };

    // Iterate through the fields and compare their values
    for (String field : fieldsToCompare) {
        if (newContact.get(field) != oldContact.get(field)) {
            fieldDifference.add(field);
        }
    }
    
    return fieldDifference; 
}

}