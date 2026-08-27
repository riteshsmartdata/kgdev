@IsTest
public class getUserTimeHourMinutesTest {
    @IsTest
    static void testGetUserTimes_SingleInput() {
        DateTime dt = DateTime.newInstance(2025, 7, 11, 14, 30, 0); // 2:30 PM
        List<DateTime> inputDates = new List<DateTime>{ dt };

        Test.startTest();
        List<getUserTimeHourMinutes.returnValues> results = getUserTimeHourMinutes.getUserTimes(inputDates);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One result expected');
        System.assertEquals(14, results[0].hour, 'Hour should match');
        System.assertEquals(30, results[0].minute, 'Minute should match');
    }

    @IsTest
    static void testGetUserTimes_MultipleInputs() {
        DateTime dt1 = DateTime.newInstance(2025, 7, 11, 8, 15, 0);  // 8:15 AM
        DateTime dt2 = DateTime.newInstance(2025, 7, 11, 18, 45, 0); // 6:45 PM
        List<DateTime> inputDates = new List<DateTime>{ dt1, dt2 };

        Test.startTest();
        List<getUserTimeHourMinutes.returnValues> results = getUserTimeHourMinutes.getUserTimes(inputDates);
        Test.stopTest();

        System.assertEquals(2, results.size(), 'Two results expected');

        System.assertEquals(8, results[0].hour, 'First hour should match');
        System.assertEquals(15, results[0].minute, 'First minute should match');

        System.assertEquals(18, results[1].hour, 'Second hour should match');
        System.assertEquals(45, results[1].minute, 'Second minute should match');
    }
}