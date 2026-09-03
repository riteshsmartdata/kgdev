/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-27-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-27-2023   Ritesh Kumar   Initial Version
**/
public without sharing class OneTimeContactSync implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

    public Database.QueryLocator start(Database.BatchableContext bc){
        String contactSOQL = '';
        String recordType = 'CRM Contact';  
        
        contactSOQL += 'SELECT Id, Phone, PromoStandards_Contact__c, PrimaryOtherEmailFlag__c, Top_Producer__c, Responsibility_Type__c, Account_Industry__c, OtherPhone, Other_Email__c,';
        contactSOQL += 'PrimaryEmailFlag__c, EmailID__c, Date_Verified__c, FaxID__c, Verified__c, MiddleName, PrimaryFaxFlag__c, MailingPostalCode, MailingCity, MailingCountry, ';
        contactSOQL += 'MailingState, MailingStreet, Other_Email_ID__c, LastName, Fax, PrimaryOtherPhoneFlag__c, Account_Number__c, Address_Type__c, Contact_ID__c, CreatedById, ';
        contactSOQL += 'Email, LastModifiedById, Contact_Type__c, Contact_Account_Status__c, IsDeleted, MobilePhone, Territory__c, Address_Status__c, RecordTypeId,LastModifiedDate, ';
        contactSOQL += 'Source_ID__c, Title, OwnerId, CreatedDate, OtherPhoneID__c, PhoneID__c, HasOptedOutOfEmail, FirstName, Do_Not_Mail__c, Suffix, AccountId, PrimaryPhoneFlag__c, ODS_Contact_Sync_Date__c, ';
        contactSOQL += 'Source__c, Contact_Status__c, Salutation, Clean_Phone_Number__c FROM Contact WHERE  RecordType.Name =: recordType AND ODS_Contact_Sync_Date__c = null';
        
        return Database.getQueryLocator(contactSOQL);
    }

    public void execute(Database.BatchableContext bc, List<Contact> contactList){

        /**
         * List hold the apex error log.
         */
        List<Apex_Errors__c> errorsList = new List<Apex_Errors__c>();
        List<Contact> syncContactList = new List<Contact>();

        /**
         * Get API key and End point from custom metadata
         */
        Contact_And_Contact_Role_Settings__mdt accessDeatils = new Contact_And_Contact_Role_Settings__mdt();
        accessDeatils =  ContactSyncWithOds.getAccessKey();

        if(!contactList.isEmpty()){
            for(Contact record : contactList){
                Apex_Errors__c apiError;

                /**
                 * Generate contact JSON and store in requestJSON variable
                 */
                String requestJSON = ContactOdsJson.replaceOneJSON(record); 
                
                if(accessDeatils != null){
                    /**
                     * Making ODS Callout
                     */
                    apiError = odsContactCallout(requestJSON, record.Id,accessDeatils );
                }

                System.debug('===== Erorr ====='+apiError);

                if(apiError != NULL ){
                    System.debug('===== Erorr =====');
                    errorsList.add(apiError);
                }else{
                    System.debug('===== Success =====');
                    Contact updateRecord = new Contact();
                    updateRecord.Id = record.Id;
                    updateRecord.ODS_Contact_Sync_Date__c = System.today();
                    syncContactList.add(updateRecord);
                }
            }
            
            /**
             * Insert apex error if any
             */
            System.debug('===== ErrorsList ====='+ErrorsList);
            if(! ErrorsList.isEmpty()){
                Database.insert(ErrorsList, false);
            }

            System.debug('===== syncContactList ====='+syncContactList);
            if(!syncContactList.isEmpty()){
                Database.Update(syncContactList, false);
            }
        }  
    }
    
    public void finish(Database.BatchableContext bc){ 
        //code here 
        System.debug('=========='+bc);
    }

    /**
     * Method is used to make API Callout to ODS and return apex error if any.
     */ 
    private static Apex_Errors__c odsContactCallout(String requestBody, String recordId, Contact_And_Contact_Role_Settings__mdt accessInformation){
        Apex_Errors__c errorRecord;
        String endpoint = accessInformation.End_Point__c;

        /**
         * Set to hold success status Code.
         */
        Set<Integer> successStatuCode = new Set<Integer>();
        successStatuCode.add(200);
        successStatuCode.add(201);
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        /**
         * Update endpoint with upsert api (replaceOne : is use to perform Upsert in ODS)
         */
        endpoint += 'action/replaceOne'; 
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('api-key', accessInformation.API_Key__c);   
        request.setBody(requestBody);
        request.setTimeout(120000);
        
        /**
        * Check HTTP Status
        */
        HttpResponse response = http.send(request); 
        System.debug('===== HTTP Response Code ====='+response.getStatusCode());
        System.debug('===== HTTP request Body ====='+ requestBody);
        System.debug('===== HTTP Response Body ====='+ response.toString());
        System.debug('===== HTTP Response Body ====='+ response.getBody());
        if(!successStatuCode.contains(response.getStatusCode())){ 

            /**
             * ADD apex erro into errorRecord
             */
            errorRecord = ApexLogUtill.assignApexLog('ODS :One Time Contact Sync', requestBody, response.getBody(), recordId, 'Contact', response.getBody(), response.getStatusCode());
        }

        return errorRecord;
    }
    
}