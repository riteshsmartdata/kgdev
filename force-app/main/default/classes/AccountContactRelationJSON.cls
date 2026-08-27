public with sharing class AccountContactRelationJSON {
	 
	public static JSONGenerator relationJSON(AccountContactRelation record){
		//return (AccountContactRelationJSON) System.JSON.deserialize(json, AccountContactRelationJSON.class);

		JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventRequest');
        gen.writeStartObject(); 
		gen.writeStringField('EventBusinessID', record.Id);        
        gen.writeDateTimeField('EventDateTime', record.createdDate);
		gen.writeStringField('EventObject', 'AccountContactRelation');
        gen.writeStringField('EventSourceSystem', 'WebSite');  

		// Account Details
        gen.writeFieldName('AccountContactRelation');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(record.AccountId)){
            gen.writeStringField('AccountId', record.AccountId);
        }else{
            gen.writeNullField('AccountId');
        }
        
        if(String.isNotBlank(record.Account.Name)){
            gen.writeStringField('AccountName', record.Account.Name);
        }else{
            gen.writeNullField('AccountName');
        }
        
        if(String.isNotBlank(record.Account.Customer_Account_Number__c)){
            gen.writeStringField('AccountNumber', record.Account.Customer_Account_Number__c);
        }else{
            gen.writeNullField('AccountNumber');
        }
        
		gen.writeEndObject();

		// Contact Details
		gen.writeFieldName('ContactDetails');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(record.ContactId)){
            gen.writeStringField('ContactId', record.ContactId);
        }else{
            gen.writeNullField('ContactId');
        }
        
        if(String.isNotBlank(record.Contact.FirstName)){
            gen.writeStringField('FirstName', record.Contact.FirstName);
        }else{
            gen.writeNullField('FirstName');
        }
        
        if(String.isNotBlank(record.Contact.LastName)){
            gen.writeStringField('LastName', record.Contact.LastName);
        }else{
            gen.writeNullField('LastName');
        }

		if(String.isNotBlank(record.Contact.Email)){
            gen.writeStringField('Email', record.Contact.Email);
        }else{
            gen.writeNullField('Email');
        }
        
		gen.writeEndObject();
		
        gen.writeBooleanField('IsActive', record.IsActive);        

		if(String.isNotBlank(record.Relationship_Strength__c)){
            gen.writeStringField('Relationship_Strength__c', record.Relationship_Strength__c);
        }else{
            gen.writeNullField('Relationship_Strength__c');
        }

		if(record.StartDate != null){
            gen.writeDateTimeField('StartDate', record.StartDate);
        }else{
            gen.writeNullField('StartDate');
        }

		if(String.isNotBlank(record.Roles)){
            gen.writeStringField('Roles', record.Roles);
        }else{
            gen.writeNullField('Roles');
        }

		if( record.EndDate!= null){
            gen.writeDateTimeField('EndDate', record.EndDate);
        }else{
            gen.writeNullField('EndDate');
        }
		
        gen.writeStringField('SfId', record.Id);
        gen.writeBooleanField('IsDirect', record.IsDirect);
         

		if(String.isNotBlank(record.WebId__c)){
            gen.writeStringField('WebId__c', record.WebId__c);
        }else{
            gen.writeNullField('WebId__c');
        }  
         
        gen.writeEndObject();
        gen.writeEndObject(); 
        System.debug('===== contact Relation Request ====='+gen.getAsString());
        return gen;
	}




	 
}