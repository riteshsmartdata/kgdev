public without sharing class AccountCaseSentimentBatch
    implements Database.Batchable<SObject>, Schedulable {

    private static final Integer DEFAULT_BATCH_SIZE = 200;

    private static final String PHASE_RESET = 'RESET';
    private static final String PHASE_CALCULATE = 'CALCULATE';

    private static final String LAST_MONTH_LITERAL = 'LAST_MONTH';
    private static final String THIS_MONTH_LITERAL = 'THIS_MONTH';

    private static final String LABEL_SPLIT_REGEX = '\\|';

    @TestVisible
    private String executionPhase;

    @TestVisible
    private String caseDateLiteral;

    @TestVisible
    private Boolean chainNextPhase;

    public AccountCaseSentimentBatch() {
        this(
            PHASE_RESET,
            LAST_MONTH_LITERAL,
            true
        );
    }

    private AccountCaseSentimentBatch(String requestedPhase) {
        this(
            requestedPhase,
            LAST_MONTH_LITERAL,
            true
        );
    }

    @TestVisible
    private AccountCaseSentimentBatch(
        String requestedPhase,
        String requestedDateLiteral,
        Boolean shouldChainNextPhase
    ) {
        validatePhase(requestedPhase);
        validateDateLiteral(requestedDateLiteral);

        executionPhase = requestedPhase;
        caseDateLiteral = requestedDateLiteral;
        chainNextPhase = shouldChainNextPhase;
    }

    public Database.QueryLocator start(
        Database.BatchableContext batchContext
    ) {
        if (executionPhase == PHASE_RESET) {
            return Database.getQueryLocator(
                buildResetAccountQuery()
            );
        }

        Set<String> excludedReasons =
            getExcludedCaseReasons();

        Map<String, Object> bindVariables =
            new Map<String, Object>();

        String accountQuery =
            buildEligibleAccountQuery(
                excludedReasons,
                bindVariables,
                caseDateLiteral
            );

        return Database.getQueryLocatorWithBinds(
            accountQuery,
            bindVariables,
            AccessLevel.SYSTEM_MODE
        );
    }

    public void execute(
        Database.BatchableContext batchContext,
        List<SObject> batchScope
    ) {
        if (
            batchScope == null ||
            batchScope.isEmpty()
        ) {
            return;
        }

        List<Account> accountScope =
            new List<Account>();

        for (SObject scopeRecord : batchScope) {
            accountScope.add(
                (Account) scopeRecord
            );
        }

        if (executionPhase == PHASE_RESET) {
            resetExistingAccountAverages(
                accountScope
            );
        } else {
            calculateAccountAverages(
                accountScope,
                caseDateLiteral
            );
        }
    }

    public void finish(
        Database.BatchableContext batchContext
    ) {
        if (
            executionPhase == PHASE_RESET &&
            chainNextPhase
        ) {
            Database.executeBatch(
                new AccountCaseSentimentBatch(
                    PHASE_CALCULATE,
                    caseDateLiteral,
                    false
                ),
                DEFAULT_BATCH_SIZE
            );
        }
    }

    public void execute(
        SchedulableContext schedulableContext
    ) {
        Database.executeBatch(
            new AccountCaseSentimentBatch(
                PHASE_RESET,
                LAST_MONTH_LITERAL,
                !Test.isRunningTest()
            ),
            DEFAULT_BATCH_SIZE
        );
    }

    private static void resetExistingAccountAverages(
        List<Account> accountScope
    ) {
        List<Account> accountsToReset =
            new List<Account>();

        for (Account accountRecord : accountScope) {
            accountsToReset.add(
                new Account(
                    Id = accountRecord.Id,
                    Average_Case_Sentiment_Score__c = null
                )
            );
        }

        performPartialUpdate(
            accountsToReset,
            PHASE_RESET
        );
    }

    /**
     * Calculates and stores eligible Case sentiment averages.
     */
    private static void calculateAccountAverages(
        List<Account> accountScope,
        String dateLiteral
    ) {
        Set<Id> accountIds =
            new Map<Id, Account>(
                accountScope
            ).keySet();

        Set<String> excludedReasons =
            getExcludedCaseReasons();

        Map<String, Object> bindVariables =
            new Map<String, Object>{
                'accountIds' => accountIds
            };

        String aggregateQuery =
            buildAggregateCaseQuery(
                excludedReasons,
                bindVariables,
                dateLiteral
            );

        List<AggregateResult> aggregateResults =
            (List<AggregateResult>)
            Database.queryWithBinds(
                aggregateQuery,
                bindVariables,
                AccessLevel.SYSTEM_MODE
            );

        List<Account> accountsToUpdate =
            new List<Account>();

        for (
            AggregateResult aggregateResult :
            aggregateResults
        ) {
            SentimentAggregateWrapper sentimentResult =
                new SentimentAggregateWrapper(
                    aggregateResult
                );

            if (
                sentimentResult.accountId == null ||
                sentimentResult.averageScore == null
            ) {
                continue;
            }

            accountsToUpdate.add(
                new Account(
                    Id = sentimentResult.accountId,
                    Average_Case_Sentiment_Score__c =
                        sentimentResult.averageScore.setScale(2)
                )
            );
        }

        performPartialUpdate(
            accountsToUpdate,
            PHASE_CALCULATE
        );
    }

    private static Set<String> getExcludedCaseReasons() {
        Set<String> excludedReasons =
            new Set<String>();

        String configuredReasons =
            System.Label.Excluded_Case_Reason_Types;

        if (String.isBlank(configuredReasons)) {
            return excludedReasons;
        }

        for (
            String configuredReason :
            configuredReasons.split(
                LABEL_SPLIT_REGEX
            )
        ) {
            String normalizedReason =
                configuredReason == null
                    ? null
                    : configuredReason.trim();

            if (
                String.isNotBlank(
                    normalizedReason
                )
            ) {
                excludedReasons.add(
                    normalizedReason
                );
            }
        }

        return excludedReasons;
    }

    private static String buildResetAccountQuery() {
        return String.join(
            new List<String>{
                'SELECT Id, Average_Case_Sentiment_Score__c',
                'FROM Account',
                'WHERE Average_Case_Sentiment_Score__c != NULL'
            },
            ' '
        );
    }

    private static String buildEligibleAccountQuery(
        Set<String> excludedReasons,
        Map<String, Object> bindVariables,
        String dateLiteral
    ) {
        validateDateLiteral(dateLiteral);

        List<String> queryParts =
            new List<String>{
                'SELECT Id, Average_Case_Sentiment_Score__c',
                'FROM Account',
                'WHERE Id IN (',
                'SELECT AccountId',
                'FROM Case',
                'WHERE AccountId != NULL',
                'AND LastModifiedDate = ' + dateLiteral,
                'AND Sentiment_Score__c >= 1',
                'AND Sentiment_Score__c <= 5'
            };

        addReasonExclusionCondition(
            queryParts,
            excludedReasons,
            bindVariables
        );

        queryParts.add(')');

        return String.join(
            queryParts,
            ' '
        );
    }

    private static String buildAggregateCaseQuery(
        Set<String> excludedReasons,
        Map<String, Object> bindVariables,
        String dateLiteral
    ) {
        validateDateLiteral(dateLiteral);

        List<String> queryParts =
            new List<String>{
                'SELECT',
                'AccountId accountId,',
                'COUNT(Id) eligibleCaseCount,',
                'SUM(Sentiment_Score__c) totalScore,',
                'AVG(Sentiment_Score__c) averageScore',
                'FROM Case',
                'WHERE AccountId IN :accountIds',
                'AND LastModifiedDate = ' + dateLiteral,
                'AND Sentiment_Score__c >= 1',
                'AND Sentiment_Score__c <= 5'
            };

        addReasonExclusionCondition(
            queryParts,
            excludedReasons,
            bindVariables
        );

        queryParts.add(
            'GROUP BY AccountId'
        );

        return String.join(
            queryParts,
            ' '
        );
    }

    private static void addReasonExclusionCondition(
        List<String> queryParts,
        Set<String> excludedReasons,
        Map<String, Object> bindVariables
    ) {
        if (
            excludedReasons == null ||
            excludedReasons.isEmpty()
        ) {
            return;
        }

        bindVariables.put(
            'excludedReasons',
            excludedReasons
        );

        queryParts.add(
            'AND (' +
            'Case_Reason_Type__c = NULL ' +
            'OR Case_Reason_Type__c NOT IN :excludedReasons' +
            ')'
        );
    }

    private static void performPartialUpdate(
        List<Account> accountsToUpdate,
        String currentPhase
    ) {
        if (
            accountsToUpdate == null ||
            accountsToUpdate.isEmpty()
        ) {
            return;
        }

        Database.SaveResult[] saveResults =
            Database.update(
                accountsToUpdate,
                false
            );

        for (
            Integer index = 0;
            index < saveResults.size();
            index++
        ) {
            if (
                saveResults[index].isSuccess()
            ) {
                continue;
            }

            logUpdateErrors(
                accountsToUpdate[index].Id,
                saveResults[index].getErrors(),
                currentPhase
            );
        }
    }

    private static void logUpdateErrors(
        Id accountId,
        List<Database.Error> updateErrors,
        String currentPhase
    ) {
        for (
            Database.Error updateError :
            updateErrors
        ) {
            System.debug(
                LoggingLevel.ERROR,
                'Account sentiment update failed.' +
                ' Phase=' + currentPhase +
                ', AccountId=' + accountId +
                ', StatusCode=' +
                    updateError.getStatusCode() +
                ', Message=' +
                    updateError.getMessage() +
                ', Fields=' +
                    String.valueOf(
                        updateError.getFields()
                    )
            );
        }
    }

    private static void validatePhase(
        String requestedPhase
    ) {
        if (
            requestedPhase != PHASE_RESET &&
            requestedPhase != PHASE_CALCULATE
        ) {
            throw new AccountCaseSentimentException(
                'Unsupported execution phase: ' +
                requestedPhase
            );
        }
    }

    private static void validateDateLiteral(
        String requestedDateLiteral
    ) {
        if (
            requestedDateLiteral != LAST_MONTH_LITERAL &&
            requestedDateLiteral != THIS_MONTH_LITERAL
        ) {
            throw new AccountCaseSentimentException(
                'Unsupported date literal: ' +
                requestedDateLiteral
            );
        }
    }

    private class SentimentAggregateWrapper {

        private Id accountId;
        private Integer eligibleCaseCount;
        private Decimal totalScore;
        private Decimal averageScore;

        private SentimentAggregateWrapper(
            AggregateResult aggregateResult
        ) {
            if (aggregateResult == null) {
                return;
            }

            accountId =
                (Id) aggregateResult.get(
                    'accountId'
                );

            totalScore =
                (Decimal) aggregateResult.get(
                    'totalScore'
                );

            averageScore =
                (Decimal) aggregateResult.get(
                    'averageScore'
                );

            Object countValue =
                aggregateResult.get(
                    'eligibleCaseCount'
                );

            if (countValue != null) {
                eligibleCaseCount =
                    Integer.valueOf(
                        String.valueOf(
                            countValue
                        )
                    );
            }
        }
    }

    public class AccountCaseSentimentException
        extends Exception {
    }
}