public class VF_InvHold_LeadTimeAutomation {
    //EBS_Order__c record id to be passed from Visualforce email template:KG_InventoryHoldEmailTemplate
    // and VF component named <c:KG_InventoryHoldBody/>
    public static Id orderId{ get; set; }
    
    public static List<EBS_Order_Line__c> getEBSOrderLines(){
        return [SELECT Id, Quantity__c, External_Product_Name__c,Scheduled_Ship_Date__c,Ship_Method__c, Product_Number__c,Estimated_Arrival_Date__c,Product_Color__c FROM EBS_Order_Line__c WHERE Order__c =: orderId  AND TOV_Line_Status__c ='In Production'];
    }
}