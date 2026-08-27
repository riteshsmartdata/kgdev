/**
 * @description       : SF-354 : Manual sync for contacts with ODS
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 05-02-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   04-26-2023   Ritesh Kumar   Initial Version
**/
public without sharing class ContactSyncWithOds {

    // class to throw custom Exception.
    public virtual class APIException extends Exception{}

    // list to hold api exception records.
    private static List<Apex_Errors__c> logList;

	//constructor
    public ContactSyncWithOds(){
        logList = new List<Apex_Errors__c>();
    } 
    
    
    @InvocableMethod(label='Send Contact Information to ODS System' description='Share contact information on a click of button' category ='API Callout')
    public static void odsCallout(List<Contact> contactList){
        /**
         * Get API key and End point from custom metadata type
         */
        Contact_And_Contact_Role_Settings__mdt accessDeatils = new Contact_And_Contact_Role_Settings__mdt();
        //Separate method to fetch mdt details
        accessDeatils =  getAccessKey(); 

        /**
         * flag to Identify error and success 
         */
        Boolean isException = false;
        
        if(!contactList.isEmpty()){
            for(Contact record : contactList){
                /**
                 * Generate contact JSON and store in requestJSON variable
                 */
                String requestJSON = ContactOdsJson.replaceOneJSON(record); 
                
                if(accessDeatils != null){
                    /**
                     * Making ODS Callout
                     */
                    isException =   odsContactCallout(requestJSON, record.Id,accessDeatils );
                }
            } 
            if(isException){

                /**
                 * Insert apex error if any
                 */

                if(!logList.isEmpty()){
                    Database.insert(logList, false);
                }
                /**
                 * throw exception if we get API error
                 */
                throw new APIException('OSD Sync Error. Please check apex log for more information.');
            }
        }
    }
    /**
     * Method is used to make API Callout to ODS
     */
    private static Boolean odsContactCallout(String requestBody, String recordId, Contact_And_Contact_Role_Settings__mdt accessInformation){

        Boolean isException = false;
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
         
        HttpResponse response = http.send(request); 
        /**
         * Check HTTP Status
         */
        System.debug('====endpoint ====='+endpoint);
        System.debug('====endpointaccessInformation.API_Key__c ====='+accessInformation.API_Key__c);
        System.debug('====requestBody ====='+requestBody);
        System.debug('====response.getStatusCode() ====='+response.getStatusCode());
        System.debug('==== response.getBody()====='+ response.getBody());
        if(!successStatuCode.contains(response.getStatusCode())){ 

            /**
             * ADD apex erro intp log list
             */
            logList.add(ApexLogUtill.assignApexLog('ODS : Contact Sync With ODS', requestBody, response.getBody(), recordId, 'Contact', response.toString(), response.getStatusCode()));
 
            isException = true;
            
        }

        return isException;
    }

    /**
     * Method is used to get API and Endpoint infromation from metadata.
     */
    
    public static Contact_And_Contact_Role_Settings__mdt getAccessKey(){

        Contact_And_Contact_Role_Settings__mdt accessInformation = new Contact_And_Contact_Role_Settings__mdt();
        accessInformation = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Information');

        return accessInformation != null ? accessInformation : null;
    }
     
}