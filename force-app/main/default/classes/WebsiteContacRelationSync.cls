public with sharing class WebsiteContacRelationSync {
    

    public static AccountContactRelation contactRelationSync(String contactJson, String recordId){ 
        AccountContactRelation relations = new AccountContactRelation ();
        List<LogInput> logInputList = new List<LogInput>();
        GrandNode_Setting__mdt grandNodeSetting = getGrandNodeSetting(
            KoozieUtility.isSandbox()
            ? 'Grand_Node_Sandbox_Contact_Relation'
            : 'Grand_Node_Contact_Relation'
        );

        String accessBody = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(grandNodeSetting.Website_API_URL__c); 
        request.setmethod(grandNodeSetting.Request_Type__c);  
        String authorization = KoozieConstants.BEARER + getToken(); 
        request.setHeader(KoozieConstants.CONTENT_TYPE, KoozieConstants.APPLICATION_JSON);
        

        if(! authorization.contains('Error :')){
            request.setHeader(KoozieConstants.AUTHORIZATION, authorization);
            request.setTimeout(120000);
            accessBody =  contactJson; 
            request.setBody(accessBody); 
            HTTPResponse response;
            response = http.send(request);
            System.debug(LoggingLevel.INFO , '====Status Code ====' +response.getStatusCode());
            System.debug(LoggingLevel.INFO , '====Response ====' +response.getbody());
            if(KoozieConstants.SUCCESS_CODES.contains(response.getStatusCode())){
                String responseJSON = (String) response.getBody();
                AccountContactRelation relationData = new AccountContactRelation();
                relationData.Id = recordId;
                relationData.webId__c = getWebId(responseJSON);
                if(String.isNotBlank(getWebId(responseJSON))){
                    relations = relationData;
                }
            }
        }
        
        return relations;
    } 
     
    public static String getToken(){

        String token = '';
        
       GrandNode_Setting__mdt grandNodeSetting = getGrandNodeSetting(
            KoozieUtility.isSandbox()
            ? 'Grand_Node_Sandbox_Contact_Relation'
            : 'Grand_Node_Contact_Relation'
        );
        String accessBody = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(grandNodeSetting.Token_URL__c); 
        request.setmethod(grandNodeSetting.Request_Type__c);   
        request.setHeader('content-type', 'application/json');
        request.setTimeout(120000);
        accessBody = '{"email":"'+grandNodeSetting.Email__c+'","password":"'+grandNodeSetting.Password__c+'"}'; 
        request.setBody(accessBody);
        HTTPResponse response;
        response = http.send(request);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){ 
            token = response.getbody();
        }else{
            token='Error : '+response.getbody()+' ;; '+accessBody+' ;; '+response.getStatusCode(); 
        } 
        return token;
    }

    public static GrandNode_Setting__mdt getGrandNodeSetting(String settingName){

        GrandNode_Setting__mdt grandNodeSetting = new GrandNode_Setting__mdt();
        grandNodeSetting = [
            SELECT DeveloperName, Token_URL__c, Request_Type__c, Password__c,Website_API_URL__c, Base_URL__c,Email__c, Website_Delete_API__c
            FROM GrandNode_Setting__mdt
            WHERE  DeveloperName =: settingName 
            LIMIT 1
        ];

        return grandNodeSetting;
    }

    public static String getWebId(String responseJSON){
        String websiteId = '';
        Map<String,Object> responseData = (Map<String,Object>) JSON.deserializeUntyped(responseJSON); 
        if(responseData == null){
            return '';
        }

        Map<String,Object> eventData = responseData.containsKey('EventResponse')? (Map<String,Object>) responseData.get('EventResponse'): new  Map<String,Object>() ;
        if(eventData == null){
            return '';
        }
        Map<String,Object> relationData = eventData.containsKey('AccountContactRelation')?  (Map<String,Object>)eventData.get('AccountContactRelation'): new  Map<String,Object>() ;
        if(relationData == null){
            return '';
        }

        websiteId = (String) relationData.get('webId__c');
        return websiteId;
    }
    
}