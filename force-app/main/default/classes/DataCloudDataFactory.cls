/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public with sharing class DataCloudDataFactory {

    public static void loadData(){
        SoqlStubProvider stub = new productSoqlStub();
        Test.createSoqlStub(ODS_Product__dlm.sObjectType, stub);

        SoqlStubProvider invStub = new InventorySoqlStub();
        Test.createSoqlStub(ODS_Product_Inventory__dlm.sObjectType, invStub);

        Assert.isTrue(Test.isSoqlStubDefined(ODS_Product__dlm.sObjectType));
        Assert.isTrue(Test.isSoqlStubDefined(ODS_Product_Inventory__dlm.sObjectType));
    }
     

    class productSoqlStub extends SoqlStubProvider {
        public override List<sObject> handleSoqlQuery(sObjectType sot, string stubbedQuery, Map<string, object> bindVars) {
        
            Assert.areEqual(ODS_Product__dlm.sObjectType, sot);
            
            // Stub assumes that the SOQL query is searching for a single record by company id

            string companyId = 'Default';
            if(bindVars.containsKey('tmpVar1')) {
                companyId = (string)bindVars.get('tmpVar1');
            }
                     
            ODS_Product__dlm dmo = (ODS_Product__dlm)Test.createStubQueryRow(
                sot, 
                new Map<string, object> {
                    'PartArrayJSON__c' => '[{"replenishmentLeadTime":null,"isExclusive":false,"attribute":"Black with Black Ink","partId":"55064.1","childItem":"0001509","isManufactured":false,"isBuyToOrder":false,"partGroup":1,"partDescription":"Black with Black Ink","isMainPart":true,"ratio":{"$numberDecimal":"1"},"partGroupRequired":true,"lastModifiedDate":{"$date":"2025-06-03T14:12:17.000+00:00"},"customerArray":[],"colorArray":[{"hexCode":"#000000","pmsColor":"BLACK C"},{"hexCode":"#000000","pmsColor":"BLACK C"}],"partGroupDescription":"Item Color","parentItem":"2007476","attributeGroup":"Item Color","pricingClassification":"Standard","marketingABCcategory":"D","fobId":"CLW"},{"replenishmentLeadTime":null,"isExclusive":false,"attribute":"Blue with Black Ink","partId":"55064.2","childItem":"0001510","isManufactured":false,"isBuyToOrder":false,"partGroup":1,"partDescription":"Blue with Black Ink","isMainPart":true,"ratio":{"$numberDecimal":"1"},"partGroupRequired":true,"lastModifiedDate":{"$date":"2025-06-03T14:12:18.000+00:00"},"customerArray":[],"colorArray":[{"hexCode":"#115740","pmsColor":"7687 C"},{"hexCode":"#000000","pmsColor":"BLACK C"}],"partGroupDescription":"Item Color","parentItem":"2007476","attributeGroup":"Item Color","pricingClassification":"Standard","marketingABCcategory":"D","fobId":"CLW"},{"replenishmentLeadTime":null,"isExclusive":false,"attribute":"Green with Black Ink","partId":"55064.3","childItem":"0001511","isManufactured":false,"isBuyToOrder":false,"partGroup":1,"partDescription":"Green with Black Ink","isMainPart":true,"ratio":{"$numberDecimal":"1"},"partGroupRequired":true,"lastModifiedDate":{"$date":"2025-06-03T14:12:18.000+00:00"},"customerArray":[],"colorArray":[{"hexCode":"#115740","pmsColor":"343"},{"hexCode":"#000000","pmsColor":"BLACK"}],"partGroupDescription":"Item Color","parentItem":"2007476","attributeGroup":"Item Color","pricingClassification":"Standard","marketingABCcategory":"D","fobId":"CLW"}]',
                    'ProductId__c' => 'Bear',
                    'ProductName__c' => 'developer@salesforce.com',
                    'productCategory__c' => 'Codey',
                    'ProductSubCategory__c' => 'Bear'
                  } 
            );           
            return new List<sObject> { dmo };
        }
    }

    class InventorySoqlStub extends SoqlStubProvider {
        public override List<sObject> handleSoqlQuery(sObjectType sot, string stubbedQuery, Map<string, object> bindVars) {
        
            Assert.areEqual(ODS_Product_Inventory__dlm.sObjectType, sot);
            
            // Stub assumes that the SOQL query is searching for a single record by company id

            string companyId = 'Default';
            if(bindVars.containsKey('tmpVar1')) {
                companyId = (string)bindVars.get('tmpVar1');
            }
                     
            ODS_Product_Inventory__dlm dmo = (ODS_Product_Inventory__dlm)Test.createStubQueryRow(
                sot, 
                new Map<string, object> {
                    'PartArray__c' => '[{"replenishmentLeadTime":null,"isExclusive":false,"futureAvailablityArray":[{"firmFlag":false,"purchaseOrderNumber":"2031035","source":"ORACLE","purchaseOrderLineNumber":1,"availableOn":{"$date":"2025-11-20T00:00:00.000+00:00"},"lastUpdatedDate":{"$date":"2025-08-09T08:19:45.000+00:00"},"quantity":{"uom":"EA","value":5880},"createdDate":{"$date":"2025-08-09T08:19:45.000+00:00"}}],"attribute":"Silver","partId":"20016.1","childItem":"0028545","isManufactured":false,"isBuyToOrder":false,"partGroup":1,"partDescription":"Silver","isMainPart":true,"ratio":{"$numberDecimal":"1"},"quantityAvailable":{"uom":"EA","value":886},"partGroupRequired":true,"lastModifiedDate":{"$date":"2025-08-05T13:23:54.000+00:00"},"customerArray":[],"colorArray":[{"hexCode":"#84888B","pmsColor":"877 C"}],"partGroupDescription":"Item Color","parentItem":"2031184","attributeGroup":"Item Color","pricingClassification":"Standard","marketingABCcategory":"C","fobId":"RDW"}]',
                    'ProductId__c' => 'Bear'
                  } 
            );           
            return new List<sObject> { dmo };
        }
    }
}