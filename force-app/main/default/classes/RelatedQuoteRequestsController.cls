public with sharing class RelatedQuoteRequestsController {
    @AuraEnabled(cacheable=true)
    public static List<Quote_Product__c> getRelatedQuoteRequests(String opportunityId) {
        system.debug('oppid@@@@@'+ opportunityId);
        List<Quote_Request__c>QuoteRequestList = new list<Quote_Request__c>();
        QuoteRequestList =[SELECT Id FROM Quote_Request__c WHERE Opportunity__c = :opportunityId ];
        List<Quote_Product__c>Quoteproducts =[SELECT Id, Name,Quote_Number__c,Quote_Request__c,	Quantity__c,Products__r.Name FROM Quote_Product__c where Quote_Request__c IN:QuoteRequestList ];
    return Quoteproducts;
    }
    
}