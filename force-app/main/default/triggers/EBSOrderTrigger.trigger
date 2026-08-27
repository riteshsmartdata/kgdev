/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 05-13-2025
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
trigger EBSOrderTrigger on EBS_Order__c (before insert,before update, after insert, after update) {  
if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
           // EBSOrderTriggerUtility.populateContactsOnOrder(Trigger.new, Trigger.oldMap);
            /*OrderContact tagContact = new OrderContact();
            tagContact.tagContact(Trigger.new, Trigger.oldMap);*/
            
        }
    }
    Trigger_Settings__mdt [] triggerSetting  = [SELECT DeveloperName, Is_Active__c, Object_Name__c FROM Trigger_Settings__mdt   WHERE DeveloperName ='EBSOrderTrigger' LIMIT 1];

    if(triggerSetting.size() >0  && triggerSetting[0].Is_Active__c == true){
        Map<Id,Ebs_Order__c> ebsNewMap = new Map<Id,Ebs_Order__c>();
        List<Id> ebsOrderTempList = new List<Id>();
       // if(////PopulateAccEmails.isfirstRun == true){

            List<EBS_Order__c> ebsList = new List<EBS_Order__c>();
            //LIFT-2064 : Task : LIFT-2082
          //  Map<String, EBS_Order__c> QuoteNum_Order_Map = new Map<String, EBS_Order__c>();
            Map<String, List<EBS_Order__c>> QuoteNum_Order_Map = new Map<String, List<EBS_Order__c>>();

            Map<String, EBS_Order__c> OQR_Map = new Map<String, EBS_Order__c>();
            Map<String, EBS_Order__c> QR_Map = new Map<String, EBS_Order__c>();
            
            for(EBS_Order__c eb : Trigger.new){
               // String quoteNumber = trigger.oldMap.get(eb.id).Quote_Number__c;
               // System.debug('====quoteNumber===='+quoteNumber);
                
                if(eb.Account_Name__c != null){
                    if(!ebsList.contains(eb)){
                        ebsList.add(eb);
                    } 
                }
                //LIFT-2064 : Task : LIFT-2082
                if(String.isNotBlank(eb.Quote_Number__c)) {
                    if(!QuoteNum_Order_Map.containsKey(eb.Quote_Number__c)){
                        QuoteNum_Order_Map.put(eb.Quote_Number__c, new List<EBS_Order__c>());
                    }
                    QuoteNum_Order_Map.get(eb.Quote_Number__c).add(eb);
                }
            }

            /**
             * Description : Calling classes to populate From Email & Acc Emails on Order
             */
            if(trigger.isBefore ){

                //EmailOnEBSOrderHandler.UpdateEmailOnEBSOrder(trigger.new);
                if(trigger.isInsert){
                    PopulateFromEmailOnOrder.populateFromEmail(trigger.new);
                    //populateQuoteReqAndOpp.UpdateOrderWithQuoteAndOpp(QuoteNum_Order_Map);
                }

                if(trigger.isUpdate || trigger.isInsert){
                    populateQuoteReqAndOpp.UpdateOrderWithQuoteAndOpp(QuoteNum_Order_Map);
                    //EmailOnEBSOrderHandler.UpdateEmailOnEBSOrder(trigger.new);
                    if(ebsList.size()>0){
                        //populateAccPoContactCcEmailValues.populateAccPoContactCcEmailValues(ebsList);
                        ////PopulateAccEmails.populateEmail(ebsList);
                    }
                }
            }
            ////PopulateAccEmails.isfirstRun = false;
        //} 
    }
}