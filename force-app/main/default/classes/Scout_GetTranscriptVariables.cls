/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   07-13-2023   Ritesh Kumar   Initial Version
**/
public without sharing class Scout_GetTranscriptVariables {

    public class TranscriptInput {
        @InvocableVariable(required=true)
        public ID routableID;
    }

    public class VisitorOutputData { 

        @InvocableVariable(required=true)
        public String sHowMayWeHelpYou; 
        
        @InvocableVariable(required=true)
        public String sCaseNumber; 
        
        @InvocableVariable(required=true)
        public String sChatRoute;
    }

    @InvocableMethod(label='Get Transcript Variables')
    public static List<VisitorOutputData> getUserName(List<TranscriptInput> transcripts) {

        List<VisitorOutputData> dataList = new List<VisitorOutputData>();

        for (TranscriptInput transcript : transcripts) {
 
        LiveChatTranscript transcriptRecord = [
            SELECT Name,  Case.How_May_We_Help_You__c, Case.Account_Number__c, case.CaseNumber
            FROM LiveChatTranscript
            WHERE Id = :transcript.routableID 
            LIMIT 1
        ];
 
        VisitorOutputData visitorData = new VisitorOutputData();
        visitorData.sHowMayWeHelpYou = transcriptRecord.Case.How_May_We_Help_You__c;
        visitorData.sCaseNumber = transcriptRecord.Case.CaseNumber;
        visitorData.sChatRoute = getChatRoute(transcriptRecord.Case.Account_Number__c);

         
 
        dataList.add(visitorData);
        }
 
        return dataList;
    }
    
    public static String getChatRoute(String accountNumber){
        String chatRoute ='';
        Account [] accountRcord = [SELECT ID, Name, Chat_Routing__c FROM Account where Customer_Account_Number__c =: accountNumber LIMIT 1];
        chatRoute = accountRcord.size() > 0 ? accountRcord[0].Chat_Routing__c : '';
        return chatRoute;
    }
}