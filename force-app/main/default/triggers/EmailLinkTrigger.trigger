trigger EmailLinkTrigger on Email_Link__c (after insert) {
    /*SwitchTrigger__c ST= SwitchTrigger__c.getvalues('EmailLinkTrigger');
    system.debug(' inside trigger --------ST@@@@@@@@@'+ST.Deactivate__c);
    Switch on trigger.operationType
    {
        When AFTER_INSERT
        {
            boolean runlogic = true;
            List<Case> lstCase = new List<Case>();
            List<ID> lstCaseID = new List<ID>();
            
            // create List of caseID from email link
            for(Email_Link__c emailLink :trigger.new){
                lstCaseID.add(emailLink.Case__c); 
            }
             
            if(!lstCaseID.isempty()){
                lstCase = [Select ID, Status, RecordType.Name 
                           From Case
                           Where ID =: lstCaseID];
                
                For(Case caseCheck : lstCase){
                   If(caseCheck.RecordType.Name == 'Clarification' && (caseCheck.Status == 'Closed' || caseCheck.Status =='Merged - Duplicate')){
                        runlogic = false;
                    }
                }
            }
          
            if(!ST.Deactivate__c && runlogic){
                system.debug('email link trigger logic run @@@@@');
                EmailLinkTriggerHandler.emailLinkCaseAssignment(trigger.new);
            }
                    
        }
    }*/
}