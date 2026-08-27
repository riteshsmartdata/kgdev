/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class InventoryWrapperTest {

    @isTest
    static void testParseMethod() {
        String json = '{' +
            '"partId":"55250.9",' +
            '"quantityByDateArray":[{' +
                '"isEarliest":true,' +
                '"minimumQuantity":{"DnumberLong":"30692"},' +
                '"truncQuantity":{"DnumberLong":"0"},' +
                '"Ddate":{"Ddate":"2025-08-09T00:00:00.000+00:00"}' +
            '}]' +
        '}';

        InventoryWrapper wrapper = InventoryWrapper.parse(json);

        System.assertEquals('55250.9', wrapper.partId);
        System.assertNotEquals(null, wrapper.quantityByDateArray);
        System.assertEquals(1, wrapper.quantityByDateArray.size());
        System.assertEquals(true, wrapper.quantityByDateArray[0].isEarliest);
    }
}