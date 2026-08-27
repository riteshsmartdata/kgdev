/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 08-30-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
trigger caseTriggerHandler on Case (before insert, after insert, after update, before update) {
    
    //Handle after context
   /*if(trigger.isAfter){
        
        //Handle insert context
        if(trigger.isInsert){
            
            //Manage Think Automation case inserts
            Set<ID> lstCaseID = trigger.newMap.keyset();  
            Set<ID> setCaseID = new Set<ID>();
            Set<ID> lstCaseIDClar = new Set<ID>(); 
            List<Case> lstCaseClarID = new List<Case>();
            
            List<ID> csID = new List<ID>(lstCaseID);
            
            For(ID s : lstCaseID){            
                If(checkRecursive.SetOfIDs.contains(s)){ 
                    lstCaseID.remove(s);
                }            
            }
            
            Map<ID, Case> mpCaseRT = new Map<ID, Case>
                ([Select ID, RecordType.Name, suppliedEmail, ContactID, AccountId, EBS_Account_Number__c
                From Case
                Where ID =: trigger.newMap.keyset()]);
            
            For(Case caseRT : mpCaseRT.values()){            
                If(checkRecursive.SetOfIDs.contains(caseRT.ID)){ 
                    lstCaseIDClar.remove(caseRT.ID);
                } else {
                    if(caseRT.recordType.Name == 'Clarification'){
                        lstCaseIDClar.add(caseRT.ID);
                        lstCaseClarID.add(caseRT);
                    } else {
                        setCaseID .add(caseRT.ID);
                    }                
                }            
            }            
            
            if(lstCaseID.size() > 0 || lstCaseIDClar.size() >0){ */
            
                //Already Commented
               /* if(lstCaseIDClar.size() > 0){
                    Map<String, List<Responsibility_Type__c>> rtLoad = new Map<String, List<Responsibility_Type__c>>();
                    rtLoad = emailToCaseContact.emailToCaseRT(lstCaseClarID);
                    setCaseID.addAll(lstCaseIDClar);
                }  */             

                /*if(setCaseID .size() > 0){
                    thinkAutomationCaseLookups.taCaseLookups(setCaseID , 'Insert', 'Case');
                }
                
                caseCategory.updateCategory(setCaseID );
                
                //Manage case assignments
                //Send empty map and call class
                Map<ID, String> oldStatus = new Map<ID, String>();
                Map<ID, String> oldAccount = new Map<ID, String>();          
                modifyCaseAssignment.caseOwnerAssignment(setCaseID , OldStatus, oldAccount,'Insert');
            } 
            
         
            
        } 
        //Handle update context
        else if(trigger.isUpdate) {
            
            Map<ID, String> oldStatus = new Map<ID, String>();
            Map<ID, String> oldAccount = new Map<ID, String>();
            Set<ID> lstCaseID = trigger.newMap.keyset();
            Set<ID> setCaseID = new Set<ID>();
            
            List<ID> csID = new List<ID>(lstCaseID);
            
            For(ID s : lstCaseID){            
                If(checkRecursive.SetOfIDsUpdate.contains(s)){ 
                    lstCaseID.remove(s);
                }
                
                checkRecursive.SetOfIDsUpdate.add(s);         
            }         
            
            if(!lstCaseID.isEmpty()){
                if(lstCaseID.size() > 0){
                    
                    For(Case c : trigger.old){
                        if(lstCaseID.contains(c.id)){
                            oldStatus.put(c.Id, c.Status);
                            oldAccount.put(c.ID, c.AccountID);   
                        }
                    }
                    system.debug('Internal IF condition');
                    //Manage case assignments and updates to cases
                    thinkAutomationCaseLookups.taCaseTeamLookups(lstCaseID);  
                    //modifyCaseAssignment.caseOwnerAssignment(lstCaseID, OldStatus, oldAccount, 'Update');
                    
                }
            }

        }
    } else {
        
        if(trigger.isInsert){
            
        } else {
            
        }    
    }
 
    if(trigger.isBefore && trigger.isUpdate){
      //  CaseTriggerUtility.UpdateEmailOnCase(trigger.new);
       // CaseTriggerUtility.UpdateClarificationToEmail(trigger.new);
       
    }

    if(trigger.isBefore && trigger.isInsert){
         CaseTriggerUtility.UpdateEmailOnCase(trigger.new);
         CaseTriggerUtility.updateVIPLargeOrder(trigger.new); 
       //  CaseTriggerUtility.UpdateClarificationToEmail(trigger.new);
        
    }    

   if(trigger.isAfter && trigger.isInsert){
      UpdateContactOnCase.UpdateCaseContact(trigger.new);     
} */
    /*if(trigger.isAfter){
    if(trigger.isUpdate || trigger.isInsert){
        List<Case> caList = new List<Case>();
        for(Case ca : Trigger.new){
              if(String.isNotBlank(ca.Clar_Link__c) && ca.Count_Open_Clarification_Questions__c > 0 && 
                  ca.Count_Open_EProof_Questions__c > 0){
                    caList.add(ca);
                }
        proofClarLink.populateProofClarLink(caList);
    }
}
}*/
    
    
    switch on Trigger.operationType {
        
        when BEFORE_INSERT 
        {
            CaseTriggerUtility.UpdateEmailOnCase(trigger.new);
            CaseTriggerUtility.updateVIPLargeOrder(trigger.new);
            CaseTriggerUtility.setCustomerToEmail(trigger.new);
            
        } 
        
       When BEFORE_UPDATE{
           
           UpdateClarLinkOnlineProofURL.updateClarProofUrlOnCase(trigger.new);
           
       }
        
        when AFTER_INSERT 
        {
         
            
            system.debug('after inser trigger called@@@@@@@@');
            //UpdateContactOnCase.UpdateCaseContact(trigger.new);    
            
            Set<ID> setCaseID = new Set<ID>();
            Map<ID, Case> mpCaseRT = new Map<ID, Case>
                ([Select ID, RecordType.Name, suppliedEmail, ContactID, AccountId, EBS_Account_Number__c
                  From Case
                  Where ID =: trigger.newMap.keyset()]);
            
            For(Case caseRT : mpCaseRT.values())
            {            
                if(!checkRecursive.SetOfIDs.contains(caseRT.ID) && caseRT.recordType.Name != 'Clarification')
                {
                    setCaseID.add(caseRT.ID);
                    checkRecursive.SetOfIDs.add(caseRT.ID);
                }
            }            
            
            if(setCaseID .size() > 0) {
                if (!System.isQueueable()) {
                    System.enqueueJob( new TACaseLookupsQueueable( setCaseID, 'Insert', 'Case' ) );
                }
                
                //thinkAutomationCaseLookups.taCaseLookups(setCaseID , 'Insert', 'Case');
                caseCategory.updateCategory(setCaseID );
                
                //Manage case assignments
                //Send empty map and call class
                Map<ID, String> oldStatus = new Map<ID, String>();
                Map<ID, String> oldAccount = new Map<ID, String>();          
                modifyCaseAssignment.caseOwnerAssignment(setCaseID , OldStatus, oldAccount,'Insert');
            }
        
        }
        
        when AFTER_UPDATE 
        {
            
            CaseTriggerUtility.runAssignmentRuleOnReopen(Trigger.new, Trigger.oldMap);
            
            
            Set<ID> lstCaseID = new Set<ID>();
            for (Case c : Trigger.new) {
                if (c.OwnerId != Trigger.oldMap.get(c.Id).OwnerId) {
                    
                    lstCaseID.add(c.Id);
                    For(ID s : lstCaseID)
                    {   
                        If(checkRecursive.SetOfIDsUpdate.contains(s))
                        { 
                            lstCaseID.remove(s);
                        }
                        checkRecursive.SetOfIDsUpdate.add(s);
                    }
                    
                }
            } 
             /* Set<ID> lstCaseID = trigger.newMap.keyset();
            
            For(ID s : lstCaseID)
            {            
                If(checkRecursive.SetOfIDsUpdate.contains(s))
                { 
                    lstCaseID.remove(s);
                }
                checkRecursive.SetOfIDsUpdate.add(s);         
            }        
            */
            
            if(lstCaseID.size() > 0)
            {
                //Manage case assignments and updates to cases
                thinkAutomationCaseLookups.taCaseTeamLookups(lstCaseID);  
            }
        }
    }
}