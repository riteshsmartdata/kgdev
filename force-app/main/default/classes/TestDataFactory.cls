/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-26-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-02-2023   Ritesh Kumar   Initial Version
**/
@isTest
public without sharing class TestDataFactory {
    public TestDataFactory() {
        System.debug('======= = =====');
    }

    public TestDataFactory(String name) {
        loadAppSetting();
        switchTriggerSetting();
    }

    public static Product2 createSingleProduct(String productName,  Double price, Boolean isActive,Boolean isInsert){
        Product2 record = new Product2();
        record.Name = productName;
        record.WebsiteID__c = 'xvnlxfhf12454578df45434545';   
        record.Product_Catalog_Number__c ='Tecst02'; 
        record.Product_Category__c =  'Writing Instruments';
        record.Product_Sub_Category__c = 'Retractables';
        record.Pricing_Code__c = 'CB1233';
        record.End_QTY_Price__c = price;
        record.End_QTY_Price_Code__c = 'CA123';
        record.End_QTY_Retail_Price__c = 11;
        record.IsActive = isActive;

        if(isInsert){
            Insert record;
        }


        return record;
    }

    public static Account createAccount(String name, String customerAccountNumber,String recordTypeName,Boolean isInsert){
        Account accountRecord = new Account();
        accountRecord.Name = name;
        accountRecord.Status__c = 'Active';
        accountRecord.Customer_Account_Number__c =  customerAccountNumber;
        accountRecord.RecordTypeId = KoozieUtility.getRecordTypeId('Account', recordTypeName);
        if(isInsert)
            Insert accountRecord;
        
        return accountRecord; 
    }

    public static Contact createContact(String lastName, String firstName , Id accountId, String recordTypeName, Boolean isInsert ){

        Contact contactRecord = new Contact();
        contactRecord.FirstName = firstName;
        contactRecord.LastName = lastName;
        contactRecord.RecordTypeId = KoozieUtility.getRecordTypeId('Contact', recordTypeName);
        contactRecord.email = 'test@test.com.invalid';
        contactRecord.phone = '123456789'; 
        contactRecord.Contact_Status__c = 'Active';
        if(accountId != null) contactRecord.AccountId = accountId;
        
        if(isInsert)
            Insert contactRecord;
        
        return contactRecord; 
    }
    
    public static void loadAppSetting(){
        AppInfo__c ce1 = new AppInfo__c();
        ce1.Name = 'Sandbox'; 
        ce1.User__c = 'webclient';
        ce1.Password__c = 'eh8q4ya4bvnx5';
        ce1.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce1; 
        
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'WebClient'; 
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce; 
    }
    
    public static void switchTriggerSetting(){
        SwitchTrigger__c ce1 = new SwitchTrigger__c();
        ce1.Name = 'EmailLinkTrigger';
        insert ce1;
    }

    
}