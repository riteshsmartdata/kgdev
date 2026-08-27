public class thinkAutomationCaseLookups{
    
    public static void taCaseTeamLookups(Set<ID> lstCaseID){
        List<Case> lstCaseToUpdate = new List<Case>();
        List<ID> caseIDs = new List<ID>();
        List<ID> caseAssignId = new List<ID>();
        try {
            List<Account_Clarification_Team__c> lstACT = new List<Account_Clarification_Team__c>([Select ID, Name, Account_Team__c, From_Email__c
                                                                                                  From Account_Clarification_Team__c]);
            
            List<Case> lstCase = new List<Case>([
                Select ID, ContactID, AccountID, Status, EBS_Order_ID__c, EBS_Account_Number__c, EBS_Order__c, 
                SuppliedEmail, Clarification_Team__c, Proof_Team__c, RecordType.Name, Owner.Name, hasBeenAssigned__c
                From Case 
                Where ID =: lstCaseID]);
            
            
            For(Case c : lstCase){
                
                String tacStringID = 'tac'+ c.Id;
                
                if(((c.Status == 'Follow-up Needed' || c.Status =='Customer Response' || c.Status == 'Day 1 Call (24 Hour)')            
                    && c.Owner.Name == 'Clarification Pending') 
                   ||  (c.hasBeenAssigned__c == False)){
                       caseAssignId.add(c.id);
                   }
                
                //Get ACT record for Clari and add to case record
                if(c.Clarification_Team__c != null && c.Clarification_Team__c != ''){
                    
                    //Loop through list to get ID
                    For(Account_Clarification_Team__c act : lstACT){
                        if(c.Clarification_Team__c == act.Account_Team__c){
                            c.Clarification_Team_Link__c = act.ID;
                        }
                    }
                }
                
                if(c.hasBeenAssigned__c == False){
                    c.hasBeenAssigned__c = True;
                }
                
                //Get ACT record for Proof and add to case record
                if(c.Proof_Team__c != null && c.Proof_Team__c != ''){
                    
                    //Loop through list to get ID
                    For(Account_Clarification_Team__c act : lstACT){
                        if(c.Proof_Team__c == act.Account_Team__c){
                            c.Proof_Team_Link__c = act.ID;
                        }
                    }
                } 
                
                lstCaseToUpdate.add(c);      
                
            }
            
            if(caseAssignId.size()>0){
                AssignCasesUsingAssignmentRules.CaseAssign(caseAssignId);
            }
            
            if(lstCaseToUpdate.size()>0){
                update lstCaseToUpdate;
            }
            
        } catch (Exception e) {
            ApexLogUtill.createApexLog( 'thinkAutomationCaseLookups.taCaseTeamLookups', null, null, null, 'Case', e.getMessage() + '\n' + e.getStackTraceString(), null );
            
        } 
    }    
}