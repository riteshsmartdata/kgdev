/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Kumar Saurav
 * JIRA TICKET        : SF-478
**/
@RestResource(urlMapping='/FindEBSOrder/*')
global without sharing class FindingOrderFromCustAccAndOrderNum {
    @HttpPOST
    global static void findOrder(String custAccNum, String ordernum ){
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String jsonS = '';
        if(String.isNotBlank(custAccNum) && String.isNotBlank(ordernum)){
            for(EBS_Order__c order : [
                SELECT Id, Customer_Account_Number__c, EBS_Order_Number__c,  Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c, Acc_Shipping_Notif_Contact_To_Email__c,Additional_Emails__c
                FROM EBS_Order__c
                WHERE  
                Customer_Account_Number__c =: custAccNum AND 
                EBS_Order_Number__c =: ordernum LIMIT 1
                
            ]){
                 jsonS = OrderJSONGenerator.orderJSON(order).getAsString();
                response.statusCode = 200;
                response.responseBody =  Blob.valueOf(jsonS);
                //jsonS = gen.getAsString();
                System.debug('====jsonS===='+jsonS);
            }
        }else{
            jsonS = 'Missing required parameters';
            response.statusCode = 400;
            response.responseBody =  Blob.valueOf(jsonS);
        }
    }
}