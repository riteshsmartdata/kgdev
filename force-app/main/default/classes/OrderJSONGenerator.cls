/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Kumar Saurav
 * JIRA TICKET        : SF-478
**/
global without sharing class OrderJSONGenerator {
    global static JSONGenerator orderJSON(EBS_Order__c order ){
         JSONGenerator gen = JSON.createGenerator (true);
            gen.writeStartObject();
             if(order.Id != null){
                gen.writeStringField('SFId', order.Id);
            }else{
                gen.writeNullField('SFId');
            }
            if(String.isNotBlank( order.Acc_PO_Contact_To_Email__c)){
                gen.writeStringField('accPOContactToEmail', order.Acc_PO_Contact_To_Email__c);
            }else{
                gen.writeNullField('accPOContactToEmail');
            }
            if(String.isNotBlank( order.Acc_Order_Confirm_Contact_To_Email__c)){
                gen.writeStringField('accOrderConfirmContactToEmail', order.Acc_Order_Confirm_Contact_To_Email__c);
            }else{
                gen.writeNullField('accOrderConfirmContactToEmail');
            }
            if(String.isNotBlank( order.Acc_Shipping_Notif_Contact_To_Email__c)){
                gen.writeStringField('accShippingNotifContactToEmail', order.Acc_Shipping_Notif_Contact_To_Email__c);
            }else{
                gen.writeNullField('accShippingNotifContactToEmail');
            }
            if(String.isNotBlank( order.Additional_Emails__c)){
                gen.writeStringField('additionalEmail', order.Additional_Emails__c);
            }else{
                gen.writeNullField('additionalEmail');
            }
            gen.writeEndObject(); 
        return gen;
    }

}