public class VFEmailController {
    //EBS_Order id passed in from email template
    public static Id EbsId { get; set; }
    
    public static List<EBS_Order_Line__c> getEBSOrderLines(){
        return [SELECT Id, Quantity__c, External_Product_Name__c, Product_Number__c,Product_Color__c FROM EBS_Order_Line__c WHERE Order__c =: EbsId  AND TOV_Line_Status__c ='In Production'];
    }
}