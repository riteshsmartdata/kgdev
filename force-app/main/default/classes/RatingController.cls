public without sharing class RatingController 
{
    public  String  headerdata{get;set;}
    public string urlvalue{get;set;}
    public string url{get;set;}    
    public string urlCaseId{get;set;}
    public string urlFeedback{get;set;}
    public string urlFeedbackUniqueCode{get;set;}
    public string CaseOwnerid{get;set;}
    public string displayMessage{get;set;}
    public Boolean createSurvey = false;
    
    public RatingController()
    {
        headerData= ApexPages.currentPage().getHeaders().get('Host');
        system.debug('Header '+headerData); 
        
        urlvalue=Apexpages.currentPage().getUrl();        
        
        url='https://' + headerdata+ urlvalue;        
        
        urlCaseId = Apexpages.currentpage().getparameters().get('caseId');
        system.debug('Case Id from Url '+urlCaseId);
        
        CaseOwnerid = Apexpages.currentpage().getparameters().get('CaseOwnerid');
        
        urlFeedback = Apexpages.currentpage().getparameters().get('feedback');
        system.debug('Feedback from Url '+urlFeedback);
        
        urlFeedbackUniqueCode = Apexpages.currentpage().getparameters().get('feedbackuniquecode');
        system.debug('Feedback from Url '+urlFeedbackUniqueCode);
        
        
        List<Custom_Survey__c> csList = [SELECT Id, Feedback_Unique_Code__c, Case__c FROM Custom_Survey__c WHERE Case__c =: urlCaseId And Feedback_Unique_Code__c =:urlFeedbackUniqueCode LIMIT 50000];		
        
        if (csList.isEmpty())
        {
            displayMessage = 'Thank you for your feedback';
            createSurvey = true;
            
        }
        else{
            displayMessage = 'The Feedback has been already submitted';
        }
    }
    public PageReference createRecordFromURLRating()
    {
        
        List<Case> caseWithContact = [SELECT Id, ContactId,AccountId FROM Case WHERE ID =: urlCaseId LIMIT 1];
        
        if(createSurvey){
            Custom_Survey__c cs = new Custom_Survey__c();
            cs.Case__c = urlCaseId;
            cs.Email_Case_Feedback__c = urlFeedback;
            cs.Survey_Type__c = 'Email Case Survey';
            cs.Feedback_Unique_Code__c = urlFeedbackUniqueCode;
            if(!test.isRunningTest()){
                cs.OwnerId   = CaseOwnerid;
                
            }
            if(!caseWithContact.isempty()){
                cs.Contact_Name__c = caseWithContact[0].ContactId;
                cs.Account_Name__c = caseWithContact[0].AccountId;
            }
            insert cs;
          
        }
        
        return null;
    }
    
}