/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DCSimilarProduct {
    
    @testVisible
    public static List<ODS_Product__dlm> testProducts = null;
    
    public class InputWrapper {
        @InvocableVariable(required=true)
        public String productId;
    } 

    public class ProductNameWrapper {
        @InvocableVariable
        public List<SimilarProduct> productNames;
    }


    @InvocableMethod(label='Get Similar Product via product name.')
    public static List<ProductNameWrapper> getSimilarProduct(List<InputWrapper> requests) {
        String productName = ''; 
        String productId = ''; 
        ProductNameWrapper similarProducts = new ProductNameWrapper();
        List<SimilarProduct> sps = new List<SimilarProduct>();
          
        for (InputWrapper req : requests) {
            // Remove special characters, keep letters, digits, and spaces
            if(String.isNotBlank(req.productId)){
                productId = req.productId.trim();
            } 
        }

        //System.debug('===== pid ======'+productId);
        if(String.isNotBlank(productId)){
            productName = DataCloudUtill.getProduct(productId,'',false).size() > 0 ?
            DataCloudUtill.getProduct(productId,'',true)[0].ProductName__c : '';
        }
        //System.debug('=== productName ==='+productName);
        String searchKey = '';
        if(productName != ''){
        
            for(String name : productName.split(' ')){ 
                searchKey += ' ' + name;
                //System.debug('=== similarProduct ==='+searchKey); 
                for(ODS_Product__dlm record : getProduct(searchKey.trim())){
                    SimilarProduct sp = new SimilarProduct();
                    sp.productId = record.ProductId__c;
                    sp.productName = record.ProductName__c;
                    sps.add(sp);
                }
            
            } 
        }

        if(sps.size() > 0){
            similarProducts.productNames = sps;
        }      
		 

        return new list<ProductNameWrapper>{similarProducts};
    }

    private static List<ODS_Product__dlm>  getProduct(String productName ){
        if (Test.isRunningTest() && testProducts != null) {
            return testProducts;
        }
        String fields = 'PartArrayJSON__c, ProductId__c, ProductName__c';
        String searchKey = '%'+DataCloudUtill.escapeForLike(ProductName.trim().toLowerCase())+'%';
        String searchPrductName = 'ProductName__c LIKE : searchKey'; 
        String productSQL = 'SELECT {0} FROM ODS_Product__dlm WHERE {1} LIMIT 200';
        String bdSQL = '';

        if(String.isNotBlank(productName)){
            bdSQL = String.format(productSQL, new List<String>{fields,searchPrductName});
        }
        //System.debug('===== SOQL ====='+bdSQL);
        ODS_Product__dlm [] record = Database.query(bdSQL);

        return record.size() > 0 ? record : new List<ODS_Product__dlm>();
    }
    
    public class SimilarProduct {

        @InvocableVariable
        public String productId;

        @InvocableVariable
        public String productName; 
    }
}