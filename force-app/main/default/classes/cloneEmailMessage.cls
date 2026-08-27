public class cloneEmailMessage {
    @InvocableMethod
    public static void EmailMessageClone(List<id> emailCaseIds)
    {
        boolean runlogic = true;
        // email message trigger code
        List<Case> lstCase = new List<Case>();
        List<ID> lstCaseID = new List<ID>();
        List<ID> lstStringID = new List<ID>(); 
        Map<ID, ID> emCaseMap = new Map<ID,ID>();
       
        // fetch email message for this particular case 
        List<EmailMessage> EmailMessageList = [select id,ParentID from EmailMessage where ParentID IN:emailCaseIds order by createddate desc limit 1];
        For(EmailMessage em : EmailMessageList){
            system.debug(em.ParentId);
            lstStringID.add(em.ParentID);    
            emCaseMap.put(em.ParentID,em.ID); 
        }
        if(lstStringID.size() > 0){
            lstCase = [Select ID, Status, RecordType.Name 
                       From Case
                       Where ID =: lstStringID];
            
            lstStringID.clear();
            For(Case caseCheck : lstCase){
                
                system.debug(caseCheck.status);
                system.debug(caseCheck.RecordType.Name);
                
                If(caseCheck.RecordType.Name == 'Clarification' && caseCheck.Status == 'Closed'){
                    lstStringID.add(emCaseMap.get(caseCheck.ID));
                    runlogic = false;
                }
            }
            if(lstStringID.size() > 0){
                clarificationEmailHandler.closeClariHandler(lstStringID);           
            }
        }
    }
}