@IsTest
public class BusinessHoursDiffActionTest {

    @IsTest
    static void testBusinessHoursDifference_singleInput() {

        // Query existing active Business Hours (DML NOT allowed)
        BusinessHours bh = [
            SELECT Id
            FROM BusinessHours
            WHERE IsActive = true
            LIMIT 1
        ];

        // Monday, Jan 8, 2024
        Datetime startDt = Datetime.newInstance(2024, 1, 8, 9, 0, 0);
        Datetime endDt   = Datetime.newInstance(2024, 1, 8, 11, 0, 0);

        BusinessHoursDiffAction.Input input =
            new BusinessHoursDiffAction.Input();
        input.businessHoursId = bh.Id;
        input.startDateTime   = startDt;
        input.endDateTime     = endDt;

        Test.startTest();
        List<BusinessHoursDiffAction.Output> results =
            BusinessHoursDiffAction.calculateDiff(
                new List<BusinessHoursDiffAction.Input>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertNotEquals(null, results[0].milliseconds);
        System.assert(results[0].totalMinutes > 0);
        System.assert(results[0].totalHours > 0);
    }

    @IsTest
    static void testBusinessHoursDifference_multipleInputs() {

        BusinessHours bh = [
            SELECT Id
            FROM BusinessHours
            WHERE IsActive = true
            LIMIT 1
        ];

        Datetime start1 = Datetime.newInstance(2024, 1, 8, 10, 0, 0);
        Datetime end1   = Datetime.newInstance(2024, 1, 8, 12, 0, 0);

        Datetime start2 = Datetime.newInstance(2024, 1, 9, 9, 0, 0);
        Datetime end2   = Datetime.newInstance(2024, 1, 9, 17, 0, 0);

        BusinessHoursDiffAction.Input i1 = new BusinessHoursDiffAction.Input();
        i1.businessHoursId = bh.Id;
        i1.startDateTime = start1;
        i1.endDateTime   = end1;

        BusinessHoursDiffAction.Input i2 = new BusinessHoursDiffAction.Input();
        i2.businessHoursId = bh.Id;
        i2.startDateTime = start2;
        i2.endDateTime   = end2;

        Test.startTest();
        List<BusinessHoursDiffAction.Output> results =
            BusinessHoursDiffAction.calculateDiff(
                new List<BusinessHoursDiffAction.Input>{ i1, i2 }
            );
        Test.stopTest();

        System.assertEquals(2, results.size());
        System.assert(results[0].milliseconds >= 0);
        System.assert(results[1].milliseconds >= 0);
    }

    @IsTest
    static void testBusinessHoursDifference_sameStartEnd() {

        BusinessHours bh = [
            SELECT Id
            FROM BusinessHours
            WHERE IsActive = true
            LIMIT 1
        ];

        Datetime dt = Datetime.newInstance(2024, 1, 10, 10, 0, 0);

        BusinessHoursDiffAction.Input input =
            new BusinessHoursDiffAction.Input();
        input.businessHoursId = bh.Id;
        input.startDateTime   = dt;
        input.endDateTime     = dt;

        Test.startTest();
        List<BusinessHoursDiffAction.Output> results =
            BusinessHoursDiffAction.calculateDiff(
                new List<BusinessHoursDiffAction.Input>{ input }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(0, results[0].milliseconds);
    }
}