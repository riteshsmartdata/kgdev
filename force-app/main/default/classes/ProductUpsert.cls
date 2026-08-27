/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   10-31-2023   Ritesh Kumar   JIRA MP-135
**/

@RestResource(urlMapping='/ProductUpsert/*')
global without sharing class ProductUpsert{

    final static String SUCCESS_MESSAGE = 'Successfully Completed.';
    final static String ERROR_MESSAGE = 'An error has occurred.';
    final static String SOURCE = 'Website';
    final static String IS_ACTIVE = 'A';
    final static String IS_INACTIVE = 'I';

    public enum STATUS{ SUCCESS, ERROR }

    @HttpPost
    global static void getProductRequest(){
        String recordID = '';
        Product2 productRecord = new Product2();

        ProductRequest productWebInfo = new ProductRequest();   
        RestRequest request = RestContext.Request; 

        RestResponse response = RestContext.response;

        String requestpayload = request.Requestbody.toString();  

        if(requestpayload != '{}' && requestpayload != null && requestpayload != ''){
            productWebInfo =  ProductRequest.parse(requestpayload); 
        } 

        //System.debug('===== Product  productWebInfo ======'+productWebInfo); 

        ProductRequest.ProductData [] productList = productWebInfo.eventRequest.productData.size() > 0 ? productWebInfo.eventRequest.productData : new List<ProductRequest.ProductData>();
        productRecord = getProduct(productList[0]);
        //System.debug('===== Product  productRecord ======'+productRecord); 

        Database.UpsertResult results =  Database.Upsert(productRecord,true);  
        //System.debug('===== Product  results ======'+results);
        if(results.isSuccess()){ 
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 200;
            String responseData = productResponse(ProductUpsert.STATUS.SUCCESS, productRecord, null);
            response.responseBody =  Blob.valueOf(responseData);
        }else{
            response.addHeader('Content-Type', 'application/json');
            response.statusCode = 400;
            String responseData = productResponse(ProductUpsert.STATUS.ERROR, productRecord, results.getErrors());
            response.responseBody =  Blob.valueOf(responseData);
        } 
    }


    /**
    * @description       : This method is used to map the product data from request JSON.
    * @Parameters        : Accept one parameter and the type is String.
    */
    private static Product2 getProduct(ProductRequest.ProductData webProductInfo){
        //System.debug('===== getProduct ======'+webProductInfo);
        product2 record = new Product2();
        record.Source__c = SOURCE;

        if(getSalesforceId(webProductInfo.productCatalogNumber, webProductInfo.salesforceID) != ''){
            record.id = getSalesforceId(webProductInfo.productCatalogNumber, webProductInfo.salesforceID);
        }

        record.WebsiteID__c = getStringValue(webProductInfo.websiteID);   
        record.Product_Catalog_Number__c = getStringValue(webProductInfo.productCatalogNumber);
        record.Name =getStringValue(webProductInfo.productName);
        record.Product_Category__c =  getStringValue(webProductInfo.categories);
        record.Product_Sub_Category__c = getStringValue(webProductInfo.subCategories);
        record.Departments__c = getStringValue(webProductInfo.departments);
        record.Brand__c =  getStringValue(webProductInfo.brand);
        record.Country_of_Orgin__c = getStringValue(webProductInfo.countryofOrgin);
        record.PostalCode__c = getStringValue(webProductInfo.manufacturingSite.postalCode);
        record.City__c = getStringValue(webProductInfo.manufacturingSite.city);
        record.State__c = getStringValue(webProductInfo.manufacturingSite.state);
        record.Country__c = getStringValue(webProductInfo.manufacturingSite.country);
        record.Product_URL__c = getStringValue(webProductInfo.productURL); 
        record.Product_Image_URL__c =  getStringValue(webProductInfo.productImageURL);
        //record.Product_Status__c = getStringValue(webProductInfo.productStatus);
        record.Pricing_Code__c = getStringValue(webProductInfo.pricingCode);
        record.End_QTY_Price__c = getNumberValue(webProductInfo.endQtyPrice); 
        record.End_QTY_Price_Code__c = getStringValue(webProductInfo.endQtPriceCode);
        record.End_QTY_Retail_Price__c = getNumberValue(webProductInfo.endQtyRetailPrice);
        record.IsActive = getStringToBoolean(webProductInfo.productStatus);
        record.Exclusive_To__c = getStringValue(webProductInfo.Exclusive_To); 
        if(! checkNull('String', webProductInfo.RecordTypeName,null)){
        	record.RecordTypeId = getStringValue(KoozieUtility.getRecordTypeId('Product2',webProductInfo.RecordTypeName));
        }
		record.Sub_Status__c = getStringValue(webProductInfo.productSubStatus);
		record.OOS_Flag__c	 = webProductInfo.isOutOfStock;
        
        return record;
    }

    /**
    * @description       : This method is used to get the salesfroce Id based on product catalog number.
    * @Parameters        : Accept three parameters and first is product catalognumber and second is salesforceid.
    */
    private static String getSalesforceId(String catalogNumber, String salesforceID){
        //System.debug('===== getSalesforceId catalogNumber ======'+catalogNumber);
        //System.debug('===== getSalesforceId salesforceID ======'+salesforceID);
        
        String productId ='';
        if(salesforceID != null && salesforceID != '' && salesforceID != 'null'){
            productId = salesforceID;
        }
    
        if(catalogNumber != null && catalogNumber != '' && catalogNumber != 'null'){
            Product2 [] product = [SELECT ID FROM Product2 WHERE Product_Catalog_Number__c =: catalogNumber WITH SECURITY_ENFORCED LIMIT 1 ];
            if(product.size() > 0){
                productId = product[0].ID;
            }  
        }
        //System.debug('===== getSalesforceId productId ======'+productId);
        return productId;
    }

    /**
    * @description       : This method is used to check whether the given value is null or not.
    * @Parameters        : Accept three parameters and first is data type and second is String value and third is number value.
    */
    private static Boolean checkNull(String dataType, String textValue, Double numberValue){
        ////System.debug('===== checkNull dataType ======'+dataType);
        ////System.debug('===== checkNull textValue ======'+textValue);
        ////System.debug('===== checkNull numberValue ======'+numberValue);
        Boolean isNullCheck = TRUE;

        switch on dataType {
            when 'String' {
                isNullCheck = (textValue != null && textValue != '' && textValue != 'null') ? FALSE : TRUE;
            }
            when 'Double' {
                isNullCheck = (numberValue != null && numberValue > 0) ? FALSE : TRUE;
            } 
        }

        //System.debug('===== checkNull ======'+isNullCheck);
        return isNullCheck;
    }

    /**
    * @description       : The method is used to generate the product response JSON..
    * @Parameters        : Accept three parameters and first is DML status and second is current product record and third is database error, if any.
    */
    @TestVisible
    private static String productResponse(ProductUpsert.STATUS type, Product2 productRecord,List<Database.Error> errors){
        //System.debug('===== productResponse ======'+productRecord);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventResponse');
        gen.writeStartObject();

        if(String.isNotBlank(productRecord.Product_Catalog_Number__c)){
            gen.writeStringField('EventBusinessID', productRecord.Product_Catalog_Number__c);
        }else{
            gen.writeNullField('EventBusinessID');
        }

        switch on  type {
            when SUCCESS {
                gen.writeStringField('EventStatus', 'SUCCESS');
                gen.writeStringField('EventStatusMessage', SUCCESS_MESSAGE);
                gen.writeFieldName('ProductData');
                responseSuccess(productRecord, gen);
                gen.writeEndObject();
                gen.writeEndObject(); 

            }
            when ERROR{
                gen.writeStringField('EventStatus', 'ERROR');
                gen.writeStringField('EventStatusMessage', ERROR_MESSAGE);
                gen.writeFieldName('ProductData');
                responseError(errors, gen);
                gen.writeEndObject();
                gen.writeEndObject(); 
            }
        }      
        //System.debug('===== Product  gen.getAsString() ======'+gen.getAsString());
        return gen.getAsString();
    }

    /**
    * @description       : The method is used to generate the success response JSON based on the success.
    * @Parameters        : Accept two parameters and the first is the product record and the second is the current JSONGenerator context.
    */
    private static JSONGenerator responseSuccess(Product2 productRecord, JSONGenerator gen){
        gen.writeStartObject();
            gen.writeStringField('SalesforceID', productRecord.Id);

            if(String.isNotBlank(productRecord.WebsiteID__c) &&   productRecord.WebsiteID__c != 'null'){
                gen.writeStringField('WebsiteID', productRecord.WebsiteID__c);
            }else{
                gen.writeNullField('WebsiteID');
            }

            if(String.isNotBlank(productRecord.Product_Catalog_Number__c) && productRecord.Product_Catalog_Number__c != 'null' ){
                gen.writeStringField('ProductCatalogNumber', productRecord.Product_Catalog_Number__c);
            }else{
                gen.writeNullField('ProductCatalogNumber');
            }
        gen.writeEndObject();
        return gen;
    }

    /**
    * @description       : The method is used to generate the error response JSON based on the error.
    * @Parameters        : Accept two parameters and the first is the database error and the second is the current JSONGenerator context.
    */
    @TestVisible
    private static JSONGenerator responseError(List<Database.Error> errors, JSONGenerator gen){
        gen.writeStartObject();
        gen.writeFieldName('Error Details');  
            gen.writeStartObject(); 
            for (Database.Error error : errors) {
                Integer index =1; 
                gen.writeStringField('Error '+index + ' : ' , error.getMessage());
                index++;
            }
            gen.writeEndObject();
        gen.writeEndObject();
        return gen;
    }

    /**
    * @description       : The method is used to check the string field, if the field is empty then return null otherwise it will return the same string which you have passed.
    * @Parameters        : Accept one parameter and the type is String.
    */
    private static String getStringValue(String fieldValue){
        return ! checkNull('String',fieldValue,null) ? fieldValue : null; 
    }

    /**
    * @description       : Method used to check number field, if field is blank then return zero otherwise it will return number.
    * @Parameters        : Accept one parameter and the type is Number(Double).
    */
    private static Double getNumberValue(Double fieldValue){
        return ! checkNull('Double',null,fieldValue) ? fieldValue : 0; 
    }

    /**
    * @description       : Method used to get boolean value from given string
    * @Parameters        : Accept one parameter and the type is string.
    */
    private static Boolean getStringToBoolean(String fieldValue){
        String value =  ! checkNull('String',fieldValue, null) ? fieldValue : '';
        return value == IS_ACTIVE ? TRUE : FALSE ; 
    } 

}