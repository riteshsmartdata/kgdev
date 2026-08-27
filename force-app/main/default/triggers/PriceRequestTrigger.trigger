trigger PriceRequestTrigger on Inquiry__c (before insert, before update) {
    PriceRequestTriggerHelper.priceRequestAddValidation(trigger.new);
    
}