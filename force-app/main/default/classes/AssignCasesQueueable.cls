public class AssignCasesQueueable implements Queueable {

    private List<Id> caseIds;

    public AssignCasesQueueable(List<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {

        List<Case> lstCaseToUpdate = new List<Case>();

        Map<Id, String> mpProfile = new Map<Id, String>();

        List<Profile> lstProfile = [ SELECT Id, Name FROM Profile WHERE Name = 'Bic API Only' ];

        for(Profile p : lstProfile) {
            mpProfile.put(p.Id, p.Name);
        }

        AssignmentRule ar = [ SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true LIMIT 1 ];

        List<Case> cases = [ SELECT Id, CreatedBy.ProfileId FROM Case WHERE Id IN :caseIds ];

        for(Case c : cases) {

            if(mpProfile.containsKey(c.CreatedBy.ProfileId)) {

                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = ar.Id;

                c.setOptions(dmlOpts);
                lstCaseToUpdate.add(c);
            }
        }
        if(!lstCaseToUpdate.isEmpty()) {
            update lstCaseToUpdate;
        }
    }
}