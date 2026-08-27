/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-25-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class DCProduct {
    @AuraEnabled @InvocableVariable public String productId;
    @AuraEnabled @InvocableVariable public String productName;
    @AuraEnabled @InvocableVariable public String productCategory;
    @AuraEnabled @InvocableVariable public String productSubCategory;
    @AuraEnabled @InvocableVariable public String websiteULR;
    @AuraEnabled @InvocableVariable public  List<ProductWrapper> detail;
}