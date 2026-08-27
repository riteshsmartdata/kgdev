/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DataCloudUtill {

    public static List<ODS_Product__dlm>  getProduct(String productId, String productName, Boolean isMUltilpeRecord){
        //System.debug('======= DC PID ====='+ productId);
        //System.debug('======= DC productName ====='+ productName); 

        String fields = 'PartArrayJSON__c, ProductId__c, ProductName__c, productCategory__c, ProductSubCategory__c ';
        String sqlLimit = isMUltilpeRecord ? '200':'1';
        if( String.isNotBlank(productName) && productName != null){
            productName = productName.toLowerCase();
        }
        
        if( String.isNotBlank(productId)){
            productId = productId.toUpperCase();
        }
        
        String searchPrductName = 'ProductName__c LIKE: productName';
        String searchPrductId = 'ProductId__c =: productId';
        String productSQL = 'SELECT {0} FROM ODS_Product__dlm WHERE {1} LIMIT {2}';
        String bdSQL = '';

        if(String.isNotBlank(productName)){
            bdSQL = String.format(productSQL, new List<String>{fields,searchPrductName,sqlLimit});
        }

        if(String.isNotBlank(productId)){
            bdSQL = String.format(productSQL, new List<String>{fields,searchPrductId,sqlLimit});
        }

        //System.debug(LoggingLevel.INFO, '==== Final SQOL ===='+bdSQL);

        ODS_Product__dlm [] record = Database.query(bdSQL);

         //System.debug(LoggingLevel.INFO, '==== record ===='+record);
        return record.size() > 0 ? record : new List<ODS_Product__dlm>();
    }

     public static List<ODS_Product_Inventory__dlm >  getInventory(String productId){
         if( String.isNotBlank(productId)){
            productId = productId.toUpperCase();
        }
        String fields = 'PartArray__c, ProductId__c';
        String searchPrductId = 'ProductId__c =: productId';
        String productSQL = 'SELECT {0} FROM ODS_Product_Inventory__dlm  WHERE {1} LIMIT 200';
        String bdSQL = ''; 

        if(String.isNotBlank(productId)){
            bdSQL = String.format(productSQL, new List<String>{fields,searchPrductId});
        }

        //System.debug(LoggingLevel.INFO, '==== Final SQOL ===='+bdSQL);

        ODS_Product_Inventory__dlm  [] record = Database.query(bdSQL);

        return record.size() > 0 ? record : new List<ODS_Product_Inventory__dlm>();
    }

    public static String getCleanString(String textString) {
        // Remove all non-alphanumeric and non-whitespace chars.
        // Then collapse multiple spaces and trim (optional but handy).
        return String.isNotBlank(textString)
            ? textString
                .replaceAll('[^a-zA-Z0-9\\s]', '')
                .replaceAll('\\s+', ' ')
                .trim()
            : '';
    } 

    public static String escapeForLike(String s){
        if (s == null) return '';        
        return s.replaceAll('\\\\', '\\\\\\\\') .replaceAll('%', '\\\\%').replaceAll('_', '\\\\_');
    }
}