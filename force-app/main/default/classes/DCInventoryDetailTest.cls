/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public  class DCInventoryDetailTest {
   @IsTest
    public static void mockSoql() {
    
        DataCloudDataFactory.loadData();
        
        Test.startTest();
        DCInventoryDetail.InputWrapper inp = new DCInventoryDetail.InputWrapper(); 
        inp.productId = 'Bear'; //'Ion Pen';

        List<DCInventory> info = DCInventoryDetail.getInventoryDetails(new List<DCInventoryDetail.InputWrapper>{inp});
        
        Test.stopTest();
        
        Assert.areEqual(1, info.size());
    }
}