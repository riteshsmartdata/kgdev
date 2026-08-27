/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 06-12-2024
* @last modified by  : ritesh.kumar@kooziegroup.com
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   11-02-2023   Ritesh Kumar   Initial Version
**/
@IsTest
public class ProductUpsertTest {
    
    private class RestSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('{"EventResponse":{"EventBusinessID":"Tecst02","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed.","ProductData":{"SalesforceID":"01t8K000004QhTpQAK","WebsiteID":"5ce04fdggg285561549ee4d92e73932432","ProductCatalogNumber":"Tecst02"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json'); 
            res.setBody('[{"errorCode":"APEX_ERROR","message":"System.StringException: Invalid id: 4353453453453453454\n\nClass.ProductUpsert.getProduct: line 71, column 1\nClass.ProductUpsert.getProductRequest: line 42, column 1"}]');
            res.setStatusCode(400);
            return res;
        }
    }
    
    @TestSetup
    public static void productData(){ 
        Product2 record = TestDataFactory.createSingleProduct('Test Product', 11, TRUE, TRUE);
        
    }
    
    @IsTest
    public static void getProductRequestSuccess_unitTest1(){ 
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/ProductUpsert/';
        request.httpMethod = 'POST';
        String requestBody = '{"EventRequest":{"EventObject":"PRODUCT","EventDateTime":"2023-04-07T03:52:56","EventSourceSystem":"Website","EventBusinessID":"Test02","ProductData":[{"WebsiteID":"5ce04fdggg285561549ee4d92e73932432","SalesforceID":"","ProductCatalogNumber":"Tecst02","ProductName":"BIC® Clic Stic® Pen Test R","Categories":"Writing Instruments","SubCategories":"Retractables","Departments":"Salesforce","Brand":"BIC®","CountryofOrgin":"Mexico","ManufacturingSite":{"PostalCode":"33760","City":"Clearwater","State":"FL","Country":"US"},"ProductURL":"https://kg-uat-template.kooziegroup.com/US/bic-clic-stic-pen-cs","ProductImageURL":"https://kgstorageprod.blob.core.windows.net/kgblob/5ced3789cac7a0376835ba90_bic-clic-stic-pen.jpeg","ProductStatus":"I","PricingCode":"B","EndQtyPrice":11,"EndQtPriceCode":"BBBBBB","EndQtyRetailPrice":3,"isOutOfStock":false}]}}';
        request.requestBody = Blob.valueof(requestBody);
        
        RestContext.request = request;
        RestContext.response = response; 
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestSuccessMock());
        ProductUpsert.getProductRequest();
        Test.stopTest(); 
        
    }
    
    @IsTest
    public static void getProductRequestSuccess_unitTest(){ 
        Product2 record = TestDataFactory.createSingleProduct('Test Productaa', 11, TRUE, FALSE);
        record.WebsiteID__c = 'xvnlxf54345dfd45';
        record.Product_Catalog_Number__c ='Tecst0ff2';
        Insert  record;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/ProductUpsert/';
        request.httpMethod = 'POST';
        String requestBody = '{"EventRequest":{"EventObject":"PRODUCT","EventDateTime":"2023-04-07T03:52:56","EventSourceSystem":"Website","EventBusinessID":"Test02","ProductData":[{"WebsiteID":"5ce04fdggg2851549ee4d92e73932432","SalesforceID":"'+record.Id+'","ProductCatalogNumber":"Tecst02","ProductName":"BIC® Clic Stic® Pen Test R","Categories":"Writing Instruments","SubCategories":"Retractables","Departments":"Salesforce","Brand":"BIC®","CountryofOrgin":"Mexico","ManufacturingSite":{"PostalCode":"33760","City":"Clearwater","State":"FL","Country":"US"},"ProductURL":"https://kg-uat-template.kooziegroup.com/US/bic-clic-stic-pen-cs","ProductImageURL":"https://kgstorageprod.blob.core.windows.net/kgblob/5ced3789cac7a0376835ba90_bic-clic-stic-pen.jpeg","ProductStatus":"I","PricingCode":"B","EndQtyPrice":11,"EndQtPriceCode":"BBBBBB","EndQtyRetailPrice":3}]}}';
        request.requestBody = Blob.valueof(requestBody);
        
        RestContext.request = request;
        RestContext.response = response; 
        Test.startTest();
        try{
            Test.setMock(HttpCalloutMock.class, new RestErrorMock());
            ProductUpsert.getProductRequest();
        }catch(Exception e){
            
        }
        
        Test.stopTest(); 
        
    }
    
    @IsTest
    public static void getProductRequestError_unitTest(){ 
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='https://cs13.salesforce.com/services/apexrest/ProductUpsert/';
        request.httpMethod = 'POST';
        try{
            String requestBody = '{"EventRequest":{"EventObject":"PRODUCT","EventDateTime":"2023-04-07T03:52:56","EventSourceSystem":"Website","EventBusinessID":"Test021","ProductData":[{"WebsiteID":"xvnlxfhf12454578df45434545","SalesforceID":"","ProductCatalogNumber":"Tecst0223","ProductName":"BIC® Clic Stic® Pen Test R","Categories":"Writing Instruments","SubCategories":"Retractables","Departments":"Salesforce","Brand":"BIC®","CountryofOrgin":"Mexico","ManufacturingSite":{"PostalCode":"33760","City":"Clearwater","State":"FL","Country":"US"},"ProductURL":"https://kg-uat-template.kooziegroup.com/US/bic-clic-stic-pen-cs","ProductImageURL":"https://kgstorageprod.blob.core.windows.net/kgblob/5ced3789cac7a0376835ba90_bic-clic-stic-pen.jpeg","ProductStatus":"I","PricingCode":"B","EndQtyPrice":"11","EndQtPriceCode":"BBBBBB","EndQtyRetailPrice":3}]}}';
            request.requestBody = Blob.valueof(requestBody);
            
            RestContext.request = request;
            RestContext.response = response;
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new RestErrorMock());
            ProductUpsert.getProductRequest();
            Test.stopTest();
            
        }catch(Exception e){
            
        }
        
        
    }   
    
    @isTest
    static void testResponseErrorWithErrors() {
        
         Product2 record = TestDataFactory.createSingleProduct('Test Productaa', 11, TRUE, FALSE);
        record.WebsiteID__c = 'xvnfdlxf54345dfd45';
        record.Product_Catalog_Number__c ='Tecst0fff2';
        Insert  record;
        // Mock Database.Error objects
        List<Database.Error> errors = new List<Database.Error>(); 
        
        // Call the method under test
        JSONGenerator gen = JSON.createGenerator(true);
        JSONGenerator result =  ProductUpsert.responseError(errors, gen); 
        String responseData = ProductUpsert.productResponse(ProductUpsert.STATUS.ERROR, record, errors);
    } 
    
}