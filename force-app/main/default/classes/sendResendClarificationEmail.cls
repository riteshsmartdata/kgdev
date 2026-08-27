public without sharing class sendResendClarificationEmail {

    //Get the object type and record ID 
    @InvocableMethod(label='Resend Clarification Email Module' description='Resend emails for clarifications.' category='Case')
    public static void sendResendClarificationNotification(List<String> caseRecordString){
        
        resendProofClarEmails.resendEmail(caseRecordString, 'Clarification');

    }
}