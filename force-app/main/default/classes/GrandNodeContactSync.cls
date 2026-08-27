/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : Ritesh Kumar
 * Ver   Date         Author         Modification
 * 1.0   08-19-2023   Ritesh Kumar   JIRA SF-884
**/
public class GrandNodeContactSync { 
    public static List<LogInput> contactSync(String contactJson, String ContactRecordId){
 
        List<LogInput> logInputList = new List<LogInput>();
        GrandNode_Setting__mdt grandNodeSetting = KoozieUtility.isSandbox() ? getGrandNodeSetting('Contact_Sandbox_Endpoint') : getGrandNodeSetting('Grand_Node_Contact_Sync');
        String accessBody = '';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(grandNodeSetting.Website_API_URL__c); 
        request.setmethod(grandNodeSetting.Request_Type__c);  
        String authorization = 'Bearer '+getToken(); 
        request.setHeader('content-type', 'application/json');
 
        if(! authorization.contains('Error :')){
            request.setHeader('Authorization', authorization);
            request.setTimeout(120000);
            accessBody =  contactJson; 
            request.setBody(accessBody); 
            HTTPResponse response;
            response = http.send(request);
            if(response.getStatusCode() != 200 || Test.isRunningTest()){ 
                LogInput errorLog = new LogInput();
                errorLog.source = 'Website';
                errorLog.requestBody = accessBody;
                errorLog.resopnseBody = response.getbody();
                errorLog.recordId = ContactRecordId;
                errorLog.objectName = 'Contact';
                errorLog.statusCode = response.getStatusCode();
                logInputList.add(errorLog); 
            } 
        }else{
            List<String> logdata = authorization.split(';;'); 
            LogInput errorLog = new LogInput();
                errorLog.source = 'Website';
                errorLog.requestBody = logdata[1].trim();
                errorLog.resopnseBody = logdata[0].replace('Error : ','').trim();
                errorLog.recordId = ContactRecordId;
                errorLog.objectName = 'Contact';
                errorLog.statusCode = Integer.valueOf(logdata[ (logdata.size() -1)].trim());//JIRA SF-884
                logInputList.add(errorLog); 
        }
        return logInputList;
    } 
    public static String getToken(){
 
        String token = '';
        GrandNode_Setting__mdt grandNodeSetting = KoozieUtility.isSandbox() ? getGrandNodeSetting('Contact_Sandbox_Endpoint') : getGrandNodeSetting('Grand_Node_Contact_Sync');
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
        if(response.getStatusCode() == 200){ 
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
}