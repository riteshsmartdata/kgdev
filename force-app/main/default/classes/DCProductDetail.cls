/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class DCProductDetail {
    
    public class InputWrapper {
        @InvocableVariable(required=false)
        public String productId; 
    }

    @InvocableMethod(label='Get Product Details' description='Get Product Details from Data Cloud by Product')
    public static List<DCProduct> getProductDetails(List<InputWrapper> requests) {
        DCProduct productDetails = new DCProduct();
        String productId;
        String productName;
        
        for (InputWrapper req : requests) {

            if(String.isNotBlank(req.productId)) {
                productId = req.productId.trim();
            } 
            
        }

        ODS_Product__dlm [] products = DataCloudUtill.getProduct(productId, productName, false);
        if(products.size() > 0) {
            for (ODS_Product__dlm record : products) {
                productDetails.productId = record.ProductId__c;
                productDetails.productName = record.ProductName__c;
                productDetails.productCategory = String.isNotBlank(record.productCategory__c) ? record.productCategory__c : '';
                productDetails.productSubCategory = String.isNotBlank(record.productSubCategory__c) ? record.productSubCategory__c : ''; 
                productDetails.detail = parsePartArray(record.PartArrayJSON__c);
                productDetails.websiteULR = System.Label.Website_ULR + '/'+record.ProductId__c;
            }
        }
        
        return productDetails != null ? new List<DCProduct>{productDetails} : new List<DCProduct>();
    }

    public static List<ProductWrapper> parsePartArray(String partArrayJSON) {
        //System.debug('=== partArrayJSON ===' + partArrayJSON);
        List<ProductWrapper> prod = new List<ProductWrapper>();
        if (String.isBlank(partArrayJSON)) {
            return new List<ProductWrapper>();
        }        

        List<ProductWrapper> prod1 = (List<ProductWrapper>) JSON.deserialize(partArrayJSON, List<ProductWrapper>.class);

        return  (List<ProductWrapper>) JSON.deserialize(partArrayJSON.replace('$','D'), List<ProductWrapper>.class);
    }
    
}