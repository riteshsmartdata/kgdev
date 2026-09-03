/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   04-28-2023   Ritesh Kumar   Initial Version
**/
public class ContactSyncWithOdsBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful,Schedulable{

    public Database.QueryLocator start(Database.BatchableContext BC){

        DateTime todaysDataTime = System.now();
        DateTime beforeOneHour = System.now().addMinutes(-32);
        String recordType = 'CRM Contact';
        String contactSOQL = '';
         
        contactSOQL += 'SELECT Id, Phone, PromoStandards_Contact__c, PrimaryOtherEmailFlag__c, Top_Producer__c, Responsibility_Type__c, Account_Industry__c, OtherPhone, Other_Email__c,';

        contactSOQL += 'PrimaryEmailFlag__c, EmailID__c, Date_Verified__c, FaxID__c, Verified__c, MiddleName, PrimaryFaxFlag__c, MailingPostalCode, MailingCity, MailingCountry, ';
        contactSOQL += 'MailingState, MailingStreet, Other_Email_ID__c, LastName, Fax, PrimaryOtherPhoneFlag__c, Account_Number__c, Address_Type__c, Contact_ID__c, CreatedById, ';
        contactSOQL += 'Email, LastModifiedById, Contact_Type__c, Contact_Account_Status__c, IsDeleted, MobilePhone, Territory__c, Address_Status__c, RecordTypeId,LastModifiedDate, ';
        contactSOQL += 'Source_ID__c, Title, OwnerId, CreatedDate, OtherPhoneID__c, PhoneID__c, HasOptedOutOfEmail, FirstName, Do_Not_Mail__c, Suffix, AccountId, PrimaryPhoneFlag__c,Is_Sales_Contact__c, ';
        contactSOQL += 'Source__c, Contact_Status__c, Salutation, Clean_Phone_Number__c FROM Contact WHERE  RecordType.Name =: recordType AND LastModifiedDate <=: todaysDataTime AND LastModifiedDate >=: beforeOneHour';
       //contactSOQL += 'Source__c, Contact_Status__c, Salutation, Clean_Phone_Number__c FROM Contact  LIMIT 1';
         
        return Database.getQueryLocator(contactSOQL);
    }

    public void execute(Database.BatchableContext BC, List<Contact> contactList){

        /**
         * List hold the apex error log.
         */
        List<Apex_Errors__c> ErrorsList = new List<Apex_Errors__c>();

        /**
         * Get API key and End point from custom metadata
         */
       // Contact_And_Contact_Role_Settings__mdt accessDeatils = new Contact_And_Contact_Role_Settings__mdt();
       Contact_And_Contact_Role_Settings__mdt accessDeatils = Contact_And_Contact_Role_Settings__mdt.getInstance(KoozieUtility.isSandbox() ? 'Send_Contact_Information_Full_Sandbox' : 'Send_Contact_Information');
        
        accessDeatils =  ContactSyncWithOds.getAccessKey();

        if(!contactList.isEmpty()){
            for(Contact record : contactList){
                Apex_Errors__c temp = new Apex_Errors__c();

                /**
                 * Generate contact JSON and store in requestJSON variable
                 */
                String requestJSON = ContactOdsJson.replaceOneJSON(record); 
                
                if(accessDeatils != null){
                     /**
                     * Making ODS Callout
                     */
                    temp = odsContactCallout(requestJSON, record.Id,accessDeatils );
                }

                if(temp!= null ){
                    ErrorsList.add(temp);
                }
            }
            
            /**
             * Insert apex error if any
             */
            if(! ErrorsList.isEmpty()){
                Database.insert(ErrorsList, false);
            }
           
        }  
    }
    
    public void finish(Database.BatchableContext BC){  
    }

    /**
     * Method is used to make API Callout to ODS and return apex error if any.
     */ 
    private static Apex_Errors__c odsContactCallout(String requestBody, String recordId, Contact_And_Contact_Role_Settings__mdt accessInformation){
        Apex_Errors__c errorRecord  = new Apex_Errors__c();
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
        if(!successStatuCode.contains(response.getStatusCode())){ 

            /**
             * ADD apex erro into errorRecord
             */
            errorRecord = ApexLogUtill.assignApexLog('ODS : Contact Sync With ODS', requestBody, response.toString(), recordId, 'Contact', response.toString(), response.getStatusCode());
 
        }

        return errorRecord;
    }

    public void execute(SchedulableContext sc) {
        ContactSyncWithOdsBatch bth = new ContactSyncWithOdsBatch();
        Database.executeBatch(bth, 5);
    }
   
}