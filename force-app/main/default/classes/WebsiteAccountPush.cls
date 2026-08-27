/**
* @description       : 
* @author            : ritesh.kumar@kooziegroup.com
* @group             : 
* @last modified on  : 09-27-2024
* @last modified by  : ritesh.kumar@kooziegroup.com
**/
public without sharing class WebsiteAccountPush {
    final static GrandNode_Setting__mdt API_INFO = GrandNode_Setting__mdt.getInstance(KoozieUtility.isSandbox() ? 'Account_Sandbox_Endpoint' : 'Grand_Node_Account_Sync');
    final static String CONTENT_TYPE  = 'application/json';
    final static Set<Integer> SUCCESS_RESPONSE = new Set<Integer>{200,201};
        @future(callout=true)
        public static void sendAccount(String recordId, String eventType ){
            System.debug(LoggingLevel.INFO,'===== sendAccount : API_INFO ====='+API_INFO);
            System.debug(LoggingLevel.INFO,'===== sendAccount : recordId ====='+recordId);
            System.debug(LoggingLevel.INFO,'===== sendAccount : eventType ====='+eventType);
            String authorization = 'Bearer '+getToken();
            System.debug(LoggingLevel.INFO,'===== sendAccount : authorization ====='+authorization);
            if(! authorization.contains('Error :')){
                String accountJson = WebsiteAccountJSON.accountRequest(recordId,eventType).getAsString(); 
                System.debug(LoggingLevel.INFO,'===== sendAccount : API_INFO.Website_API_URL__c ====='+API_INFO.Website_API_URL__c);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(API_INFO.Website_API_URL__c); 
                request.setmethod(API_INFO.Request_Type__c); 
                request.setHeader('content-type', CONTENT_TYPE);
                request.setHeader('Authorization', authorization);
                request.setTimeout(120000);
                System.debug('===== Account JSON ====='+accountJson);
                request.setBody(accountJson);
                HTTPResponse response;
                response = http.send(request);
                if( SUCCESS_RESPONSE.contains(response.getStatusCode())){
                    System.debug(LoggingLevel.INFO,'===== sendAccount : Status Code====='+response.getStatusCode());
                    System.debug(LoggingLevel.INFO,'===== sendAccount : Response body ====='+response.getBody());
                    if(String.isNotBlank(response.getBody())){
                        WebsiteAccountResponse accountRecord = WebsiteAccountResponse.parse(response.getBody()); 
                        if(accountRecord.EventResponse.AccountData != null){
                            if( String.isNotBlank(accountRecord.EventResponse.AccountData.SFId) && String.isNotBlank(accountRecord.EventResponse.AccountData.webId) ){
                                System.debug(LoggingLevel.INFO,'===== sendAccount : SFId ====='+accountRecord.EventResponse.AccountData.SFId);
                                System.debug(LoggingLevel.INFO,'===== sendAccount : webId ====='+accountRecord.EventResponse.AccountData.webId);
                                Update new Account(
                                    Id = accountRecord.EventResponse.AccountData.SFId, 
                                    Web_Id__c = accountRecord.EventResponse.AccountData.webId
                                );
                            }
                        }
                    }                   
                }else{
                    ApexLogUtill.createApexLog('Website', accountJson, (String) response.getbody(), recordId, 'Account', (String)response.getbody(),response.getStatusCode()); 
                }
            }else{
                List<String> logdata = authorization.split(';;'); 
                Integer statusCode = Integer.valueOf(logdata[(logdata.size() -1)].trim());
                ApexLogUtill.createApexLog('Website', logdata[1].trim(), logdata[0].replace('Error : ','').trim(), recordId, 'Account', logdata[0].trim(),statusCode); 
            }
        }
    public static String getToken(){
        String token = '';
        String accessBody = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(API_INFO.Token_URL__c); 
        request.setmethod(API_INFO.Request_Type__c);   
        request.setHeader('content-type', CONTENT_TYPE);
        request.setTimeout(120000);
        accessBody = '{"email":"'+API_INFO.Email__c+'","password":"'+API_INFO.Password__c+'"}'; 
        request.setBody(accessBody);
        System.debug(LoggingLevel.INFO,'===== sendAccount : token URL ====='+API_INFO.Token_URL__c);
        System.debug(LoggingLevel.INFO,'===== sendAccount : accessBody ====='+accessBody);
        HTTPResponse response;
        response = http.send(request);
        if(SUCCESS_RESPONSE.contains(response.getStatusCode())){ 
            token = response.getbody();
        }else{
            token='Error : '+response.getbody()+' ;; '+accessBody+' ;; '+response.getStatusCode(); 
        }
        System.debug(LoggingLevel.INFO,'===== sendAccount : token ====='+token);
        return token;
    }
}