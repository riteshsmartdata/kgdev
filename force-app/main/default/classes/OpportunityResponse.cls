public class OpportunityResponse {
    public Boolean success { get; set; }
    public Boolean showOther { get; set; }
    public String feedbackText { get; set; }
    public String oppId;
    public String picklistValue;
    public Custom_Survey__c surveyRec;
    public String USER_MESSAGE { get; set; }

    public OpportunityResponse() {
        USER_MESSAGE = '';
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        picklistValue = ApexPages.currentPage().getParameters().get('value');

        // Check if feedback already exists
        List<Custom_Survey__c> surveyList = [SELECT Id, Name, Customer_Closed_Won_Lost_Comments__c FROM Custom_Survey__c WHERE Opportunity__c = :oppId LIMIT 1];

        if (!surveyList.isEmpty()) {
            success = true;
            showOther = false;
            USER_MESSAGE = 'Feedback already submitted!';
            return;
        }

        success = false;
        showOther = (picklistValue == 'Other');
    }

    public void doInit() {
        if (success) {
            return; // Already submitted
        }

        if (String.isNotBlank(oppId) && String.isNotBlank(picklistValue) && picklistValue != 'Other') {
            try {
                createCustomSurvey(oppId, picklistValue, '');
                success = true;
                showOther = false;
            } catch (Exception e) {
                ApexLogUtill.createApexLog('OpportunityResponse.doInit', picklistValue, e.getMessage(), oppId, 'Opportunity', e.getMessage(), 0);
            }
        } else {
            showOther = true;
        }
    }

    public PageReference submitFeedback() {
        if (String.isBlank(feedbackText)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Feedback cannot be empty.'));
            return null;
        }

        try {
           // createCustomSurvey(oppId, '', feedbackText);
            createCustomSurvey(oppId, 'Other', feedbackText);
            success = true;
            showOther = false;
        } catch (Exception e) {
            ApexLogUtill.createApexLog('OpportunityResponse.submitFeedback', picklistValue, e.getMessage(), oppId, 'Opportunity', e.getMessage(), 0);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while submitting feedback.'));
        }
        return null;
    }

    private void createCustomSurvey(String oppId, String picklistValue, String feedbackText) {
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1];

        // Check again to avoid duplicates
        List<Custom_Survey__c> existing = [SELECT Id FROM Custom_Survey__c WHERE Opportunity__c = :oppId LIMIT 1];

        if (!existing.isEmpty()) {
            USER_MESSAGE = 'Feedback already submitted!';
            success = true;
            showOther = false;
            return;
        }

        Custom_Survey__c cs = new Custom_Survey__c();
        cs.Customer_Closed_Lost_Reason__c = picklistValue;
        cs.Opportunity__c = opp.Id;
        cs.Survey_Type__c = 'Opportunity Survey';
        cs.Account_Name__c = opp.AccountId;
        cs.Customer_Closed_Won_Lost_Comments__c = feedbackText;

        insert cs;
        USER_MESSAGE = 'Thank you for your feedback!';
    }
}