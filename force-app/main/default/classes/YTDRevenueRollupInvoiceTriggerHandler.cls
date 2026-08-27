public with sharing class YTDRevenueRollupInvoiceTriggerHandler {
    /**
     * handler to keep the trigger code-free and reusable.
     * Use YTDRevenueRollupService so both
     * trigger and batch share the same logic.
     * For after insert:
     *   - Requires Account__c and Order__c not null
     *   - Invoice_Date__c must be within the current calendar year
     *   - Filter to Customers Account record type via YTDRevenueRollupService.getCustomerAccountIds
     *   - Invoke YTDRevenueRollupService.updateYTDRevenue on filtered set
     */
    public static void afterInsert(List<Invoice__c> newList) {
        if (newList == null || newList.isEmpty()) return;

        // Current year range per requirement
        Date startOfYear = Date.newInstance(System.today().year(), 1, 1);
        Date endOfYear   = Date.newInstance(System.today().year(), 12, 31);

        Set<Id> AccountIds = new Set<Id>();

        for (Invoice__c inv : newList) {
            // Must have Account and Order and invoice date within current year
            if (inv.Account__c != null && inv.Order__c != null &&
                inv.Invoice_Date__c != null &&
                inv.Invoice_Date__c >= startOfYear && inv.Invoice_Date__c <= endOfYear && inv.Type__c == 'INVOICE') {
                AccountIds.add(inv.Account__c);
            }
        }

        if (!AccountIds.isEmpty()) {
            // Filter Customer Accounts via shared service, then update revenue via the same service
            Set<Id> customerAccIds = YTDRevenueRollupService.getCustomerAccountIds(AccountIds);
            if (!customerAccIds.isEmpty()) {
                YTDRevenueRollupService.updateYTDRevenue(customerAccIds);
            }
        }
    }
}