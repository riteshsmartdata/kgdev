/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-15-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   01-25-2023   Ritesh Kumar   Initial Version
**/
public without sharing class PopulateEmailSubject {

    /**
     * Description : method is used in flows to get email subject.
     * Param : emailvalueList : hold the record information (wrapper Class)
     */

    @InvocableMethod(label='Get Subject on Notification Record')
    public static List<Result> populateSubject(List<EmailValues> emailvalueList){
        String contactId = '';
        String orderId = '';
        String templateId = '';
        EmailTemplate template = new EmailTemplate(); 
        List<Result> results = new List<Result>();  

        if(!emailvalueList.isEmpty()){
            for(EmailValues value : emailvalueList ){
               //System.debug('==== Email  ===='+value);
                if(String.isNotBlank(value.ContactId)){
                    contactId  = value.ContactId;
                }

                if(String.isNotBlank(value.orderId)){
                    orderId  = value.orderId;
                }

                if(String.isNotBlank(value.templateId)){
                    templateId  = value.templateId;
                }
            }
        }  
        if(String.isNotBlank(templateId)){
           //System.debug('==== templateId : '+templateId+' =======contactId : '+contactId+'======== orderId: '+orderId);
            Messaging.SingleEmailMessage emailRecord = Messaging.renderStoredEmailTemplate(templateId, contactId != 'NULL' ? contactId: null,orderId);  
            Result data = new Result();
            data.subject = emailRecord.getSubject();
            data.body = emailRecord.getHtmlBody().replace('p{margin-top:0px; margin-bottom:0px;}', '');
            results.add(data);
        }
       //System.debug('==== subjectList  ===='+results);
        return results;
    }


    /**
     * Description: EmailValues class is used to get input from flows.
     */
    public class EmailValues {

        @InvocableVariable( required=false description='Contact Record Id' label='Contact Id')
        public String ContactId;

        @InvocableVariable(required=false description='EBS Order Id' label='EBS Order Id')
        public String orderId; 

        @InvocableVariable(required=false description='Template Id' label='Template Id')
        public String templateId;  

    }

     /**
     * Description: Result class is used to send output to flows.
     */
    public class Result {

        @InvocableVariable(required=true description='Email Subject' label='Email Subject')
        public String subject;

        @InvocableVariable(required=false description='Email Body' label='Email Body')
        public String body;  

    }
 
}