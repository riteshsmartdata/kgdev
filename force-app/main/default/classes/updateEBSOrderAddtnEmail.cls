/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Kumar Saurav
 * JIRA TICKET        : SF-478
**/
@RestResource(urlMapping='/UpdateEBSOrder/*')
global without sharing class updateEBSOrderAddtnEmail {
    @HttpPOST
    global static String updateOrder(Id orderId, String additionalEmail ){// JIRA Ticket
        String jsonS = '';
        List<EBS_Order__c> ebsOrderList = new List<EBS_Order__c>();
        if(orderId != Null){
            Map<Id,EBS_Order__c> ordMap = new Map<Id,EBS_Order__c>([SELECT Id, Customer_Account_Number__c, EBS_Order_Number__c,
                                                                    Acc_PO_Contact_To_Email__c, Acc_Order_Confirm_Contact_To_Email__c,
                                                                    Acc_Shipping_Notif_Contact_To_Email__c, Additional_Emails__c 
                                                                    FROM EBS_Order__c
                                                                    WHERE Id =: orderId LIMIT 1]);
            
            if( ordMap.size() > 0 ) {
                for(String addEmail : ordMap.keySet()){
                    ebsOrderList.add( new EBS_Order__c(id=ordMap.get(addEmail).Id, Additional_Emails__c= additionalEmail));
                }
                Database.SaveResult[] srList = new Database.SaveResult[]{};
                if(ebsOrderList.size() > 0){
                    try{
                       srList = Database.update(ebsOrderList);
                    }catch(Exception exp){
                        jsonS = exp.getMessage();
                    }
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            jsonS = 'Successfully updated record with ID:'+sr.getId();
                        }
                    }
                }else {
                    jsonS = 'Order not found!';
                }
            }
        }
        return jsonS;
    }
}