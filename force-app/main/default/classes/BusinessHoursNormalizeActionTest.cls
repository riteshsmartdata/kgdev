@IsTest
public class BusinessHoursNormalizeActionTest {

    /**
     * Utility method to get an active Business Hours record.
     * Assumes at least one Business Hours record exists (true for all orgs).
     */
    private static Id getBusinessHoursId() {
        BusinessHours bh = [
            SELECT Id
            FROM BusinessHours
            WHERE IsActive = true
            LIMIT 1
        ];
        return bh.Id;
    }

    @IsTest
    static void testDateTimeWithinBusinessHours() {
        Id bhId = getBusinessHoursId();

        // Create a DateTime that should be within business hours
        // Using noon local time to avoid DST edge cases
        Datetime withinBH = Datetime.newInstance(
            Date.today(),
            Time.newInstance(12, 0, 0, 0)
        );

        BusinessHoursNormalizeAction.Request req =
            new BusinessHoursNormalizeAction.Request();
        req.inputDateTime = withinBH;
        req.businessHoursId = bhId;

        Test.startTest();
        List<BusinessHoursNormalizeAction.Response> results =
            BusinessHoursNormalizeAction.normalizeDateTime(
                new List<BusinessHoursNormalizeAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One response expected');
        System.assertEquals(
            withinBH,
            results[0].resultDateTime,
            'DateTime within business hours should be unchanged'
        );
    }

    @IsTest
    static void testDateTimeOutsideBusinessHours() {
        Id bhId = getBusinessHoursId();

        // Create a DateTime very early in the morning (likely outside BH)
        Datetime outsideBH = Datetime.newInstance(
            Date.today(),
            Time.newInstance(2, 0, 0, 0)
        );

        BusinessHoursNormalizeAction.Request req =
            new BusinessHoursNormalizeAction.Request();
        req.inputDateTime = outsideBH;
        req.businessHoursId = bhId;

        Test.startTest();
        List<BusinessHoursNormalizeAction.Response> results =
            BusinessHoursNormalizeAction.normalizeDateTime(
                new List<BusinessHoursNormalizeAction.Request>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One response expected');

        // Expected value is next business start after inputDateTime
        Datetime expectedNextStart = BusinessHours.nextStartDate(
            bhId,
            outsideBH.addSeconds(1)
        );

        System.assertEquals(
            expectedNextStart,
            results[0].resultDateTime,
            'DateTime outside business hours should normalize to next start'
        );
    }

    @IsTest
    static void testMultipleRequests() {
        Id bhId = getBusinessHoursId();

        Datetime withinBH = Datetime.newInstance(
            Date.today(),
            Time.newInstance(11, 0, 0, 0)
        );

        Datetime outsideBH = Datetime.newInstance(
            Date.today(),
            Time.newInstance(1, 0, 0, 0)
        );

        List<BusinessHoursNormalizeAction.Request> requests =
            new List<BusinessHoursNormalizeAction.Request>();

        BusinessHoursNormalizeAction.Request r1 =
            new BusinessHoursNormalizeAction.Request();
        r1.inputDateTime = withinBH;
        r1.businessHoursId = bhId;

        BusinessHoursNormalizeAction.Request r2 =
            new BusinessHoursNormalizeAction.Request();
        r2.inputDateTime = outsideBH;
        r2.businessHoursId = bhId;

        requests.add(r1);
        requests.add(r2);

        Test.startTest();
        List<BusinessHoursNormalizeAction.Response> results =
            BusinessHoursNormalizeAction.normalizeDateTime(requests);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Two responses expected');
        System.assertEquals(withinBH, results[0].resultDateTime);
        System.assertNotEquals(
            outsideBH,
            results[1].resultDateTime,
            'Outside BH DateTime should be adjusted'
        );
    }
}