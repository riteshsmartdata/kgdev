public with sharing class AccountSampleOrdersController {
    @AuraEnabled(cacheable=true)
    public static List<OrderWrapper> getAccountOrders(Id accountId) {
        List<OrderWrapper> orderWrappers = new List<OrderWrapper>();
        
        List<EBS_Order__c> ebsOrders = [ 
            SELECT Id, Name, EBS_Order_Number__c, Effective_Date__c, Order_Header_Total__c, Order_Header_Charges__c, 
                   Order_Header_Status__c, Customer_PO__c, Incl_in_Samples_Journey__c, Date_Ordered__c, Order_Type__c,
                   (SELECT Id, External_Product_Name__c FROM EBS_Order_Lines__r) 
            FROM EBS_Order__c 
            WHERE Account_Name__c = :accountId
              AND Order_Type__c LIKE 'Sample%'
            ORDER BY Date_Ordered__c DESC, Effective_Date__c DESC 
            LIMIT 1000 
        ];

        for (EBS_Order__c ebs : ebsOrders) {
            if (ebs.EBS_Order_Lines__r != null && !ebs.EBS_Order_Lines__r.isEmpty()) {
                for (EBS_Order_Line__c ebsOrderLine : ebs.EBS_Order_Lines__r) {
                    orderWrappers.add(new OrderWrapper(ebs, ebsOrderLine));
                }
            } else {
                orderWrappers.add(new OrderWrapper(ebs, null));
            }
        }
        return orderWrappers;
    }

    public class OrderWrapper {
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String EBSOrderNumber { get; set; }
        @AuraEnabled public String ExternalProductName { get; set; }
        @AuraEnabled public Datetime EffectiveDate { get; set; }
        @AuraEnabled public Decimal OrderHeaderTotal { get; set; }
        @AuraEnabled public String OrderHeaderStatus { get; set; }
        @AuraEnabled public String CustomerPO { get; set; }
        @AuraEnabled public Boolean Incl_in_Samples_Journey { get; set; }
        @AuraEnabled public String Id { get; set; }

        public OrderWrapper(EBS_Order__c ebsOrder, EBS_Order_Line__c ebsOrderLine) {
            this.Name = ebsOrder.Name;
            this.EBSOrderNumber = ebsOrder.EBS_Order_Number__c;
            this.ExternalProductName = ebsOrderLine != null ? ebsOrderLine.External_Product_Name__c : null;
            this.EffectiveDate = ebsOrder.Effective_Date__c;
            this.OrderHeaderTotal = ebsOrder.Order_Header_Total__c;
            this.OrderHeaderStatus = ebsOrder.Order_Header_Status__c;
            this.CustomerPO = ebsOrder.Customer_PO__c;
            this.Incl_in_Samples_Journey = ebsOrder.Incl_in_Samples_Journey__c;
            this.Id = ebsOrder.Id;
        }
    }
}