global class CreateCaseFromSurveyQueueable implements Queueable {
    
    public void execute(QueueableContext qc) {
        
        try {
            List<Custom_Survey__c> surveyList = [
                SELECT Id, Case__c, Case__r.CaseNumber, Case__r.AccountId, Case__r.ContactId 
                FROM Custom_Survey__c
                WHERE Email_Case_Feedback__c = 'Poor' 
                AND Case__c != null 
                AND DAY_ONLY(CreatedDate) = Today
                AND Id NOT IN (SELECT Custom_Survey__c FROM Case WHERE Custom_Survey__c != null AND RecordType.DeveloperName = 'Survey')
                LIMIT 200
            ];

            if (surveyList.isEmpty()) { 
                return;
            }

            Id surveyRecordTypeId = Schema.SObjectType.Case
                                        .getRecordTypeInfosByDeveloperName()
                                        .get('Survey')
                                        .getRecordTypeId();

            List<Case> casesToInsert = new List<Case>();
            for (Custom_Survey__c survey : surveyList) {
                Case cse = new Case();
                cse.Status           = 'New';
                cse.Custom_Survey__c = survey.Id;
                cse.AccountId        = survey.Case__r.AccountId;
                cse.ContactId        = survey.Case__r.ContactId;
                cse.Origin           = 'Email';
                cse.Subject          = 'Survey Response On ' + survey.Case__r.CaseNumber;
                cse.ParentId         = survey.Case__c;
                cse.Survey_Type__c   = 'Email Case Survey';
                cse.RecordTypeId     = surveyRecordTypeId;
                casesToInsert.add(cse);
            }

            insert casesToInsert;

            Set<Id> newCaseIds = new Set<Id>();
            for (Case c : casesToInsert) {
                newCaseIds.add(c.Id);
            }

            if (!newCaseIds.isEmpty()) {
                System.enqueueJob(new TACaseLookupsQueueable(newCaseIds, 'Insert', 'Case'));
            } 


        } catch (Exception ex) {
            ApexLogUtill.createApexLog(
                'CreateCaseFromSurveyQueueable.execute',
                null,
                ex.getMessage(), 
                null,
                'Case',
                ex.getMessage(),
                0
            );
        }
    }
}