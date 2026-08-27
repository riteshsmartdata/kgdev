/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-09-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class ProductInventoryWrapperTest {

    @isTest
    static void testParseMethod() {
        String json = '{' +
            '"replenishmentLeadTime":7,' +
            '"isExclusive":true,' +
            '"futureAvailablityArray":[{' +
                '"firmFlag":true,' +
                '"purchaseOrderNumber":"2007219",' +
                '"source":"ORACLE",' +
                '"purchaseOrderLineNumber":1,' +
                '"availableOn":{"Ddate":"2025-11-10T00:00:00.000+00:00"},' +
                '"lastUpdatedDate":{"Ddate":"2025-08-09T09:01:51.000+00:00"},' +
                '"quantity":{"uom":"EA","value":29400},' +
                '"createdDate":{"Ddate":"2025-08-09T09:01:51.000+00:00"}' +
            '}],' +
            '"attribute":"Blue with Blue Ink",' +
            '"partId":"55250.1",' +
            '"childItem":"1009313",' +
            '"isManufactured":true,' +
            '"isBuyToOrder":false,' +
            '"partGroup":1,' +
            '"partDescription":"Blue with Blue Ink",' +
            '"isMainPart":true,' +
            '"ratio":{"DnumberDecimal":"1"},' +
            '"quantityAvailable":{"uom":"EA","value":30692},' +
            '"partGroupRequired":false,' +
            '"lastModifiedDate":{"Ddate":"2025-08-01T03:25:09.000+00:00"},' +
            '"customerArray":[{}],' +
            '"colorArray":[{"hexCode":"#324A96","pmsColor":"7455 C"}],' +
            '"partGroupDescription":"Item Color",' +
            '"parentItem":"2007499",' +
            '"attributeGroup":"Item Color",' +
            '"pricingClassification":"Standard",' +
            '"marketingABCcategory":"B",' +
            '"fobId":"CLW"' +
        '}';

        ProductInventoryWrapper wrapper = ProductInventoryWrapper.parse(json);

        System.assertEquals(7, wrapper.replenishmentLeadTime);
        System.assertEquals(true, wrapper.isExclusive);
        System.assertNotEquals(null, wrapper.futureAvailablityArray);
        System.assertEquals(1, wrapper.futureAvailablityArray.size());
        System.assertEquals(true, wrapper.futureAvailablityArray[0].firmFlag);
        System.assertEquals('2007219', wrapper.futureAvailablityArray[0].purchaseOrderNumber);
        System.assertEquals('ORACLE', wrapper.futureAvailablityArray[0].source);
        System.assertEquals(1, wrapper.futureAvailablityArray[0].purchaseOrderLineNumber);
        System.assertNotEquals(null, wrapper.customerArray);
        System.assertEquals(1, wrapper.customerArray.size());
        System.assertNotEquals(null, wrapper.colorArray);
        System.assertEquals(1, wrapper.colorArray.size());
        System.assertEquals('#324A96', wrapper.colorArray[0].hexCode);
        System.assertEquals('7455 C', wrapper.colorArray[0].pmsColor);
        System.assertEquals('Item Color', wrapper.partGroupDescription);
        System.assertEquals('2007499', wrapper.parentItem);
        System.assertEquals('Item Color', wrapper.attributeGroup);
        System.assertEquals('Standard', wrapper.pricingClassification);
        System.assertEquals('B', wrapper.marketingABCcategory);
        System.assertEquals('CLW', wrapper.fobId);
    }
}