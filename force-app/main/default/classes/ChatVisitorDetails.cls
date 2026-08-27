/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Mohammad Arafat Ali
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   06-02-2023   Ritesh Kumar   Initial Version
**/
public without sharing class ChatVisitorDetails {


    @AuraEnabled
    Public Static List<ConversationContextEntry > getConversationContextEntry( String parentId){
        List<ConversationContextEntry > conversationContextList = new  List<ConversationContextEntry >();
        

            conversationContextList  = [SELECT Id,ConversationContextEntryName, CustomDetailContextKey, CustomDetailContextValue FROM ConversationContextEntry  WHERE ParentId =:parentId ];

            return conversationContextList;    
        
    }
}