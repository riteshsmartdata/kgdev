public class SendEmailMarketingProjectsHelper {
    public static boolean isTriggerRunning = false;

    public static void sendEmail(List<Marketing_Projects__c> marketingProjectsList) {

        if (isTriggerRunning) {
            return; // Avoid recursion
        }

        try {
            isTriggerRunning = true;

            OrgWideEmailAddress owea = [
                SELECT Id, Address, DisplayName
                FROM OrgWideEmailAddress
                WHERE Address = 'marketing@kooziegroup.com'
                LIMIT 1
            ];

            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

            for (Marketing_Projects__c marp : marketingProjectsList) {

                if (marp.Submitter_Email__c != null) {

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    if (owea != null) {
                        mail.setOrgWideEmailAddressId(owea.Id);
                    }

                    mail.setToAddresses(new String[]{marp.Submitter_Email__c});
                    mail.setSubject('Marketing Project Submitted');

                    String emailBody = 'Thanks for submitting your marketing project. ' +
                                       'For reference, your project number is ' + marp.Name + '. ' +
                                       'We’ll send you an alert from SmartSheet when the first proof is ready for your review.';

                    mail.setPlainTextBody(emailBody);

                    emailList.add(mail);
                }
            }

            if(!emailList.isEmpty()){
                Messaging.sendEmail(emailList);
            }

        } catch(Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
        } finally {
            isTriggerRunning = false;
        }
    }
}