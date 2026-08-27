public class TACaseLookupsQueueable implements Queueable {

    private Set<Id> caseIds;
    private String trigContext;
    private String caseType;

    public TACaseLookupsQueueable(Set<Id> caseIds, String trigContext, String caseType) {
        this.caseIds = caseIds;
        this.trigContext = trigContext;
        this.caseType = caseType;
    }

    public void execute(QueueableContext context) {

        if(caseIds == null || caseIds.isEmpty()) {
            return;
        }

        Map<String, Id> clarificationTeamMap = new Map<String, Id>();
        Map<String, Id> proofTeamMap = new Map<String, Id>();

        for(Account_Clarification_Team__c act :
            [SELECT Id, Account_Team__c FROM Account_Clarification_Team__c]) {

            clarificationTeamMap.put(act.Account_Team__c, act.Id);
            proofTeamMap.put(act.Account_Team__c, act.Id);
        }
        
        List<Case> cases = [
            Select ID, ContactID, AccountID, Status, EBS_Order_ID__c, EBS_Account_Number__c, EBS_Order__c, 
            SuppliedEmail, Clarification_Team__c, Proof_Team__c, RecordType.Name
            From Case 
            WHERE Id IN :caseIds
        ];

        Set<String> acctNums = new Set<String>();
        Set<String> orderNums = new Set<String>();

        for(Case c : cases) {
            if(String.isNotBlank(c.EBS_Account_Number__c)) {
                acctNums.add(c.EBS_Account_Number__c);
            }
            if(String.isNotBlank(c.EBS_Order_ID__c)) {
                orderNums.add(c.EBS_Order_ID__c);
            }
        }

        Map<String, Id> acctMap = new Map<String, Id>();
        for(Account a :
            [SELECT Id, Customer_Account_Number__c
             FROM Account
             WHERE Customer_Account_Number__c IN :acctNums]) {

            acctMap.put(a.Customer_Account_Number__c, a.Id);
        }

        Map<String, Id> orderMap = new Map<String, Id>();
        for(EBS_Order__c o :
            [SELECT Id, EBS_Order_Number__c
             FROM EBS_Order__c
             WHERE EBS_Order_Number__c IN :orderNums]) {

            orderMap.put(o.EBS_Order_Number__c, o.Id);
        }

        Map<String, List<Contact>> emailContactMap =
            emailToCaseContact.emailToCaseContact(cases);

        List<Case> casesToUpdate = new List<Case>();

        for(Case c : cases) {

            // Account lookup
            if(trigContext == 'Insert'
               && acctMap.containsKey(c.EBS_Account_Number__c)) {

                c.AccountId = acctMap.get(c.EBS_Account_Number__c);
            }

            // Contact lookup (Email based)
            if(String.isNotBlank(c.SuppliedEmail) && c.ContactId == null
               && emailContactMap.containsKey(c.SuppliedEmail)) {

                Contact selectedContact = emailContactMap.get(c.SuppliedEmail)[0];

                for(Contact con : emailContactMap.get(c.SuppliedEmail)) {
                    if(con.AccountId == c.AccountId) {
                        selectedContact = con;
                        break;
                    }
                }
                c.ContactId = selectedContact.Id;
            }

            // Order lookup
            if(orderMap.containsKey(c.EBS_Order_ID__c)) {
                c.EBS_Order__c = orderMap.get(c.EBS_Order_ID__c);
            }

            // Clarification Team lookup
            if(String.isNotBlank(c.Clarification_Team__c)
               && clarificationTeamMap.containsKey(c.Clarification_Team__c)) {

                c.Clarification_Team_Link__c =
                    clarificationTeamMap.get(c.Clarification_Team__c);
            }

            if(String.isNotBlank(c.Proof_Team__c)
               && proofTeamMap.containsKey(c.Proof_Team__c)) {

                c.Proof_Team_Link__c =
                    proofTeamMap.get(c.Proof_Team__c);
            }

            casesToUpdate.add(c);
        }
        if(!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }
}