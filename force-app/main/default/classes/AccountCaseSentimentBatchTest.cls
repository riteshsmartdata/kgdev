@IsTest
private class AccountCaseSentimentBatchTest {

    private static final String PHASE_RESET =
        'RESET';

    private static final String PHASE_CALCULATE =
        'CALCULATE';

    private static final String THIS_MONTH_LITERAL =
        'THIS_MONTH';

    private static final String ACCOUNT_CALCULATION =
        'UT Sentiment Calculation Account';

    private static final String ACCOUNT_RESET =
        'UT Sentiment Reset Account';

    private static final String ACCOUNT_EXCLUDED =
        'UT Sentiment Excluded Account';

    @TestSetup
    static void createTestData() {
        List<Account> testAccounts =
            new List<Account>{
                new Account(
                    Name = ACCOUNT_CALCULATION
                ),
                new Account(
                    Name = ACCOUNT_RESET,
                    Average_Case_Sentiment_Score__c = 4.75
                ),
                new Account(
                    Name = ACCOUNT_EXCLUDED,
                    Average_Case_Sentiment_Score__c = 2.50
                )
            };

        insert testAccounts;

        Map<String, Id> accountIdsByName =
            new Map<String, Id>();

        for (
            Account accountRecord :
            testAccounts
        ) {
            accountIdsByName.put(
                accountRecord.Name,
                accountRecord.Id
            );
        }

        String activeStatus =
            getFirstActivePicklistValue(
                Case.Status
            );

        String activeOrigin =
            getFirstActivePicklistValue(
                Case.Origin
            );

        List<Case> casesToInsert =
            new List<Case>();

        casesToInsert.add(
            createCase(
                accountIdsByName.get(
                    ACCOUNT_CALCULATION
                ),
                'UT eligible sentiment 1',
                1,
                null,
                activeStatus,
                activeOrigin
            )
        );

        casesToInsert.add(
            createCase(
                accountIdsByName.get(
                    ACCOUNT_CALCULATION
                ),
                'UT eligible sentiment 3',
                3,
                null,
                activeStatus,
                activeOrigin
            )
        );

        casesToInsert.add(
            createCase(
                accountIdsByName.get(
                    ACCOUNT_CALCULATION
                ),
                'UT eligible sentiment 5',
                5,
                null,
                activeStatus,
                activeOrigin
            )
        );

        casesToInsert.add(
            createCase(
                accountIdsByName.get(
                    ACCOUNT_CALCULATION
                ),
                'UT null sentiment',
                null,
                null,
                activeStatus,
                activeOrigin
            )
        );

        String excludedReason =
            getActiveExcludedReason();

        if (
            String.isNotBlank(
                excludedReason
            )
        ) {
            casesToInsert.add(
                createCase(
                    accountIdsByName.get(
                        ACCOUNT_CALCULATION
                    ),
                    'UT excluded sentiment 5',
                    5,
                    excludedReason,
                    activeStatus,
                    activeOrigin
                )
            );

            casesToInsert.add(
                createCase(
                    accountIdsByName.get(
                        ACCOUNT_EXCLUDED
                    ),
                    'UT excluded-only sentiment',
                    1,
                    excludedReason,
                    activeStatus,
                    activeOrigin
                )
            );
        }

        insert casesToInsert;
    }

    @IsTest
    static void shouldResetExistingAverages() {
        Test.startTest();

        Database.executeBatch(
            new AccountCaseSentimentBatch(
                PHASE_RESET,
                THIS_MONTH_LITERAL,
                false
            ),
            200
        );

        Test.stopTest();

        Map<String, Account> accountsByName =
            getTestAccountsByName();

        System.assertEquals(
            null,
            accountsByName
                .get(ACCOUNT_RESET)
                .Average_Case_Sentiment_Score__c,
            'The RESET phase should clear an existing average.'
        );

        System.assertEquals(
            null,
            accountsByName
                .get(ACCOUNT_EXCLUDED)
                .Average_Case_Sentiment_Score__c,
            'The RESET phase should clear the old excluded Account value.'
        );

        System.assertEquals(
            null,
            accountsByName
                .get(ACCOUNT_CALCULATION)
                .Average_Case_Sentiment_Score__c,
            'An Account that was already blank should remain blank.'
        );
    }

    @IsTest
    static void shouldCalculateEligibleCaseAverage() {
        Test.startTest();

        Database.executeBatch(
            new AccountCaseSentimentBatch(
                PHASE_CALCULATE,
                THIS_MONTH_LITERAL,
                false
            ),
            200
        );

        Test.stopTest();

        Map<String, Account> accountsByName =
            getTestAccountsByName();

        System.assertEquals(
            Decimal.valueOf('3.00'),
            accountsByName
                .get(ACCOUNT_CALCULATION)
                .Average_Case_Sentiment_Score__c,
            'The calculated Account average is incorrect.'
        );

        System.assertEquals(
            Decimal.valueOf('4.75'),
            accountsByName
                .get(ACCOUNT_RESET)
                .Average_Case_Sentiment_Score__c,
            'CALCULATE should not change an Account without eligible Cases.'
        );

        if (
            String.isNotBlank(
                getActiveExcludedReason()
            )
        ) {
            System.assertEquals(
                Decimal.valueOf('2.50'),
                accountsByName
                    .get(ACCOUNT_EXCLUDED)
                    .Average_Case_Sentiment_Score__c,
                'An Account having only excluded Cases should not be recalculated.'
            );
        }
    }

    @IsTest
    static void shouldHandleEmptyBatchScope() {
        AccountCaseSentimentBatch batchInstance =
            new AccountCaseSentimentBatch(
                PHASE_CALCULATE,
                THIS_MONTH_LITERAL,
                false
            );

        Test.startTest();

        batchInstance.execute(
            null,
            new List<SObject>()
        );

        Test.stopTest();

        System.assertEquals(
            PHASE_CALCULATE,
            batchInstance.executionPhase,
            'The empty-scope execution should exit safely.'
        );
    }

    @IsTest
    static void shouldHandleAccountWithoutEligibleCases() {
        Account resetOnlyAccount = [
            SELECT
                Id,
                Average_Case_Sentiment_Score__c
            FROM Account
            WHERE Name = :ACCOUNT_RESET
            LIMIT 1
        ];

        AccountCaseSentimentBatch batchInstance =
            new AccountCaseSentimentBatch(
                PHASE_CALCULATE,
                THIS_MONTH_LITERAL,
                false
            );

        Test.startTest();

        batchInstance.execute(
            null,
            new List<SObject>{
                resetOnlyAccount
            }
        );

        Test.stopTest();

        Account updatedAccount = [
            SELECT Average_Case_Sentiment_Score__c
            FROM Account
            WHERE Id = :resetOnlyAccount.Id
        ];

        System.assertEquals(
            Decimal.valueOf('4.75'),
            updatedAccount
                .Average_Case_Sentiment_Score__c,
            'No DML should occur when no aggregate result exists.'
        );
    }

    @IsTest
    static void shouldInvokeSchedulableEntryPoint() {
        Test.startTest();

        new AccountCaseSentimentBatch().execute(
            (SchedulableContext) null
        );

        Test.stopTest();

        Integer submittedBatchJobs = [
            SELECT COUNT()
            FROM AsyncApexJob
            WHERE ApexClass.Name =
                'AccountCaseSentimentBatch'
        ];

        System.assert(
            submittedBatchJobs > 0,
            'The Schedulable entry point should submit a batch job.'
        );
    }

@IsTest
static void shouldRejectInvalidPhase() {
    Boolean exceptionThrown = false;

    try {
        new AccountCaseSentimentBatch(
            'INVALID_PHASE',
            THIS_MONTH_LITERAL,
            false
        );
    } catch (AccountCaseSentimentBatch.AccountCaseSentimentException expectedException) {
        exceptionThrown = true;

        System.assert(
            expectedException.getMessage().contains(
                'Unsupported execution phase'
            ),
            'The invalid-phase error message is incorrect.'
        );
    }

    System.assertEquals(
        true,
        exceptionThrown,
        'An invalid phase should throw an exception.'
    );
}

 @IsTest
static void shouldRejectInvalidDateLiteral() {
    Boolean exceptionThrown = false;

    try {
        new AccountCaseSentimentBatch(
            PHASE_CALCULATE,
            'YESTERDAY',
            false
        );
    } catch (AccountCaseSentimentBatch.AccountCaseSentimentException expectedException) {
        exceptionThrown = true;

        System.assert(
            expectedException.getMessage().contains(
                'Unsupported date literal'
            ),
            'The invalid-date error message is incorrect.'
        );
    }

    System.assertEquals(
        true,
        exceptionThrown,
        'An invalid date literal should throw an exception.'
    );
}

    private static Case createCase(
        Id accountId,
        String caseSubject,
        Decimal sentimentScore,
        String reasonType,
        String activeStatus,
        String activeOrigin
    ) {
        return new Case(
            AccountId = accountId,
            Subject = caseSubject,
            Status = activeStatus,
            Origin = activeOrigin,
            Sentiment_Score__c = sentimentScore,
            Case_Reason_Type__c = reasonType
        );
    }

    private static String getFirstActivePicklistValue(
        Schema.SObjectField fieldToken
    ) {
        for (
            Schema.PicklistEntry picklistEntry :
            fieldToken
                .getDescribe()
                .getPicklistValues()
        ) {
            if (picklistEntry.isActive()) {
                return picklistEntry.getValue();
            }
        }

        System.assert(
            false,
            'No active picklist value exists for ' +
            fieldToken
                .getDescribe()
                .getName()
        );

        return null;
    }

    private static String getActiveExcludedReason() {
        Set<String> labelReasons =
            new Set<String>();

        String labelValue =
            System.Label.Excluded_Case_Reason_Types;

        if (String.isBlank(labelValue)) {
            return null;
        }

        for (
            String configuredReason :
            labelValue.split('\\|')
        ) {
            if (
                String.isNotBlank(
                    configuredReason
                )
            ) {
                labelReasons.add(
                    configuredReason.trim()
                );
            }
        }

        for (
            Schema.PicklistEntry picklistEntry :
            Case.Case_Reason_Type__c
                .getDescribe()
                .getPicklistValues()
        ) {
            if (
                picklistEntry.isActive() &&
                labelReasons.contains(
                    picklistEntry.getValue()
                )
            ) {
                return picklistEntry.getValue();
            }
        }

        return null;
    }

    private static Map<String, Account>
        getTestAccountsByName() {

        Map<String, Account> accountsByName =
            new Map<String, Account>();

        for (
            Account accountRecord :
            [
                SELECT
                    Id,
                    Name,
                    Average_Case_Sentiment_Score__c
                FROM Account
                WHERE Name IN (
                    :ACCOUNT_CALCULATION,
                    :ACCOUNT_RESET,
                    :ACCOUNT_EXCLUDED
                )
            ]
        ) {
            accountsByName.put(
                accountRecord.Name,
                accountRecord
            );
        }

        return accountsByName;
    }
}