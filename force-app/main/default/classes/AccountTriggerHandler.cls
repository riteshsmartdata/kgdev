/**
* @description       : 
* @author            : ritesh.kumar@kooziegroup.com
* @group             : 
* @last modified on  : 10-17-2025
* @last modified by  : kumar.s@kooziegroup.com
**/
public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newRecords;
    private Map<Id, Account> oldRecords;

    private static final Trigger_Settings__mdt triggerSetting =
        Trigger_Settings__mdt.getInstance('Account');

    public AccountTriggerHandler(String className) {
        this.newRecords = (List<Account>) Trigger.new;
        this.oldRecords = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void afterUpdate() {

        // Master kill switch via metadata
        if (triggerSetting == null || triggerSetting.Is_Active__c == false) {
            return;
        }

        // Prevent recursion
        if (KoozieUtility.isRecursion == false) {
            return;
        }

        Map<Id, String> accountStatusMap = new Map<Id, String>();

        for (Account acc : newRecords) {
            Account oldAcc = oldRecords.get(acc.Id);

            // Detect Active → Inactive
            if (
                acc.Status__c == 'Inactive' && oldAcc.Status__c != 'Inactive') {
                accountStatusMap.put(acc.Id, acc.Status__c);
            }
        }

        if (!accountStatusMap.isEmpty()) {
            // Flip recursion flag BEFORE async
            KoozieUtility.isRecursion = false;

            System.enqueueJob(
                new AccountContactStatusSync(accountStatusMap)
            );
        }
    }
}