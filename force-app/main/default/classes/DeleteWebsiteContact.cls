/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-19-2023   Ritesh Kumar   JIRA SF-884
**/
public without sharing class DeleteWebsiteContact {
    public static String generateJSON(String contactId){
        Contact contactRecord = new Contact();
        Contact [] contactArray = [
            SELECT id, Account_Number__c, FirstName, LastName, Contact_Type__c, Email, IsDeleted,
                Web_Id__c, CreatedDate
            FROM Contact
            WHERE Id=: contactId AND IsDeleted = TRUE ALL ROWS 
        ];
 
        if(contactArray.size() >0){
            contactRecord = contactArray[0];
        }
        // Create a JSONGenerator instance
        JSONGenerator gen = JSON.createGenerator(true);
        // Start the JSON object
        gen.writeStartObject();
        gen.writeFieldName('EventRequest');
        gen.writeStartObject();
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('EventBusinessID',contactRecord.Email);  
        }
        gen.writeStringField('EventObject', 'CUSTOMER');
        gen.writeStringField('EventSourceSystem', 'Salesforce');
        gen.writeStringField('EventType', 'DELETE');
        gen.writeFieldName('CustomerData');
        gen.writeStartObject();
 
        if(String.isNotBlank(contactRecord.Id)){
            gen.writeStringField('Sf_Id', contactRecord.Id);
        }else{
            gen.writeNullField('Sf_Id');
        }
 
        if(String.isNotBlank(contactRecord.Web_Id__c)){
            gen.writeStringField('Web_Id', contactRecord.Web_Id__c);
        }else{
            gen.writeNullField('Web_Id');
        } 
        if(String.isNotBlank(contactRecord.Account_Number__c)){
            gen.writeStringField('AccountNumber', contactRecord.Account_Number__c);
        }else{
            gen.writeNullField('AccountNumber');
        }
 
        if(String.isNotBlank(contactRecord.Email)){
            gen.writeStringField('EmailId', contactRecord.Email);
        }else{
            gen.writeNullField('EmailId');
        }
 
        gen.writeEndObject();
        gen.writeEndObject();
        // End of the main JSON object
        gen.writeEndObject();
 
        // Get JSON string 
        system.debug('>>'+gen.getAsString());
        return gen.getAsString();
    }
 
    
    public static LogInput sendDeleteContactRequest(String contactId){
        String accessBody = '';
        LogInput errorLog = new LogInput(); 
        Set<Integer> successStatusCode = new Set<Integer>{200, 201};
 
        GrandNode_Setting__mdt grandNodeSetting = KoozieUtility.isSandbox() ? GrandNodeContactSync.getGrandNodeSetting('Contact_Sandbox_Endpoint') : GrandNodeContactSync.getGrandNodeSetting('Grand_Node_Contact_Sync');
 
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        String deleteEndpoint = ''+grandNodeSetting.Website_Delete_API__c;
        request.setEndpoint(deleteEndpoint);  
        request.setmethod(grandNodeSetting.Request_Type__c);
        //Get the token
        String authorization = 'Bearer '+GrandNodeContactSync.getToken(); 
        request.setHeader('content-type', 'application/json');
 
        if(!authorization.contains('Error :') || Test.isRunningTest() ){
            request.setHeader('Authorization', authorization);
            request.setTimeout(120000); 
            accessBody =  DeleteWebsiteContact.generateJSON(contactId); 
            request.setBody(accessBody); 
            HTTPResponse response = http.send(request); 
            if( !successStatusCode.contains(response.getStatusCode())){  
                errorLog.source = 'ODS : Single Contact Delete';
                errorLog.requestBody = accessBody;
                errorLog.resopnseBody =  response.toString();
                errorLog.recordId = ContactId;
                errorLog.objectName = 'Contact';
                errorLog.statusCode = response.getStatusCode(); 
            } 
            System.debug('== Status Code====='+response.getStatusCode());
            System.debug('== Response Body ====='+response.getBody());
        }
        return errorLog;
    }

}