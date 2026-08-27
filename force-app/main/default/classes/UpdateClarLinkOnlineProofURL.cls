/**
 * @description       : 
 * @author            : Saxena Anubhav
 * @group             : 
 * @last modified on  : 27-11-2023
 * @last modified by  : Saxena Anubhav
**/
public class UpdateClarLinkOnlineProofURL {

    public static FINAL Id PROOF_QUESTION_RECORDTYPEID = Schema.SObjectType.Clarification_Question__c.getRecordTypeInfosByName().get('ProofQuestion').getRecordTypeId();
	
    public static void updateClarProofUrlOnCase(List<Case> caseList){
        try {
            Set<Id> caseIds = new Set<Id>();
            List<Clarification_Question__c> proofQuestionList = new List<Clarification_Question__c>();
            Map<Id,String> caseProofQuestionsURLMap = new Map<Id,String>();
            for(Case caseRecord:caseList){
                if(caseRecord.Count_Open_Clarification_Questions__c>0 && caseRecord.Count_Open_EProof_Questions__c>0){
                    caseIds.add(caseRecord.Id);				
                }
            }
            if(!caseIds.isEmpty()){
                proofQuestionList = [SELECT Id,Status__c,Question_Type__c,Online_Proof_URL__c,Case__r.Id FROM Clarification_Question__c WHERE Status__c = 'Open' AND recordTypeId =:PROOF_QUESTION_RECORDTYPEID AND Case__r.Id IN:caseIds];
            }
            if(!proofQuestionList.isEmpty()){
                for(Clarification_Question__c proofQuestions:proofQuestionList){
                    if(String.isNotBlank(proofQuestions.Online_Proof_URL__c) && !(caseProofQuestionsURLMap.containsKey(proofQuestions.Case__r.Id))){
                        String urls = proofQuestions.Online_Proof_URL__c + ', ';
                        caseProofQuestionsURLMap.put(proofQuestions.Case__r.Id,urls);
                    }else If (String.isNotBlank(proofQuestions.Online_Proof_URL__c) && caseProofQuestionsURLMap.containsKey(proofQuestions.Case__r.Id)){
                        String urls = caseProofQuestionsURLMap.get(proofQuestions.Case__r.Id);
                        urls += proofQuestions.Online_Proof_URL__c + ', ';
                        caseProofQuestionsURLMap.put(proofQuestions.Case__r.Id,urls);
                    }
                }
                // System.debug('============= Proof Question Map =============== '+caseProofQuestionsURLMap);	
            }	
            if(!caseIds.isEmpty()){
                for(Case caseRecord:caseList){																							
                    String proofURLText = '';	
                    if(String.isNotBlank(caseRecord.Clar_Link__c)){
                        // System.debug('================= Clar Link =============='+caseRecord.Clar_Link__c);
                        proofURLText += 'Clar URL: '+caseRecord.Clar_Link__c + '\n';
                    }
                    if(caseProofQuestionsURLMap.containsKey(caseRecord.Id)){
                        String modifiedUrl = caseProofQuestionsURLMap.get(caseRecord.Id).removeEnd(', ');
                        // System.debug('============ Modified URL ========== '+modifiedUrl);
                        proofURLText += 'Proof URL: '+modifiedUrl +'\n';
                    }
                    caseRecord.Proof_Clar_Link_URL__c = proofURLText;
                }
            }
            
        } catch (Exception e) {
            ApexLogUtill.createApexLog( 'UpdateClarLinkOnlineProofURL.updateClarProofUrlOnCase', null, null, null, 'Case', e.getMessage() + '\n' + e.getStackTraceString(), null );
            
        } 
    }
}