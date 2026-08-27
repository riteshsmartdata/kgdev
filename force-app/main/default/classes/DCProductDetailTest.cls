/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class DCProductDetailTest {
     @IsTest
    public static void mockSoql() {
    
        DataCloudDataFactory.loadData();
        
        Test.startTest();
        DCProductDetail.InputWrapper inp = new DCProductDetail.InputWrapper(); 
        inp.productId = 'Bear'; //'Ion Pen';

        List<DCProduct> info = DCProductDetail.getProductDetails(new List<DCProductDetail.InputWrapper>{inp});
        
        Test.stopTest();
        
        Assert.areEqual(1, info.size());
    }
}