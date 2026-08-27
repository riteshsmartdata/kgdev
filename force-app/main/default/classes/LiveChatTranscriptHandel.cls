/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 07-20-2023
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   07-05-2023   Ritesh Kumar   Initial Version
**/
public without sharing class LiveChatTranscriptHandel {
    
    public static void UpdateCaseOwner(List<LiveChatTranscript> liveChatList){
        
        Map<Id,Id> CaseIdVSOwner = new Map<Id,Id>();
        List<Case> CaseList = new List<Case>();
        Map<String,String> emailCaseMap = new Map<String,String>();
        Set<Id> chatIdSet = new Set<Id>();
        
        if(!liveChatList.isEmpty()){
            for(LiveChatTranscript chat : liveChatList){
                if(String.isNotBlank(chat.CaseId)){
                    CaseIdVSOwner.put(chat.CaseId, chat.OwnerID); 
                    chatIdSet.add(chat.Id);
                }
            }  
        } 
        
        if(chatIdSet.size() > 0){
            List<ConversationContextEntry> entryList = [SELECT Id,ConversationContextEntryName, CustomDetailContextKey, CustomDetailContextValue,ParentId FROM ConversationContextEntry  WHERE ParentId IN:chatIdSet];
            System.debug('===== entryList ===== : '+entryList);
            if(entryList.size() > 0){
                for(ConversationContextEntry entery : entryList){
                    if(entery.CustomDetailContextKey == 'Email' && String.isNotBlank(entery.CustomDetailContextValue) ){
                        emailCaseMap.put(entery.ParentId,entery.CustomDetailContextValue );
                    }
                }
            }  
        } 
        
        if(!CaseIdVSOwner.isEmpty()){
            for(LiveChatTranscript chat : liveChatList){
                Case data = new Case();
                data.Id = chat.CaseId;
                data.SuppliedEmail = emailCaseMap.containsKey(chat.Id) ? emailCaseMap.get(chat.Id) : null; 
                
                if(String.isNotBlank(chat.CaseId) && chat.Status == 'InProgress'){ 
                    data.OwnerId = CaseIdVSOwner.get(chat.CaseId);
                    data.Status = 'Working';
                    //data.Case_Reason_Type__c = 'Chat'; 
                    System.debug('=====data ===== : '+data); 
                }
                CaseList.add(data);
            }  
        }
        
        if(!CaseList.isEmpty()){
            Database.update(CaseList);  
            CaseList.clear();
        }
        
    }
    
}