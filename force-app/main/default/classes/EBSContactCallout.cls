/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-13-2024   Ritesh Kumar   Initial Version
**/
public without sharing class EBSContactCallout {

    @future (callout= true)
    public static void sendContactData(String recordId, String eventType) {
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: recordId ====='+recordId);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: eventType ====='+eventType);

        String requestJSON = EBSContactRequest.contactRequest(recordId,eventType);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: requestJSON ====='+requestJSON);
        Http http=new Http();
        HttpRequest request=new HttpRequest();          

        //Get environment details from custom settings 
        
        AppInfo__c ebsAPP = new AppInfo__c();
        if(KoozieUtility.isSandbox()){
           ebsAPP = AppInfo__c.getValues('Sandbox');
           System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: Sandbox ====='+ebsAPP);
            
        }else{
           ebsAPP = AppInfo__c.getValues('WebClient');
           System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: WebClient ====='+ebsAPP);
        }
         
        //Get user details from custom settings
        string username = ebsAPP.user__c;
        string password = ebsAPP.password__c;
        string endpoint = ebsAPP.endpoint__c;     
        
        
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: username ====='+username);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: password ====='+password);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: endpoint ====='+endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        Blob headerValue = Blob.valueOf(username + ':' + password);        
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: headerValue ====='+headerValue.toString());
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestJSON);
        request.setTimeout(120000);
        
        HttpResponse response = http.send(request);
		System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: requestJSON ====='+requestJSON);
        System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: getStatusCode ====='+response.getStatusCode());
        if(response.getStatusCode() == 201 || response.getStatusCode() == 200){
            System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: response body ====='+response.getBody());
            Boolean exceptionFlag = EBSContactResponseJSON.parseJSONString(response.getBody(), recordID);
            
            if(exceptionFlag){
                ApexLogUtill.createApexLog('EBSContactCallout', requestJSON, response.getBody(), recordID,'Contact', 'Check in JSON', response.getStatusCode());
            } 
        }else{
            
            System.debug(LoggingLevel.INFO,'===== EBSContactCallout : sendContactData: response body ====='+response.getBody());
             ApexLogUtill.createApexLog('EBSContactCallout', requestJSON, response.getBody(), recordID,'Contact', '', response.getStatusCode());
        } 
    }
}