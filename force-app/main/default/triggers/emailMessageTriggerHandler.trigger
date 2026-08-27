trigger emailMessageTriggerHandler on EmailMessage (after insert, after update) {
    
    List<User> automatedUser = [SELECT Id FROM User 
                                WHERE Id = :UserInfo.getUserId() 
                                AND Name = 'Automated Process' LIMIT 1];
    
    if(!automatedUser.isEmpty()){
        return;
    }
     System.debug('trigger run');
    // Call the Koozie email classification handler (converted from Update_Inbound_Email_Message flow)
    if (Trigger.isAfter && Trigger.isInsert) {
        EmailMessageTriggerHandler.handleKoozieEmailClassification(Trigger.new);
    }
    
    List<Case> lstCase = new List<Case>();
    List<ID> lstStringID = new List<ID>();
    Map<ID, ID> emCaseMap = new Map<ID,ID>();
    SwitchTrigger__c ST= SwitchTrigger__c.getvalues('EmailLinkTrigger');
    boolean runlogic = true;
    System.debug('Email Message Triger ::: '+ST);
    //Manage Think Automation case inserts
    Set<ID> lstEmailId = trigger.newMap.keyset();     
    String newUniqueID = '';
    List<ID> emID = new List<ID>(lstEmailId);   
    Id emailMessageIdToUpdate;
    Map<Id, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosById();
    List<EmailMessage> emailMessageCloneList = new List<EmailMessage>();
    Set<Id> parentIds = new Set<Id>();
    For(EmailMessage em : trigger.new){
        system.debug(em.ParentId);
        lstStringID.add(em.ParentID);    
        emCaseMap.put(em.ParentID,em.ID); 
        newUniqueID = em.Unique_ID__c;
        emailMessageIdToUpdate = em.Id;
    }
    System.debug('======= lstStringID A ======'+lstStringID);
    if(lstStringID.size() > 0){
        lstCase = [Select ID, Status, RecordType.Name, Merged_Parent_Case__c 
                   From Case
                   Where ID =: lstStringID];
        
        lstStringID.clear();
        
        For(Case caseCheck : lstCase){
            
            system.debug(caseCheck.status);
            system.debug(caseCheck.RecordType.Name);
            
            If(caseCheck.RecordType.Name == 'Clarification' && caseCheck.Status == 'Closed'){
                if(!checkRecursive.SetOfIDs.contains(caseCheck.Id)){
                    lstStringID.add(emCaseMap.get(caseCheck.ID));
                    checkRecursive.SetOfIDs.add(caseCheck.ID); 
                }
            }
            System.debug('======= caseCheck A ======'+caseCheck);
            if (caseCheck.Status == 'Merged - Duplicate' ||  caseCheck.Status == 'Merged'){
                System.debug('======= caseCheck.Status ======'+caseCheck.Status);                
                System.debug('======= caseCheck B ======'+caseCheck);
                System.debug('======= caseCheck B ======'+caseCheck.Merged_Parent_Case__c);
                case[] winnerCase = [SELECT Id, RecordTypeId, CaseNumber FROM Case WHERE CaseNumber =: caseCheck.Merged_Parent_Case__c LIMIT 1];
                system.debug('Winner Case => '+winnerCase);
                
                if(!winnerCase.isEmpty()){
                    //Email Message Cloning
                    for ( EmailMessage em : trigger.new ) {
                        System.debug('===em.ParentId==='+em.ParentId);
                        EmailMessage eMessage = em.Clone(false,true, true, false);
                        eMessage.ParentId = winnerCase[0].Id;
                        eMessage.Unique_ID__c = '';
                        emailMessageCloneList.add(eMessage);
                        System.debug('===emailMessageCloneList==='+emailMessageCloneList);
                    }
                }
                
            }
            If(caseCheck.RecordType.Name == 'Clarification' && (caseCheck.Status == 'Closed' || caseCheck.Status =='Merged - Duplicate')){
                runlogic = false;
            }
            
        }
        if(!ST.Deactivate__c && runlogic){
            system.debug('email link trigger logic run @@@@@');
            EmailMessageTriggerHandler.emailLinkCaseAssignment(trigger.new);
        }
        
        if(lstStringID.size() > 0){
            clarificationEmailHandler.closeClariHandler(lstStringID);           
        }
        if(!emailMessageCloneList.isempty() ){
            if(checkRecursive.isFirstTime){
                checkRecursive.isFirstTime=false;
                insert emailMessageCloneList;
            } 
        }
    }
    
    if(Trigger.isAfter){
        Boolean isFirstRun = TRUE;
        if(isFirstRun){
            isFirstRun = CreateContactHistoryEmail.emailMessageHandler(Trigger.new, Trigger.oldMap);
            
        }
        
    }
    
}