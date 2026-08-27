/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 02-02-2024
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   12-18-2023   Ritesh Kumar   Initial Version
**/
trigger EBSOrderLineTrigger on EBS_Order_Line__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    
    // Run 15 min later after the last line on the order is created or edited 

    Switch On trigger.operationType{
        
        When AFTER_UPDATE
        {
            //EBSOrderLineTriggerHandler.DelayedOrderCaseCreation(trigger.new, trigger.oldMap); //SF-1204
            Boolean flag = TRUE;
            if(flag){
                flag = EBSOrderLineHandler.delayedOrderCase(trigger.new, trigger.oldMap);
            }
            
        }
    }

    TriggerHandler.showLimits();
	new EBSOrderLineSendEmail('EBSOrderLineSendEmail').debug(true).run();
    
}