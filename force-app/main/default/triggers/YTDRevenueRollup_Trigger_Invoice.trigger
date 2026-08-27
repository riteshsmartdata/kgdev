trigger YTDRevenueRollup_Trigger_Invoice on Invoice__c (after insert) {
    //handler to keep trigger code-free and reuse service logic
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('Invoice');
    if(triggerSetting.Is_Active__c == TRUE){
        YTDRevenueRollupInvoiceTriggerHandler.afterInsert(Trigger.new);
    }
}