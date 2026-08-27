public class KG_ShipmentEmailController {
    // EBS_Order__c record id to be passed from Visualforce email template/component
    public static Id orderId { get; set; }

    // Return shipped lines only, mirroring VF_InvHold_LeadTimeAutomation pattern
    public static List<EBS_Order_Line__c> getEBSOrderLines() {
        return [
            SELECT Id,
                   Quantity__c,
                   External_Product_Name__c,
                   Scheduled_Ship_Date__c,
                   Ship_Method__c,
                   Product_Number__c,
                   Estimated_Arrival_Date__c,
                   Product_Color__c
            FROM EBS_Order_Line__c
            WHERE Order__c = :orderId
              AND TOV_Line_Status__c = 'COMPLETE'
        ];
    }
}