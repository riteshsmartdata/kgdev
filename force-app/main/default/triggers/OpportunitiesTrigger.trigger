trigger OpportunitiesTrigger on Opportunity (before insert) {
    OpportunityTriggerHelper.pricerequestcaseassign(trigger.new);
}