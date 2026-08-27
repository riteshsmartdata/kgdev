/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DCInventoryDetail {
     public class InputWrapper {
        @InvocableVariable(required=false)
        public String productId;
         
    }

    @InvocableMethod(label='Get Inventory Details' description='Get Inventory Details from Data Cloud by Product ID')
    public static List<DCInventory> getInventoryDetails(List<InputWrapper> requests) {
        DCInventory inventoryDetails = new DCInventory();
        String productId = ''; 
        
        for (InputWrapper req : requests) {

            if(String.isNotBlank(req.productId)) {
                productId = req.productId.trim();
            }  

        }

        ODS_Product__dlm [] products = DataCloudUtill.getProduct(productId, null, false);
        if(products.size() > 0) {
            for (ODS_Product__dlm record : products) {
                inventoryDetails.productId = record.ProductId__c;
                inventoryDetails.productName = record.ProductName__c;                
                inventoryDetails.detail = parsePartArray(record.PartArrayJSON__c);
                inventoryDetails.websiteULR = System.Label.Website_ULR + '/'+record.ProductId__c;
            }
        }

        ODS_Product_Inventory__dlm [] inventory = DataCloudUtill.getInventory(productId);
        if(inventory.size() > 0){
            for (ODS_Product_Inventory__dlm record : inventory) { 
                 if(String.isNotBlank(record.partArray__c) && record.partArray__c != null){
                    inventoryDetails.inventory = parseProductInventoryWrapper(record.PartArray__c);
                 } 
            }
        } 

        return inventoryDetails != null ? new List<DCInventory>{inventoryDetails} : new List<DCInventory>();
    }

    public static List<ProductWrapper> parsePartArray(String partArrayJSON) {
        //System.debug('=== partArrayJSON ===' + partArrayJSON);
        List<ProductWrapper> prod = new List<ProductWrapper>();
        if (String.isBlank(partArrayJSON)) {
            return new List<ProductWrapper>();
        }        

        return  (List<ProductWrapper>) JSON.deserialize(partArrayJSON.replace('$','D'), List<ProductWrapper>.class);
    }

    public static List<ProductInventoryWrapper> parseProductInventoryWrapper(String partArrayJSON) {
        //System.debug('=== partArrayJSON ===' + partArrayJSON);
        List<ProductInventoryWrapper> prod = new List<ProductInventoryWrapper>();
        if (String.isBlank(partArrayJSON)) {
            return new List<ProductInventoryWrapper>();
        } 

        return  (List<ProductInventoryWrapper>) JSON.deserialize(partArrayJSON.replace('$','D'), List<ProductInventoryWrapper>.class);
    }
}