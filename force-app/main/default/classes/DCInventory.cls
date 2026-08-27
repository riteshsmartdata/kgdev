/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DCInventory {
    @AuraEnabled @InvocableVariable public String productId;
    @AuraEnabled @InvocableVariable public String productName;
    @AuraEnabled @InvocableVariable public  List<ProductWrapper> detail;
    @AuraEnabled @InvocableVariable public  List<ProductInventoryWrapper> inventory;
    @AuraEnabled @InvocableVariable public  List<InventoryWrapper> inventoryOnDemand;
    @AuraEnabled @InvocableVariable public String websiteULR;

}