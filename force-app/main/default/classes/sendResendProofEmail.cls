public without sharing class sendResendProofEmail {

    //Get the object type and record ID 
    @InvocableMethod(label='Resend Proof Email Module' description='Resend emails for proofs.' category='Case')
    public static void sendResendProofNotification(List<String> caseRecordString){

        resendProofClarEmails.resendEmail(caseRecordString, 'Proof');
        
    } 
}