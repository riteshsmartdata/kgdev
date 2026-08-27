public with sharing class EbsOrderEmailMessageController {
    
    // Wrapper class for EmailMessage
    public class EmailMessageWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Subject { get; set; }
        @AuraEnabled public String FromAddress { get; set; }
        @AuraEnabled public String ToAddress { get; set; }
        @AuraEnabled public String TextBody { get; set; }
        @AuraEnabled public String ParentId { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        
        // Constructor to initialize the fields
        public EmailMessageWrapper(EmailMessage email) {
            this.Id = email.Id;
            this.Subject = email.Subject;
            this.FromAddress = email.FromAddress;
            this.ToAddress = email.ToAddress;
            this.TextBody = email.TextBody;
            this.CreatedDate = email.CreatedDate;
            this.ParentId = email.ParentId;
        }
    }
    
    // Apex method to fetch Email Messages associated with the cases of a specific EBS Order
    @AuraEnabled(cacheable=true)
    public static List<EmailMessageWrapper> getEmailMessagesFromEbsOrder(Id ebsOrderId) {
        List<EmailMessageWrapper> emailMessages = new List<EmailMessageWrapper>();
        try {
            // Query to retrieve Email Messages from cases related to the EBS Order
            List<EBS_Order__c> ebsOrders = [
                SELECT Id, 
                (SELECT Id, 
                 CaseNumber, 
                 (SELECT Id, Subject, ParentId, FromAddress, ToAddress, TextBody, CreatedDate 
                  FROM EmailMessages ORDER BY CreatedDate DESC) 
                 FROM Cases__r) 
                FROM EBS_Order__c 
                WHERE Id = :ebsOrderId
            ];
            
            // Loop through the EBS Orders and their cases to get email messages
            for (EBS_Order__c order : ebsOrders) {
                for (Case caseRec : order.Cases__r) {
                    for (EmailMessage email : caseRec.EmailMessages) {
                        emailMessages.add(new EmailMessageWrapper(email));
                    }
                }
            }
            
        } catch (Exception e) {
            ApexLogUtill.createApexLog('EmailMessageWrapper.getEmailMessagesFromEbsOrder', 'EmailMessage' , e.getMessage(), ebsOrderId, 'EBS_Order__c', e.getMessage(), 0);
        }
        
        return emailMessages;
    }
}