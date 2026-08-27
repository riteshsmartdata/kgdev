/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 06-27-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   04-28-2023   Ritesh Kumar   Initial Version
**/
public without sharing class ContactOdsJson {

    /**
     * Method is used to genrate JSON.
     */
    
    public static String replaceOneJSON(Contact contactRecord){
        JSONGenerator gen = JSON.createGenerator(true);
        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance(KoozieUtility.isSandbox() ? 'Send_Contact_Information_Full_Sandbox' : 'Send_Contact_Information');
        //Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');
        if(contactRecord != null){ 

            gen.writeStartObject(); 
            gen.writeStringField('dataSource', API_SETTING.Data_Source__c);
            gen.writeStringField('database', API_SETTING.Database__c);
            gen.writeStringField('collection', API_SETTING.Collection__c);

            gen.writeFieldName('filter');
            gen.writeStartObject();
            gen.writeStringField('salesforceId', contactRecord.Id);
            gen.writeEndObject();

            gen.writeFieldName('replacement');
            gen.writeStartObject();
 
            if(contactRecord.Phone != null){
                gen.writeStringField('phone', contactRecord.Phone);
            }else{
                gen.writeNullField('phone');
            }

            if(contactRecord.PromoStandards_Contact__c != null){
                gen.writeBooleanField('promoStandardsContact', contactRecord.PromoStandards_Contact__c);
            }else{
                gen.writeNullField('promoStandardsContact');
            } 

            if(contactRecord.PrimaryOtherEmailFlag__c != null){
                gen.writeBooleanField('primaryOtherEmailFlag', contactRecord.PrimaryOtherEmailFlag__c);
            }else{
                gen.writeNullField('primaryOtherEmailFlag');
            } 

            if(contactRecord.Top_Producer__c != null){
                gen.writeBooleanField('topProducer', contactRecord.Top_Producer__c);
            }else{
                gen.writeNullField('topProducer');
            }

            if(contactRecord.Responsibility_Type__c != null){
                gen.writeStringField('responsibilityType', contactRecord.Responsibility_Type__c);
            }else{
                gen.writeNullField('responsibilityType');
            } 

            if(contactRecord.Account_Industry__c != null){
                gen.writeStringField('accountIndustry', contactRecord.Account_Industry__c);
            }else{
                gen.writeNullField('accountIndustry');
            } 

            if(contactRecord.OtherPhone != null){
                gen.writeStringField('otherPhone', contactRecord.OtherPhone);
            }else{
                gen.writeNullField('otherPhone');
            }

            if(contactRecord.Other_Email__c != null){
                gen.writeStringField('otherEmail', contactRecord.Other_Email__c);
            }else{
                gen.writeNullField('otherEmail');
            }

            if(contactRecord.PrimaryEmailFlag__c != null){
                gen.writeBooleanField('primaryEmailFlag', contactRecord.PrimaryEmailFlag__c);
            }else{
                gen.writeNullField('primaryEmailFlag');
            } 

            if(contactRecord.EmailID__c != null){
                gen.writeStringField('emailId', contactRecord.EmailID__c);
            }else{
                gen.writeNullField('emailId');
            } 

            if(contactRecord.Date_Verified__c != null){
                gen.writeDateTimeField('dateVerified', contactRecord.Date_Verified__c);
            }else{
                gen.writeNullField('dateVerified');
            }

            if(contactRecord.FaxID__c != null){
                gen.writeStringField('faxId', contactRecord.FaxID__c);
            }else{
                gen.writeNullField('faxId');
            } 

            if(contactRecord.Verified__c != null){
                gen.writeBooleanField('verified', contactRecord.Verified__c);
            }else{
                gen.writeNullField('verified');
            }

            if(contactRecord.MiddleName != null){
                gen.writeStringField('middlesName', contactRecord.MiddleName);
            }else{
                gen.writeNullField('middlesName');
            } 

            if(contactRecord.PrimaryFaxFlag__c != null){
                gen.writeBooleanField('primaryFaxFlag', contactRecord.PrimaryFaxFlag__c);
            }else{
                gen.writeNullField('primaryFaxFlag');
            } 

            gen.writeFieldName('ShippingAddressArray');
            gen.writeStartArray();
            gen.writeStartObject();
            
            if(contactRecord.MailingPostalCode != null){
                gen.writeStringField('mailingPostalCode', contactRecord.MailingPostalCode);
            }else{
                gen.writeNullField('mailingPostalCode');
            }
            
            if(contactRecord.MailingCity != null){
                gen.writeStringField('mailingCity', contactRecord.MailingCity);
            }else{
                gen.writeNullField('mailingCity');
            }
            
            if(contactRecord.MailingCountry != null){
                gen.writeStringField('mailingCountry', contactRecord.MailingCountry);
            }else{
                gen.writeNullField('mailingCountry');
            }
            
            if(contactRecord.MailingState != null){
                gen.writeStringField('mailingState', contactRecord.MailingState);
            }else{
                gen.writeNullField('mailingState');
            }
            
            if(contactRecord.MailingStreet != null){
                gen.writeStringField('mailingStreet', contactRecord.MailingStreet);
            }else{
                gen.writeNullField('mailingStreet');
            }
            
            gen.writeEndObject();
            gen.writeEndArray();
            
            if(contactRecord.Other_Email_ID__c != null){
                gen.writeStringField('otherEmailId', contactRecord.Other_Email_ID__c);
            }else{
                gen.writeNullField('otherEmailId');
            }
            
            if(contactRecord.LastName != null){
                gen.writeStringField('lastName', contactRecord.LastName); 
            }else{
                gen.writeNullField('lastName');
            }
            
            if(contactRecord.Fax != null){
                gen.writeStringField('fax', contactRecord.Fax);
            }else{
                gen.writeNullField('fax');
            }
            
            if(contactRecord.PrimaryOtherPhoneFlag__c != null){
                gen.writeBooleanField('primaryOtherPhoneFlag', contactRecord.PrimaryOtherPhoneFlag__c);
            }else{
                gen.writeNullField('primaryOtherPhoneFlag');
            }
            
            if(contactRecord.Account_Number__c != null){ 
                gen.writeFieldName('accountNo');
                gen.writeStartObject();
                gen.writeStringField('$numberLong', String.valueOf(contactRecord.Account_Number__c));
                gen.writeEndObject();
            }else{
                gen.writeNullField('accountNo');
            }
            
            if(contactRecord.Address_Type__c != null){
                gen.writeStringField('addressType', contactRecord.Address_Type__c);
            }else{
                gen.writeNullField('addressType');
            }
            
            if(contactRecord.Id != null){
                gen.writeStringField('salesforceId', contactRecord.Id);
            }else{
                gen.writeNullField('salesforceId');
            }
            
            if(contactRecord.Clean_Phone_Number__c != null){
                gen.writeStringField('cleanPhoneNumber', contactRecord.Clean_Phone_Number__c);
            }else{
                gen.writeNullField('cleanPhoneNumber');
            }
            
            if(contactRecord.Contact_ID__c != null){
                gen.writeStringField('EBSContactId', contactRecord.Contact_ID__c);
            }else{
                gen.writeNullField('EBSContactId');
            }
            
            if(contactRecord.CreatedById != null){
                gen.writeStringField('createdBy', contactRecord.CreatedById);
            }else{
                gen.writeNullField('createdBy');
            }
            
            if(contactRecord.Email != null){
                gen.writeStringField('email', contactRecord.Email);
            }else{
                gen.writeNullField('email');
            }
            
            if(contactRecord.LastModifiedById != null){
                gen.writeStringField('lastModifiedBy', contactRecord.LastModifiedById);
            }else{
                gen.writeNullField('lastModifiedBy');
            }
            
            if(contactRecord.Contact_Type__c != null){
                gen.writeStringField('contactType', contactRecord.Contact_Type__c);
            }else{
                gen.writeNullField('contactType');
            }
                        
            if(contactRecord.Contact_Account_Status__c != null){
                gen.writeStringField('contactAccountStatus', contactRecord.Contact_Account_Status__c);
            }else{
                gen.writeNullField('contactAccountStatus');
            }
            
            if(contactRecord.IsDeleted != null){
                gen.writeBooleanField('isDeletedInSf', contactRecord.IsDeleted); 
            }else{
                gen.writeNullField('isDeletedInSf');
            }
            
            if(contactRecord.MobilePhone != null){
                gen.writeStringField('mobile', contactRecord.MobilePhone);
            }else{
                gen.writeNullField('mobile');
            }
            
            if(contactRecord.Territory__c != null){
                gen.writeStringField('territory', contactRecord.Territory__c);
            }else{
                gen.writeNullField('territory');
            }
            
            if(contactRecord.Address_Status__c != null){
                gen.writeStringField('addressStatus', contactRecord.Address_Status__c);
            }else{
                gen.writeNullField('addressStatus');
            }
            
            if(contactRecord.RecordTypeId != null){
                gen.writeStringField('contactRecordType', contactRecord.RecordTypeId);
            }else{
                gen.writeNullField('contactRecordType');
            }
            
            if(contactRecord.LastModifiedDate != null){  
                gen.writeFieldName('ODSLastModifiedDate');
                gen.writeStartObject();
                gen.writeFieldName('$date');
                gen.writeStartObject();
                gen.writeStringField('$numberLong', String.valueOf(contactRecord.LastModifiedDate.getTime()));
                gen.writeEndObject();
                gen.writeEndObject();
            }else{
                gen.writeNullField('ODSLastModifiedDate');
            }
            
            if(contactRecord.Source_ID__c != null){
                gen.writeStringField('sourceId', contactRecord.Source_ID__c);
            }else{
                gen.writeNullField('sourceId');
            }
            
            if(contactRecord.Title != null){
                gen.writeStringField('title', contactRecord.Title);
            }else{
                gen.writeNullField('title');
            }
            
            if(contactRecord.OwnerId != null){
                gen.writeStringField('contactOwner', contactRecord.OwnerId);
            }else{
                gen.writeNullField('contactOwner');
            }
            
            if(contactRecord.CreatedDate != null){ 
                gen.writeFieldName('createdAt');
                gen.writeStartObject();
                gen.writeFieldName('$date');
                gen.writeStartObject();
                gen.writeStringField('$numberLong', String.valueOf(contactRecord.CreatedDate.getTime()));
                gen.writeEndObject();
                gen.writeEndObject();
            }else{
                gen.writeNullField('createdAt');
            }
            
            if(contactRecord.OtherPhoneID__c != null){
                gen.writeStringField('otherPhoneId', contactRecord.OtherPhoneID__c);
            }else{
                gen.writeNullField('otherPhoneId');
            }
            
            if(contactRecord.PhoneID__c != null){
                gen.writeStringField('phoneId', contactRecord.PhoneID__c);
            }else{
                gen.writeNullField('phoneId');
            }
            
            if(contactRecord.HasOptedOutOfEmail != null){
                gen.writeBooleanField('emailOptOut', contactRecord.HasOptedOutOfEmail);
            }else{
                gen.writeNullField('emailOptOut');
            }
            
            if(contactRecord.FirstName != null){
                gen.writeStringField('firstName', contactRecord.FirstName); 
            }else{
                gen.writeNullField('firstName');
            }
            
            if(contactRecord.Do_Not_Mail__c != null){
                gen.writeBooleanField('doNotMail', contactRecord.Do_Not_Mail__c);
            }else{
                gen.writeNullField('doNotMail');
            }
            
            if(contactRecord.Suffix != null){
                gen.writeStringField('suffix', contactRecord.Suffix); 
            }else{
                gen.writeNullField('suffix'); 
            }
            
            if(contactRecord.AccountId != null){
                gen.writeStringField('accountName', contactRecord.AccountId); 
            }else{
                gen.writeNullField('accountName');
            }
            
            if(contactRecord.PrimaryPhoneFlag__c != null){
                gen.writeBooleanField('primaryPhoneFlag', contactRecord.PrimaryPhoneFlag__c);
            }else{
                gen.writeNullField('primaryPhoneFlag');
            }
            
            if(contactRecord.Source__c != null){
                gen.writeStringField('source', contactRecord.Source__c);
            }else{
                gen.writeNullField('source');
            }
            
            if(contactRecord.Contact_Status__c != null){
                gen.writeStringField('contactStatus', contactRecord.Contact_Status__c);
            }else{
                gen.writeNullField('contactStatus');
            }
            
            //MP-https://kooziegroup.atlassian.net/browse/MP-481
            if(contactRecord.Is_Sales_Contact__c != null){
                gen.writeBooleanField('distributorSalesContact', contactRecord.Is_Sales_Contact__c);
            }else{
                gen.writeNullField('distributorSalesContact');
            }
            
            if(contactRecord.LastModifiedDate != null){ 
                gen.writeFieldName('lastModifiedDate');
                gen.writeStartObject();
                gen.writeFieldName('$date');
                gen.writeStartObject();  
                gen.writeStringField('$numberLong', String.valueOf(contactRecord.LastModifiedDate.getTime()));
                gen.writeEndObject();
                gen.writeEndObject();
            }else{
                gen.writeNullField('lastModifiedDate');
            }
            
            if(contactRecord.Salutation != null){
                gen.writeStringField('salutation', contactRecord.Salutation);
            }else{
                gen.writeNullField('salutation');
            }
            gen.writeEndObject();
            gen.writeBooleanField('upsert', true); 
            gen.writeEndObject();

        }
		System.debug('===== ODS JSON ====='+gen.getAsString());
        return gen.getAsString();
    }
}