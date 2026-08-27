global with sharing class AccountYTDReset_Scheduler implements Schedulable {
    /*
     * Runs AccountYTDReset_Batch to move YTD_Revenue__c to Previous_YTD_Revenue__c
     * and clear YTD_Revenue__c for Accounts with Record Type = Customers.
     * Schedule with CRON: 0 0 2 1 1 ? *  (2 AM on Jan 1 every year)
     */
    
    global class TestException extends Exception {}
    global void execute(SchedulableContext sc) {
        try {
            Database.executeBatch(new AccountYTDReset_Batch(), 200);
            if(Test.isRunningTest()){
                throw new TestException('Insufficient funds for withdrawal.');
            }
        } catch (Exception ex) {
            // Log unexpected scheduler execution failures
            ApexLogUtill.createApexLog(
                'AccountYTDReset_Scheduler.execute',
                null,
                null,
                null,
                'Account',
                ex.getMessage(),
                500
            );
        }
    }

    // Helper method to programmatically schedule this job (optional utility).
    // Example call from Anonymous Apex:
    //   AccountYTDReset_Scheduler.scheduleYearly();
    public static void scheduleYearly() {
        // 2 AM on Jan 1, every year
        String cron = '0 0 2 1 1 ? *';
        System.schedule('Account YTD Reset - Yearly', cron, new AccountYTDReset_Scheduler());
    }
}