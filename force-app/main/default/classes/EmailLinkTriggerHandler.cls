public with sharing class EmailLinkTriggerHandler {
    
    public static void emailLinkCaseAssignment(List<Email_Link__c> newEmailLinkList)
    {
       Boolean RunLogic = False;
        system.debug('emailLinkCaseAssignment called@@@@@@@'+newEmailLinkList);
        Set<Id> caseIds = new Set<Id>();
        Map<String,datetime> caseIDLinkDateMap = New Map<String,datetime>();
        
        for ( Email_Link__c el : newEmailLinkList )
        {
            if ( el.Case__c != null )
            {
                caseIds.add(el.Case__c);
                caseIDLinkDateMap.put(el.Case__c , el.CreatedDate);
            }
        }

        Map<String, String> profileMap = new Map<String, String>();
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name LIKE '%claim%' or Name LIKE '%customer service%'];
        
        for ( Profile pr : profileList )
        {
            profileMap.put(pr.Id, pr.Name);
        }
        
        List<Case> updateCaseList = new List<Case>();        
        Map<Id, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        List<Case> caseList = [SELECT Id, createddate,ReOpen_Date__c, Status, RecordTypeId, CreatedBy.ProfileId FROM Case WHERE Id =: caseIds];
        AssignmentRule AR = [SELECT Id FROM AssignmentRule WHERE SObjectType = 'Case' AND Active = True LIMIT 1];
        
        for ( Case cs : caseList )
        {
            Long caseCreatedTime = cs.createddate.getTime() ;
            //Long currentDTLong = DateTime.now().getTime();
            Long currentDTLong = caseIDLinkDateMap.get(cs.id).getTime();
            Long milliseconds =  currentDTLong - caseCreatedTime;
            Long seconds = milliseconds / 1000;
            if(seconds > 4 ){
               RunLogic = true;
            }
            if(test.isRunningTest()){
                RunLogic = true;
            }
            if ( (RunLogic) && (caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('Clarification') 
                && ( cs.Status != 'Closed' && cs.Status != 'Merged - Duplicate' && cs.Status != 'Merged' ) ))
            {
                cs.Status = 'Customer Response';
                system.debug('insdie if clarification type @@@@@@@@@@@@@');
                if (profileMap.get(cs.CreatedBy.ProfileId) == null)
                {

                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    
                    cs.setOptions(dmlOpts);
                    updateCaseList.add(cs);
                }
                else
                {
                    updateCaseList.add(cs);
                }
            }
         /*   else if((RunLogic) && (caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('VLT Vendor Liaison Case') || caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('MLT Mfg Liaison Case')) ){  
                cs.Status = 'Response Received';            
               updateCaseList.add(cs);
                
            }*/
            else if ( (RunLogic) && (!caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('Clarification') 
                     && ( cs.Status == 'Closed' ) ))
            {
                // do not run logic for mlt vlt 
                if((!caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('VLT Vendor Liaison Case') && !caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('MLT Mfg Liaison Case'))){
                cs.Status = 'Customer Response';
                cs.ReOpen_Date__c = DateTime.now();
                
                if (profileMap.get(cs.CreatedBy.ProfileId) == null)
                {

                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    
                    cs.setOptions(dmlOpts);
                    updateCaseList.add(cs);
                }
                else
                {
                    updateCaseList.add(cs);
                }
                               }
            }
            else if ( (RunLogic) && (!caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('Clarification') 
                     && ( cs.Status != 'Closed' && cs.Status != 'Merged - Duplicate' &&  cs.Status != 'Merged') ))
            {
                system.debug('if case is not clarification@@@@@@@@@@@');
                // do not run logic for mlt vlt 
                if((!caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('VLT Vendor Liaison Case') && !caseRecordTypeMap.get(cs.RecordTypeId).getName().containsIgnoreCase('MLT Mfg Liaison Case'))){
                    cs.Status = 'Customer Response';
                	updateCaseList.add(cs);
                }
               
            }
        }
        if(!updateCaseList.isempty() ){
            update updateCaseList;

        }
    }
}