/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-05-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   07-05-2023   Ritesh Kumar   Initial Version
**/
trigger LiveChatTranscriptTrigger on LiveChatTranscript (After insert, After update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){       
            LiveChatTranscriptHandel.UpdateCaseOwner(Trigger.New);
        }

    }

}