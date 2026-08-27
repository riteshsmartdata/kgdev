trigger MarketingProjectsTrigger on Marketing_Projects__c (after insert) {
    SendEmailMarketingProjectsHelper.sendEmail(trigger.new);
}