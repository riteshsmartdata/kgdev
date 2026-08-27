/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ProductWrapperTest {

    @isTest
    static void testParseMethod() {
        // Prepare sample JSON for ProductWrapper
        String json = '{' +
            '"replenishmentLeadTime":5,' +
            '"isExclusive":true,' +
            '"attribute":"Aquamarine with Black Ink",' +
            '"partId":"55250.1",' +
            '"childItem":"1071334",' +
            '"isManufactured":true,' +
            '"isBuyToOrder":false,' +
            '"partGroup":1,' +
            '"partDescription":"Aquamarine with Black Ink",' +
            '"isMainPart":true,' +
            '"ratio":{"DnumberDecimal":"1"},' +
            '"partGroupRequired":false,' +
            '"lastModifiedDate":{"Ddate":"2025-06-03T14:12:56.000+00:00"},' +
            '"customerArray":[{}],' +
            '"colorArray":[{"hexCode":"#006D7E","pmsColor":"8225 C"}],' +
            '"partGroupDescription":"Item Color",' +
            '"parentItem":"2007499",' +
            '"attributeGroup":"Item Color",' +
            '"pricingClassification":"Standard",' +
            '"marketingABCcategory":"N25",' +
            '"fobId":"CLW"' +
        '}';

        ProductWrapper wrapper = ProductWrapper.parse(json);

        System.assertEquals(5, wrapper.replenishmentLeadTime);
        System.assertEquals(true, wrapper.isExclusive);
        System.assertEquals('Aquamarine with Black Ink', wrapper.attribute);
        System.assertEquals('55250.1', wrapper.partId);
        System.assertEquals('1071334', wrapper.childItem);
        System.assertEquals(true, wrapper.isManufactured);
        System.assertEquals(false, wrapper.isBuyToOrder);
        System.assertEquals(1, wrapper.partGroup);
        System.assertEquals('Aquamarine with Black Ink', wrapper.partDescription);
        System.assertEquals(true, wrapper.isMainPart);
        System.assertNotEquals(null, wrapper.customerArray);
        System.assertEquals(1, wrapper.customerArray.size());
        System.assertNotEquals(null, wrapper.colorArray);
        System.assertEquals(1, wrapper.colorArray.size());
        System.assertEquals('#006D7E', wrapper.colorArray[0].hexCode);
        System.assertEquals('8225 C', wrapper.colorArray[0].pmsColor);
        System.assertEquals('Item Color', wrapper.partGroupDescription);
        System.assertEquals('2007499', wrapper.parentItem);
        System.assertEquals('Item Color', wrapper.attributeGroup);
        System.assertEquals('Standard', wrapper.pricingClassification);
        System.assertEquals('N25', wrapper.marketingABCcategory);
        System.assertEquals('CLW', wrapper.fobId);
    }
}