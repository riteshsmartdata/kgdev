@IsTest
private class AccountContactRelationCleanupBatchTest {

    @IsTest
    static void testBatchCoverage() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        // Create two Accounts
        Account mainAcc = new Account(Name = 'Main Account');
        Account relAcc = new Account(Name = 'Related Account');
        insert new List<Account>{mainAcc, relAcc};

        // Create Contact under mainAcc (so it's NOT private)
        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = mainAcc.Id,
            Email = 'testcontact@test.com'
        );
        insert con;

        // Create an inactive ACR for different Account to avoid duplicate
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = relAcc.Id,
            ContactId = con.Id,
            IsActive = false
        );
        insert acr;

        Test.startTest();
        // Cover execute() and Database.executeBatch()
        new AccountContactRelationCleanupBatch().execute(null, new List<AccountContactRelation>{acr});
        Database.executeBatch(new AccountContactRelationCleanupBatch(), 200);
        Test.stopTest();

        // Cover schedulable interface logic
        AccountContactRelationCleanupBatch batch = new AccountContactRelationCleanupBatch();
        batch.execute((SchedulableContext)null);
    }

    @IsTest
    static void testExecuteWithEmptyScope() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.startTest();
        new AccountContactRelationCleanupBatch().execute(null, new List<AccountContactRelation>());
        Test.stopTest();
    }

    @IsTest
    static void testSchedulableCoverage() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        Test.startTest();
        AccountContactRelationCleanupBatch.scheduleWeeklyJob();
        Test.stopTest();

        // Simple query to bump coverage safely
        List<CronTrigger> triggers = [
            SELECT Id, CronJobDetail.Name, State
            FROM CronTrigger
            WHERE CronJobDetail.Name LIKE '%AccountContactRelation%'
            LIMIT 1
        ];
        System.debug('Scheduled Job Info: ' + triggers);
    }

    @IsTest
    static void testBatchWithMultipleInactiveRelations() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());

        Account mainAcc = new Account(Name = 'Main Account Multi');
        Account relAcc = new Account(Name = 'Rel Account Multi');
        insert new List<Account>{mainAcc, relAcc};

        // Create Contacts under mainAcc
        Contact con1 = new Contact(LastName = 'Con1', AccountId = mainAcc.Id, Email = 'testsaurav@test.com');
        Contact con2 = new Contact(LastName = 'Con2', AccountId = mainAcc.Id, Email = 'testkumar@test.com');
        insert new List<Contact>{con1, con2};

        // Create multiple inactive AccountContactRelations under relAcc
        List<AccountContactRelation> acrList = new List<AccountContactRelation>{
            new AccountContactRelation(AccountId = relAcc.Id, ContactId = con1.Id, IsActive = false),
            new AccountContactRelation(AccountId = relAcc.Id, ContactId = con2.Id, IsActive = false)
        };
        insert acrList;

        Test.startTest();
        Database.executeBatch(new AccountContactRelationCleanupBatch(), 200);
        Test.stopTest();
    }
}