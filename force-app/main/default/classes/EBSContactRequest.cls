/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-29-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-12-2024   Ritesh Kumar   Initial Version
**/
public with sharing class EBSContactRequest {

    final static String SALESFORCE = 'Salesforce';
    final static String EBS = 'EBS';
    final static String CUSTOMER_CONTACT = 'CUSTOMER_CONTACT';
    final static String EVENT_BUSINESS_ID = '1234567890';
    final static String STATUS_ACTIVE ='Active';
    final static String EMPTY = 'EMPTY';
    final static String CREATE_DML = 'CREATE'; 
    final static String EMAIL_COMMUNICATION = 'EMAIL';
    final static String PHONE_COMMUNICATION = 'PHONE';
    final static String FAX_COMMUNICATION = 'FAX';



    public static String contactRequest( String recordId, String eventType){  

        Contact contactData =[
            SELECT Id, FirstName, LastName, MailingStreet, MailingCity, MailingState, 
                MailingPostalCode, MailingCountry, County__c, Email, Phone, OtherPhone, Fax, 
                Responsibility_Type__c, Account.Customer_Account_Number__c, PhoneID__c, 
                FaxID__c, OtherPhoneID__c, EmailID__c, Contact_ID__c, Address1_ID__c,
                Account.RecordType.Name, Contact_Status__c, PrimaryEmailFlag__c, PrimaryFaxFlag__c, 
                PrimaryOtherPhoneFlag__c, PrimaryPhoneFlag__c, Other_Email_ID__c, Other_Email__c, 
                PrimaryOtherEmailFlag__c, Primary_Responsibility_Flag__c,LastModifiedDate,CreatedDate
            FROM Contact
            WHERE Id =: recordId LIMIT 1];
        
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
            gen.writeFieldName('EventRequest');
            gen.writeStartObject();
                gen.writeStringField('EventType', eventType);
                gen.writeStringField('EventSourceSystem', SALESFORCE);
                gen.writeStringField('EventRecordSystem',EBS);
                gen.writeStringField('EventObject', CUSTOMER_CONTACT);
                gen.writeDateTimeField('EventDateTime', system.now());
                gen.writeStringField('EventBusinessID', EVENT_BUSINESS_ID);
                gen.writeFieldName('CustomerContacts');
                gen.writeStartObject();
                    gen.writeFieldName('CustomerContact');
                    gen.writeStartArray();
                        gen.writeStartObject();
                            if(String.isNotBlank(contactData.Responsibility_Type__c)){
                                gen.writeStringField('ResponsibilityType', contactData.Responsibility_Type__c);
                            }else{
                                gen.writeNullField('ResponsibilityType');
                            } 

                            if(String.isNotBlank(contactData.Primary_Responsibility_Flag__c)){
                                gen.writeStringField('PrimaryResponsibilityFlag', contactData.Primary_Responsibility_Flag__c);
                            }else{
                                gen.writeNullField('PrimaryResponsibilityFlag');
                            }
                            
                            gen.writeNullField('PrimaryFlag');
                            gen.writeStringField('ContactStatus', contactData.Contact_Status__c == STATUS_ACTIVE? 'A':'I');
                            gen.writeDateTimeField('ContactLastUpdateDate', contactData.LastModifiedDate);
                            gen.writeStringField('ContactLastName', contactData.LastName);
                            if(String.isNotBlank(contactData.Contact_ID__c)){
                                gen.writeStringField('ContactID', contactData.Contact_ID__c);
                            }else{
                                gen.writeNullField('ContactID');
                            }
                            
                            gen.writeStringField('ContactFirstName', contactData.FirstName);
                            gen.writeDateTimeField('ContactCreateDate', contactData.CreatedDate);
                            gen.writeFieldName('ContactAddress');
                            gen.writeStartObject();
                                gen.writeFieldName('ContactAddresses');
                                    gen.writeStartArray();
                                        gen.writeStartObject();
                                            
        									if(String.isNotBlank(contactData.MailingState)){
                                                gen.writeStringField('State', contactData.MailingState);
                                            }else{
                                                gen.writeNullField('State');
                                            }
        
        									if(String.isNotBlank(contactData.MailingState)){
                                                gen.writeStringField('Province', contactData.MailingState);
                                            }else{
                                                gen.writeNullField('Province');
                                            }
 	
        									if(String.isNotBlank(contactData.MailingPostalCode)){
                                                gen.writeStringField('PostalCode', contactData.MailingPostalCode);
                                            }else{
                                                gen.writeNullField('PostalCode');
                                            }

                                            if(String.isNotBlank(contactData.County__c)){
                                                gen.writeStringField('County', contactData.County__c);
                                            }else{
                                                gen.writeNullField('County');
                                            }
                                            
                                            if(String.isNotBlank(contactData.MailingCountry) && String.isNotBlank(contactData.Address1_ID__c)){
                                                gen.writeStringField('Country',  contactData.MailingCountry);
                                            }else{
                                                gen.writeStringField('Country','NA');
                                            }
        
                                            if(String.isNotBlank(contactData.MailingCity)){
                                                gen.writeStringField('City',  contactData.MailingCity);
                                            }else{
                                                gen.writeNullField('City');
                                            }
                                            
        
                                            gen.writeStringField('AddressLine4', '');
                                            gen.writeStringField('AddressLine3', '');
                                            gen.writeStringField('AddressLine2', '');
                                            if(String.isNotBlank(contactData.MailingStreet) && String.isNotBlank(contactData.Address1_ID__c)){
                                                gen.writeStringField('AddressLine1',  contactData.MailingStreet);
                                            }else{
                                                gen.writeStringField('AddressLine1',EMPTY);
                                            }
                                            
                                            if(String.isNotBlank(contactData.Address1_ID__c)){
                                                gen.writeStringField('AddressID', contactData.Address1_ID__c);
                                            }else{
                                                gen.writeNullField('AddressID');
                                            }
                                            
                                        gen.writeEndObject();
                                    gen.writeEndArray();
                                gen.writeEndObject();

                                gen.writeFieldName('Communications');        
                                gen.writeStartObject();
                                gen.writeFieldName('CommunicationArray');
                                    gen.writeStartArray();
                                        setCommunications(gen,contactData);
                                    gen.writeEndArray();
                                gen.writeEndObject();
                            gen.writeStringField('ActiveFlag', 'A');
                        gen.writeEndObject(); 
                    gen.writeEndArray();
                    gen.writeStringField('CustomerAccountNumber', contactData.Account.Customer_Account_Number__c);
                gen.writeEndObject(); 
            gen.writeEndObject();
        gen.writeEndObject();  
        return gen.getAsString();
    } 


    public static JSONGenerator setCommunications(JSONGenerator gen,  Contact contactData){

        if(String.isNotBlank(contactData.Email)){
            gen.writeStartObject();
                gen.writeStringField('PrimaryFlag', (contactData.PrimaryEmailFlag__c == True ) ? 'true' : 'false');
                gen.writeStringField('CommunicationMethod', EMAIL_COMMUNICATION);
                gen.writeStringField('CommunicationInfo', contactData.Email);
                if(String.isNotBlank(contactData.EmailID__c)){
                    gen.writeStringField('CommunicationID',   contactData.EmailID__c);
                }else{
                    gen.writeNullField('CommunicationID');
                }
                
                gen.writeStringField('ActiveFlag', 'A'); 
            gen.writeEndObject();
        }

        if(String.isNotBlank(contactData.Other_Email__c)){
            gen.writeStartObject();
                gen.writeStringField('PrimaryFlag', (contactData.PrimaryOtherEmailFlag__c == True) ? 'true' : 'false');
                gen.writeStringField('CommunicationMethod', EMAIL_COMMUNICATION);
                gen.writeStringField('CommunicationInfo', contactData.Other_Email__c);
                if(String.isNotBlank(contactData.Other_Email_ID__c)){
                    gen.writeStringField('CommunicationID',   contactData.Other_Email_ID__c);
                }else{
                    gen.writeNullField('CommunicationID');
                }
                
                gen.writeStringField('ActiveFlag', 'A'); 
            gen.writeEndObject();
        }

        if(String.isNotBlank(contactData.Phone)){
            gen.writeStartObject();
                gen.writeStringField('PrimaryFlag', (contactData.PrimaryPhoneFlag__c == True) ? 'true' : 'false');
                gen.writeStringField('CommunicationMethod', PHONE_COMMUNICATION);
                gen.writeStringField('CommunicationInfo', contactData.Phone);
                if(String.isNotBlank(contactData.PhoneID__c)){
                    gen.writeStringField('CommunicationID',   contactData.PhoneID__c);
                }else{
                    gen.writeNullField('CommunicationID');
                }
                
                gen.writeStringField('ActiveFlag', 'A'); 
            gen.writeEndObject();
        }

        if(String.isNotBlank(contactData.OtherPhone)){
            gen.writeStartObject();
                gen.writeStringField('PrimaryFlag', (contactData.PrimaryOtherPhoneFlag__c == True ) ? 'true' : 'false');
                gen.writeStringField('CommunicationMethod', PHONE_COMMUNICATION);
                gen.writeStringField('CommunicationInfo', contactData.OtherPhone);
                if(String.isNotBlank(contactData.OtherPhoneID__c)){
                    gen.writeStringField('CommunicationID',   contactData.OtherPhoneID__c);
                }else{
                    gen.writeNullField('CommunicationID');
                }
                
                gen.writeStringField('ActiveFlag', 'A'); 
            gen.writeEndObject();
        }

        if(String.isNotBlank(contactData.Fax)){
            gen.writeStartObject();
                gen.writeStringField('PrimaryFlag', (contactData.PrimaryFaxFlag__c == True ) ? 'true' : 'false');
                gen.writeStringField('CommunicationMethod', FAX_COMMUNICATION);
                gen.writeStringField('CommunicationInfo', contactData.Fax);
                if(String.isNotBlank(contactData.FaxID__c)){
                    gen.writeStringField('CommunicationID',   contactData.FaxID__c);
                }else{
                    gen.writeNullField('CommunicationID');
                }
                
                gen.writeStringField('ActiveFlag', 'A'); 
            gen.writeEndObject();
        }
                    
        return gen;
    }
}