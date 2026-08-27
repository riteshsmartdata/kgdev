/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 04-05-2024
* @last modified by  : ritesh.kumar@kooziegroup.com
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   03-15-2024   Ritesh Kumar   Initial Version
**/
public class EBSContactResponseJSON {
    final Static String SUCCESS = 'SUCCESS';
    final Static String EMAIL = 'EMAIL';
    final Static String PHONE = 'PHONE';
    final Static String FAX = 'FAX';
    
    public static Boolean parseJSONString(String jsonString, String recordId) {
        Boolean exceptionFlag = TRUE;
        EBSContactResponse contactData = EBSContactResponse.parse(jsonString); 
        Boolean isDML = FALSE;
        Contact record = [
            SELECT 
                Id, Email, Other_Email__c, EmailID__c, Other_Email_ID__c, Fax,
                Phone, OtherPhone, OtherPhoneID__c, PhoneID__c, Address1_ID__c, Contact_ID__c,
                FaxID__c  
            FROM 
            Contact 
            WHERE 
            Id = :recordID
        ];
        
        if(contactData.EventResponse.EventStatus == SUCCESS){
            
            for(EBSContactResponse.CustomerContact data : contactData.EventResponse.CustomerContacts.CustomerContact){
                System.debug(LoggingLevel.INFO,'===== EBSContactResponseJSON : parseJSONString:  ====='+data); 
                if(String.isBlank(record.Contact_Id__c)){
                    record.Contact_ID__c = data.ContactID;
                    isDML = TRUE;
                }
                
                for(EBSContactResponse.ContactAddresses address : data.ContactAddress.ContactAddresses){
                    if(String.isBlank(record.Address1_ID__c)){
                        record.Address1_ID__c = address.AddressID;
                        isDML = TRUE;
                    }
                }
                
                for(EBSContactResponse.CommunicationArray communication : data.Communications.CommunicationArray){
                    if(String.isBlank(record.EmailID__c) && communication.CommunicationMethod == EMAIL ){
                        if (record.Email == communication.CommunicationInfo) {
                            record.EmailID__c = communication.CommunicationID;
                            isDML = TRUE;
                        }
                        
                    }

                    if(String.isBlank(record.Other_Email_ID__c) && communication.CommunicationMethod == EMAIL ){
                        if (record.Other_Email__c == communication.CommunicationInfo) {
                            record.Other_Email_ID__c = communication.CommunicationID;
                            isDML = TRUE; 
                        }
                       
                    }
                    
                    if(String.isBlank(record.PhoneID__c) && communication.CommunicationMethod == PHONE ){

                        if (record.Phone == communication.CommunicationInfo) {
                            record.PhoneID__c = communication.CommunicationID;
                            isDML = TRUE;
                        }
                        
                    }

                    if(String.isBlank(record.OtherPhoneID__c) && communication.CommunicationMethod == PHONE ){
                        if (record.OtherPhone == communication.CommunicationInfo) {
                            record.OtherPhoneID__c = communication.CommunicationID;
                            isDML = TRUE;
                        } 
                    }
                    
                    if(String.isBlank(record.FaxID__c) && communication.CommunicationMethod == FAX ){
                        record.FaxID__c = communication.CommunicationID;
                        isDML = TRUE;
                    }
                }
                
            } 
            
            if(isDML){
            	Update record;
                exceptionFlag = FALSE;
            } 
            
            System.debug(LoggingLevel.INFO,'===== EBSContactResponseJSON : record:  ====='+record); 
        } 
        
        return exceptionFlag;
    }
}