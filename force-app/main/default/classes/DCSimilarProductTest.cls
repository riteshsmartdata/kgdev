/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class DCSimilarProductTest {

    @IsTest
    public static void mockSoql() {
    
        DataCloudDataFactory.loadData();
        
        Test.startTest();
        DCSimilarProduct.InputWrapper inp = new DCSimilarProduct.InputWrapper(); 
        inp.productId = 'Bear'; //'Ion Pen';

        List<DCSimilarProduct.ProductNameWrapper> info = DCSimilarProduct.getSimilarProduct(new List<DCSimilarProduct.InputWrapper>{inp});
        
        Test.stopTest();
        
        Assert.areEqual(1, info.size());
    } 
}