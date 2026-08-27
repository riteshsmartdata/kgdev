/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   10-12-2023   Ritesh Kumar   Initial Version
**/

public class GenerateContactJSONData {
    
   // @future(callout=true)
    public static LogInput generateJSONForSingleContactInsert( String  jsonData, String crudMode, String recordId){ 

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');
        LogInput errorLog = new LogInput();
        //System.debug('====== future generateJSONForSingleContactInsert===== '); 
       // Contact_Endpoint__c app = new Contact_Endpoint__c();  

        String endpoint = API_SETTING.End_Point__c;
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(crudMode == 'UPDATE'){
            endpoint += 'action/updateOne';
        }else if(crudMode == 'INSERT'){
            endpoint += 'action/insertOne';
        }
        //System.debug('======endpoint===='+endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('api-key', API_SETTING.API_Key__c); 
        //request.setHeader('User-agent', 'Salesforce-integration-client');
        /* Commented by Prerak on 4/10/2023 request.setHeader('Authorization','Bearer'); */
        request.setBody(jsonData);
        request.setTimeout(120000);
        
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200){
            //System.debug('==== Apex log====='+response.getStatusCode());
            
            errorLog.source = 'ODS : Single Contact Insert';
            errorLog.requestBody = jsonData;
            errorLog.resopnseBody =  response.toString();
            errorLog.recordId = recordId;
            errorLog.objectName = 'Contact';
            errorLog.statusCode = response.getStatusCode();
             
            //ApexLogUtill.createApexLog('ODS : Single Contact Insert', jsonData, response.toString(), recordId, 'Contact', '', response.getStatusCode());
        }
        //System.debug('===== Response Body ======: '+response.getBody());
        //System.debug('===== Status Code ======: '+response.getStatusCode());    
        //System.debug('===== response ======: '+response );  
        
        return errorLog;
    }

    public static LogInput sendSingleContactInformation( String  jsonData, String crudMode, String recordId){ 

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');
        LogInput errorLog = new LogInput();

        //System.debug('====== future generateJSONForSingleContactInsert===== '); 
       // Contact_Endpoint__c app = new Contact_Endpoint__c();  

        String endpoint = API_SETTING.End_Point__c;
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(crudMode == 'UPDATE'){
            endpoint += 'action/updateOne';
        }else if(crudMode == 'INSERT'){
            endpoint += 'action/insertOne';
        }
        //System.debug('======endpoint===='+endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        request.setHeader('api-key', API_SETTING.API_Key__c); 
        request.setHeader('User-agent', 'Salesforce-integration-client');
        request.setHeader('Authorization','Bearer');
        request.setBody(jsonData);
        request.setTimeout(120000);
        
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200 || response.getStatusCode() != 201){
            //System.debug('==== Apex log====='+response.getStatusCode());
            
            errorLog.source = 'ODS : Contact Information';
            errorLog.requestBody = jsonData;
            errorLog.resopnseBody =  response.toString();
            errorLog.recordId = recordId;
            errorLog.objectName = 'Contact';
            errorLog.statusCode = response.getStatusCode();
           //ApexLogUtill.createApexLog('ODS : ContactInformation', jsonData, response.toString(), recordId, 'Contact', '', response.getStatusCode());
        }
        //System.debug('===== Response Body ======: '+response.getBody());
        //System.debug('===== Status Code ======: '+response.getStatusCode());    
        //System.debug('===== response ======: '+response );    
        return errorLog;
    }

    public static String insertOneContactJSON(Contact contactRecord){
        JSONGenerator gen = JSON.createGenerator(true);
        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');
        if(contactRecord != null){ 

            gen.writeStartObject(); 
            gen.writeStringField('dataSource', API_SETTING.Data_Source__c);
            gen.writeStringField('database', API_SETTING.Database__c);
            gen.writeStringField('collection', API_SETTING.Collection__c);
            gen.writeFieldName('document');
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
                gen.writeStringField('accountNo', contactRecord.Account_Number__c);
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

            if(contactRecord.Merged_Contact_ID__c != null){
                gen.writeStringField('createdBy', contactRecord.Merged_Contact_ID__c);
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
            
            /*if(contactRecord.LastModifiedDate != null){
                gen.writeDateTimeField('ODSLastModifiedDate', contactRecord.LastModifiedDate); 
            }else{
                gen.writeNullField('ODSLastModifiedDate');
            }*/
            
            setDateTime(gen,'ODSLastModifiedDate',contactRecord.LastModifiedDate );
            
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

            setDateTime(gen,'createdAt',contactRecord.CreatedDate );
 
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
            
            setDateTime(gen,'lastModifiedDate',contactRecord.LastModifiedDate );
            
            if(contactRecord.Salutation != null){
                gen.writeStringField('salutation', contactRecord.Salutation);
            }else{
                gen.writeNullField('salutation');
            }
            gen.writeEndObject();
            gen.writeEndObject();

        } 
        return gen.getAsString();
    }

    public static String updateOneContactJSON (Contact contactRecord , Set<String> contactFields){

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');
        JSONGenerator gen = JSON.createGenerator(true);
        if(contactRecord != null){ 

            gen.writeStartObject(); 
            gen.writeStringField('dataSource', API_SETTING.Data_Source__c);
            gen.writeStringField('database', API_SETTING.Database__c);
            gen.writeStringField('collection', 'Contact');
            gen.writeFieldName('filter');
            gen.writeStartObject();
            if(contactRecord.Id != null){
                gen.writeStringField('salesforceId', contactRecord.Id);
            }else{
                gen.writeNullField('salesforceId');
            }

            gen.writeEndObject();

            gen.writeFieldName('update');
            gen.writeStartObject();

            gen.writeFieldName('$set');
            gen.writeStartObject();
 
            if(contactRecord.Phone != null && contactFields.contains('Phone')){
                gen.writeStringField('phone', contactRecord.Phone);
            }else if(contactRecord.Phone == null && contactFields.contains('Phone')){
                gen.writeNullField('phone');
            }

            if(contactRecord.PromoStandards_Contact__c != null && contactFields.contains('PromoStandards_Contact__c')){
                gen.writeBooleanField('promoStandardsContact', contactRecord.PromoStandards_Contact__c);
            }else if(contactRecord.PromoStandards_Contact__c == null && contactFields.contains('PromoStandards_Contact__c')){
                gen.writeNullField('promoStandardsContact');
            } 

            if(contactRecord.PrimaryOtherEmailFlag__c != null && contactFields.contains('PrimaryOtherEmailFlag__c')){
                gen.writeBooleanField('primaryOtherEmailFlag', contactRecord.PrimaryOtherEmailFlag__c);
            }else if(contactRecord.PrimaryOtherEmailFlag__c == null && contactFields.contains('PrimaryOtherEmailFlag__c')){
                gen.writeNullField('primaryOtherEmailFlag');
            } 

            if(contactRecord.Top_Producer__c != null && contactFields.contains('Top_Producer__c')){
                gen.writeBooleanField('topProducer', contactRecord.Top_Producer__c);
            }else if(contactRecord.Top_Producer__c == null && contactFields.contains('Top_Producer__c')){
                gen.writeNullField('topProducer');
            }

            if(contactRecord.Responsibility_Type__c != null && contactFields.contains('Responsibility_Type__c')){
                gen.writeStringField('responsibilityType', contactRecord.Responsibility_Type__c);
            }else if(contactRecord.Responsibility_Type__c == null && contactFields.contains('Responsibility_Type__c')){
                gen.writeNullField('responsibilityType');
            } 

            if(contactRecord.Account_Industry__c != null && contactFields.contains('Account_Industry__c')){
                gen.writeStringField('accountIndustry', contactRecord.Account_Industry__c);
            }else if(contactRecord.Account_Industry__c == null && contactFields.contains('Account_Industry__c')){
                gen.writeNullField('accountIndustry');
            } 

            if(contactRecord.OtherPhone != null && contactFields.contains('OtherPhone')){
                gen.writeStringField('otherPhone', contactRecord.OtherPhone);
            }else if(contactRecord.OtherPhone == null && contactFields.contains('OtherPhone')){
                gen.writeNullField('otherPhone');
            }

            if(contactRecord.Other_Email__c != null && contactFields.contains('Other_Email__c')){
                gen.writeStringField('otherEmail', contactRecord.Other_Email__c);
            }else if(contactRecord.Other_Email__c == null && contactFields.contains('Other_Email__c')){
                gen.writeNullField('otherEmail');
            }

            if(contactRecord.PrimaryEmailFlag__c != null && contactFields.contains('PrimaryEmailFlag__c')){
                gen.writeBooleanField('primaryEmailFlag', contactRecord.PrimaryEmailFlag__c);
            }else if(contactRecord.PrimaryEmailFlag__c == null && contactFields.contains('PrimaryEmailFlag__c')){
                gen.writeNullField('primaryEmailFlag');
            } 

            if(contactRecord.EmailID__c != null && contactFields.contains('EmailID__c')){
                gen.writeStringField('emailId', contactRecord.EmailID__c);
            }else if(contactRecord.EmailID__c == null && contactFields.contains('EmailID__c')){
                gen.writeNullField('emailId');
            } 

            if(contactRecord.Date_Verified__c != null && contactFields.contains('Date_Verified__c')){
                gen.writeDateTimeField('dateVerified', contactRecord.Date_Verified__c);
            }else if(contactRecord.Date_Verified__c == null && contactFields.contains('Date_Verified__c')) {
                gen.writeNullField('dateVerified');
            }

            if(contactRecord.FaxID__c != null && contactFields.contains('FaxID__c')){
                gen.writeStringField('faxId', contactRecord.FaxID__c);
            }else if(contactRecord.FaxID__c == null && contactFields.contains('FaxID__c')){
                gen.writeNullField('faxId');
            } 

            if(contactRecord.Verified__c != null && contactFields.contains('Verified__c')){
                gen.writeBooleanField('verified', contactRecord.Verified__c);
            }else if(contactRecord.Verified__c == null && contactFields.contains('Verified__c')){
                gen.writeNullField('verified');
            }

            if(contactRecord.MiddleName != null && contactFields.contains('MiddleName')){
                gen.writeStringField('middlesName', contactRecord.MiddleName);
            }else if(contactRecord.MiddleName == null && contactFields.contains('MiddleName')){
                gen.writeNullField('middlesName');
            } 

            if(contactRecord.PrimaryFaxFlag__c != null && contactFields.contains('PrimaryFaxFlag__c')){
                gen.writeBooleanField('primaryFaxFlag', contactRecord.PrimaryFaxFlag__c);
            }else if(contactRecord.PrimaryFaxFlag__c == null && contactFields.contains('PrimaryFaxFlag__c')){
                gen.writeNullField('primaryFaxFlag');
            } 

            gen.writeFieldName('ShippingAddressArray');
            gen.writeStartArray();
            gen.writeStartObject();
            
            if(contactRecord.MailingPostalCode != null && contactFields.contains('MailingPostalCode')){
                gen.writeStringField('mailingPostalCode', contactRecord.MailingPostalCode);
            }else if(contactRecord.MailingPostalCode == null && contactFields.contains('MailingPostalCode')){
                gen.writeNullField('mailingPostalCode');
            }
            
            if(contactRecord.MailingCity != null  && contactFields.contains('MailingCity')){
                gen.writeStringField('mailingCity', contactRecord.MailingCity);
            }else if(contactRecord.MailingCity == null  && contactFields.contains('MailingCity')){
                gen.writeNullField('mailingCity');
            }
            
            if(contactRecord.MailingCountry != null && contactFields.contains('MailingCountry')){
                gen.writeStringField('mailingCountry', contactRecord.MailingCountry);
            }else if(contactRecord.MailingCountry == null && contactFields.contains('MailingCountry')){
                gen.writeNullField('mailingCountry');
            }
            
            if(contactRecord.MailingState != null && contactFields.contains('MailingState')){
                gen.writeStringField('mailingState', contactRecord.MailingState);
            }else if(contactRecord.MailingState == null && contactFields.contains('MailingState')){
                gen.writeNullField('mailingState');
            }
            
            if(contactRecord.MailingStreet != null && contactFields.contains('MailingStreet')){
                gen.writeStringField('mailingStreet', contactRecord.MailingStreet);
            }else if(contactRecord.MailingStreet == null && contactFields.contains('MailingStreet')){
                gen.writeNullField('mailingStreet');
            }
            
            gen.writeEndObject();
            gen.writeEndArray();
            
            if(contactRecord.Other_Email_ID__c != null && contactFields.contains('Other_Email_ID__c')){
                gen.writeStringField('otherEmailId', contactRecord.Other_Email_ID__c);
            }else if(contactRecord.Other_Email_ID__c == null && contactFields.contains('Other_Email_ID__c')){
                gen.writeNullField('otherEmailId');
            }
            
            if(contactRecord.LastName != null && contactFields.contains('LastName')){
                gen.writeStringField('lastName', contactRecord.LastName); 
            }else if(contactRecord.LastName == null && contactFields.contains('LastName')){
                gen.writeNullField('lastName');
            }
            
            if(contactRecord.Fax != null && contactFields.contains('Fax')){
                gen.writeStringField('fax', contactRecord.Fax);
            }else if(contactRecord.Fax == null && contactFields.contains('Fax')){
                gen.writeNullField('fax');
            }
            
            if(contactRecord.PrimaryOtherPhoneFlag__c != null && contactFields.contains('PrimaryOtherPhoneFlag__c')){
                gen.writeBooleanField('primaryOtherPhoneFlag', contactRecord.PrimaryOtherPhoneFlag__c);
            }else if(contactRecord.PrimaryOtherPhoneFlag__c == null && contactFields.contains('PrimaryOtherPhoneFlag__c')){
                gen.writeNullField('primaryOtherPhoneFlag');
            }
            
            if(contactRecord.Account_Number__c != null && contactFields.contains('Account_Number__c')){
                gen.writeStringField('accountNo', contactRecord.Account_Number__c);
            }else if(contactRecord.Account_Number__c == null && contactFields.contains('Account_Number__c')){
                gen.writeNullField('accountNo');
            }
            
            if(contactRecord.Address_Type__c != null && contactFields.contains('Address_Type__c')){
                gen.writeStringField('addressType', contactRecord.Address_Type__c);
            }else if(contactRecord.Address_Type__c == null && contactFields.contains('Address_Type__c')){
                gen.writeNullField('addressType');
            }
            
            if(contactRecord.Id != null && contactFields.contains('Id')){
                gen.writeStringField('salesforceId', contactRecord.Id);
            }else if(contactRecord.Id == null && contactFields.contains('Id')){
                gen.writeNullField('salesforceId');
            }
            
            if(contactRecord.Clean_Phone_Number__c != null && contactFields.contains('Clean_Phone_Number__c')){
                gen.writeStringField('cleanPhoneNumber', contactRecord.Clean_Phone_Number__c);
            }else if(contactRecord.Clean_Phone_Number__c == null && contactFields.contains('Clean_Phone_Number__c')){
                gen.writeNullField('cleanPhoneNumber');
            }
            /**--------------------------------------------------- */
            if(contactRecord.Contact_ID__c != null && contactFields.contains('Contact_ID__c')){
                gen.writeStringField('EBSContactId', contactRecord.Contact_ID__c);
            }else if(contactRecord.Contact_ID__c == null && contactFields.contains('Contact_ID__c')){
                gen.writeNullField('EBSContactId');
            }
            
            if(contactRecord.CreatedById != null && contactFields.contains('CreatedById')){
                gen.writeStringField('createdBy', contactRecord.CreatedById);
            }else if(contactRecord.CreatedById == null && contactFields.contains('CreatedById')){
                gen.writeNullField('createdBy');
            }

            if(contactRecord.Merged_Contact_ID__c != null && contactFields.contains('Merged_Contact_ID__c')){
                gen.writeStringField('mergeToId', contactRecord.Merged_Contact_ID__c);
            }else if(contactRecord.Merged_Contact_ID__c == null && contactFields.contains('Merged_Contact_ID__c')){
                gen.writeNullField('mergeToId');
            }
            
            if(contactRecord.Email != null && contactFields.contains('Email')){
                gen.writeStringField('email', contactRecord.Email);
            }else if(contactRecord.Email == null && contactFields.contains('Email')){
                gen.writeNullField('email');
            }
            
            if(contactRecord.LastModifiedById != null && contactFields.contains('LastModifiedById')){
                gen.writeStringField('lastModifiedBy', contactRecord.LastModifiedById);
            }else if(contactRecord.LastModifiedById == null && contactFields.contains('LastModifiedById')){
                gen.writeNullField('lastModifiedBy');
            }
            
            
            if(contactRecord.Contact_Type__c != null && contactFields.contains('Contact_Type__c')){
                gen.writeStringField('contactType', contactRecord.Contact_Type__c);
            }else if(contactRecord.Contact_Type__c == null && contactFields.contains('Contact_Type__c')){
                gen.writeNullField('contactType');
            }
            
            
            if(contactRecord.Contact_Account_Status__c != null  && contactFields.contains('Contact_Account_Status__c')){
                gen.writeStringField('contactAccountStatus', contactRecord.Contact_Account_Status__c);
            }else if(contactRecord.Contact_Account_Status__c == null  && contactFields.contains('Contact_Account_Status__c')){
                gen.writeNullField('contactAccountStatus');
            }

            /**------------------------------------------------------------------ */
            if(contactRecord.IsDeleted != null && contactFields.contains('Contact_Account_Status__c')){
                gen.writeBooleanField('isDeletedInSf', contactRecord.IsDeleted);  
            }else if(contactRecord.IsDeleted == null && contactFields.contains('Contact_Account_Status__c')){
                gen.writeNullField('isDeletedInSf');
            }
            
            if(contactRecord.MobilePhone != null && contactFields.contains('MobilePhone')){
                gen.writeStringField('mobile', contactRecord.MobilePhone);
            }else if(contactRecord.MobilePhone == null && contactFields.contains('MobilePhone')){
                gen.writeNullField('mobile');
            }
            
            if(contactRecord.Territory__c != null && contactFields.contains('Territory__c')){
                gen.writeStringField('territory', contactRecord.Territory__c);
            }else if(contactRecord.Territory__c == null && contactFields.contains('Territory__c')){
                gen.writeNullField('territory');
            }
            
            if(contactRecord.Address_Status__c != null && contactFields.contains('Address_Status__c')){
                gen.writeStringField('addressStatus', contactRecord.Address_Status__c);
            }else if(contactRecord.Address_Status__c == null && contactFields.contains('Address_Status__c')){
                gen.writeNullField('addressStatus');
            }
            
            if(contactRecord.RecordTypeId != null && contactFields.contains('RecordTypeId')){
                gen.writeStringField('contactRecordType', contactRecord.RecordTypeId);
            }else if(contactRecord.RecordTypeId == null && contactFields.contains('RecordTypeId')){
                gen.writeNullField('contactRecordType');
            } 
            
            setDateTime(gen,'ODSLastModifiedDate',contactRecord.LastModifiedDate );

            
            if(contactRecord.Source_ID__c != null && contactFields.contains('Source_ID__c')){
                gen.writeStringField('sourceId', contactRecord.Source_ID__c);
            }else if(contactRecord.Source_ID__c == null && contactFields.contains('Source_ID__c')){
                gen.writeNullField('sourceId');
            }
            
            if(contactRecord.Title != null && contactFields.contains('Title')){
                gen.writeStringField('title', contactRecord.Title);
            }else if(contactRecord.Title == null && contactFields.contains('Title')){
                gen.writeNullField('title');
            }
            
            if(contactRecord.OwnerId != null && contactFields.contains('OwnerId')){
                gen.writeStringField('contactOwner', contactRecord.OwnerId);
            }else if(contactRecord.OwnerId == null && contactFields.contains('OwnerId')){
                gen.writeNullField('contactOwner');
            }
             
            setDateTime(gen,'createdAt',contactRecord.CreatedDate );
            
            if(contactRecord.OtherPhoneID__c != null && contactFields.contains('OtherPhoneID__c')){
                gen.writeStringField('otherPhoneId', contactRecord.OtherPhoneID__c);
            }else if(contactRecord.OtherPhoneID__c == null && contactFields.contains('OtherPhoneID__c')){
                gen.writeNullField('otherPhoneId');
            }
            
            if(contactRecord.PhoneID__c != null && contactFields.contains('PhoneID__c')){
                gen.writeStringField('phoneId', contactRecord.PhoneID__c);
            }else if(contactRecord.PhoneID__c == null && contactFields.contains('PhoneID__c')){
                gen.writeNullField('phoneId');
            }
            
            if(contactRecord.HasOptedOutOfEmail != null && contactFields.contains('HasOptedOutOfEmail')){
                gen.writeBooleanField('emailOptOut', contactRecord.HasOptedOutOfEmail);
            }else if(contactRecord.HasOptedOutOfEmail == null && contactFields.contains('HasOptedOutOfEmail')){
                gen.writeNullField('emailOptOut');
            }
            
            if(contactRecord.FirstName != null && contactFields.contains('FirstName')){
                gen.writeStringField('firstName', contactRecord.FirstName); 
            }else if(contactRecord.FirstName == null && contactFields.contains('FirstName')){
                gen.writeNullField('firstName');
            }
            
            if(contactRecord.Do_Not_Mail__c != null && contactFields.contains('Do_Not_Mail__c')){
                gen.writeBooleanField('doNotMail', contactRecord.Do_Not_Mail__c);
            }else if(contactRecord.Do_Not_Mail__c == null && contactFields.contains('Do_Not_Mail__c')){
                gen.writeNullField('doNotMail');
            }
            
            if(contactRecord.Suffix != null && contactFields.contains('Suffix')){
                gen.writeStringField('suffix', contactRecord.Suffix); 
            }else if(contactRecord.Suffix == null && contactFields.contains('Suffix')){
                gen.writeNullField('suffix'); 
            }
            
            if(contactRecord.AccountId != null && contactFields.contains('AccountId')){
                gen.writeStringField('accountName', contactRecord.AccountId); 
            }else if(contactRecord.AccountId == null && contactFields.contains('AccountId')){
                gen.writeNullField('accountName');
            }
            
            if(contactRecord.PrimaryPhoneFlag__c != null && contactFields.contains('PrimaryPhoneFlag__c')){
                gen.writeBooleanField('primaryPhoneFlag', contactRecord.PrimaryPhoneFlag__c);
            }else if(contactRecord.PrimaryPhoneFlag__c == null && contactFields.contains('PrimaryPhoneFlag__c')){
                gen.writeNullField('primaryPhoneFlag');
            }
            
            if(contactRecord.Source__c != null && contactFields.contains('Source__c')){
                gen.writeStringField('source', contactRecord.Source__c);
            }else if(contactRecord.Source__c == null && contactFields.contains('Source__c')){
                gen.writeNullField('source');
            }
            
            if(contactRecord.Contact_Status__c != null && contactFields.contains('Contact_Status__c')){
                gen.writeStringField('contactStatus', contactRecord.Contact_Status__c);
            }else if(contactRecord.Contact_Status__c == null && contactFields.contains('Contact_Status__c')){
                gen.writeNullField('contactStatus');
            }
            
            if(contactRecord.LastModifiedDate != null && contactFields.contains('LastModifiedDate')){
                gen.writeDateTimeField('lastModifiedDate', contactRecord.LastModifiedDate);
            }else if(contactRecord.LastModifiedDate == null && contactFields.contains('LastModifiedDate')){
                gen.writeNullField('lastModifiedDate');
            }
            
            if(contactRecord.Salutation != null && contactFields.contains('Salutation')){
                gen.writeStringField('salutation', contactRecord.Salutation);
            }else if(contactRecord.Salutation == null && contactFields.contains('Salutation')){
                gen.writeNullField('salutation');
            }
            gen.writeEndObject();
            gen.writeEndObject();            
            gen.writeBooleanField('upsert', false); 
            gen.writeEndObject(); 
        } 

        
       System.debug('======= Update JSON ======='+ gen.getAsString());
        return gen.getAsString();
    }  

    private static JSONGenerator setDateTime(JSONGenerator gen, String jsonKey, DateTime jsonValue){

        if(jsonValue != null){  
            gen.writeFieldName(jsonKey);
            gen.writeStartObject();
            gen.writeFieldName('$date');
            gen.writeStartObject();
            gen.writeStringField('$numberLong', String.valueOf(jsonValue.getTime()));
            gen.writeEndObject();
            gen.writeEndObject();
        }else{
            gen.writeNullField(jsonKey);
        }  
        return gen;
    } 

    
}