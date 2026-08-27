public without sharing class PopulateAccEmails {
    
    // Handle recursion
    public static Boolean isfirstRun = true;
    
    //Variable to hold string values
    private static final String CRM_CONTACT = 'CRM Contact';
    private static final String EMAIL = 'Email';
    private static final String BOTH = 'Both';
    private static final String STATUS_ACTIVE = 'Active';
    
    // Variable to hold email type.
    public enum EmailType{
        PO_CONTACT,
            ORDER_ACKNOWLEDGEMENT,
            SHIPPING_CONTACT 
            }
    
    /**
* Description : Method is used in trigger to populate acc email on order object. 
* Param : 1 newOrderList : Hold new order records.
*/
    public static void populateEmail(List<EBS_Order__c> newOrderList){
        
        Set<String> accountIdSet = new Set<String>();
        Map<String, List<Contact>> accountContactMap = new Map<String,List<Contact>>();
        
        
        // Get account id from order and store in account id set
        if(!newOrderList.isEmpty()){
            for(EBS_Order__c order : newOrderList ){
                if(String.isNotBlank(order.Account_Name__c)){
                    accountIdSet.add(order.Account_Name__c);
                }
            } 
            
        }
        
        //System.debug('====== accountIdSet ====='+ accountIdSet);
        
        // Get contact record based on account id set and store them into account contact map.
        if(!accountIdSet.isEmpty()){
            for(Contact record : [
                SELECT 
                Id, AccountId, Email, Acc_PO_Contact__c, Acc_Order_Acknowledgement__c, PO_Confirmation__c, Acc_Shipping_Contact__c, 
                Order_Acknowledgement__c,Shipment_Confirmation__c
                FROM Contact 
                WHERE
                AccountId IN: accountIdSet AND 
                RecordType.Name = : CRM_CONTACT AND
                Email != NULL AND
                Contact_Status__c =: STATUS_ACTIVE LIMIT 50000
            ] ){
                if(accountContactMap.containsKey(record.AccountId)){
                    accountContactMap.get(record.AccountId).add(record);
                }else{
                    accountContactMap.put(record.AccountId, new List<Contact>{record});
                }
            } 
        }
        
        //System.debug('====== accountContactMap ====='+ accountContactMap);
        
        //check order list and get the email from account contact map and populate Acc fields. 
        if(!newOrderList.isEmpty()){
            for(EBS_Order__c order : newOrderList ){
                
                if(accountContactMap.containsKey(order.Account_Name__c)){
                    
                    String poEmail = getEmails(accountContactMap.get(order.Account_Name__c),PopulateAccEmails.EmailType.PO_CONTACT, String.isNotBlank(order.PO_Contact_Email__c) ? order.PO_Contact_Email__c:NULL);
                    order.Acc_PO_Contact_To_Email__c = poEmail;
                    if(order.Additional_Emails__c != null){
                       order.Acc_PO_Contact_To_Email__c = poEmail +', '+ order.Additional_Emails__c;
                   }                    
                    String orderEmail = getEmails(accountContactMap.get(order.Account_Name__c),PopulateAccEmails.EmailType.ORDER_ACKNOWLEDGEMENT, String.isNotBlank(order.Order_Confirmation_Email__c )? order.Order_Confirmation_Email__c:NULL);
                    order.Acc_Order_Confirm_Contact_To_Email__c = orderEmail;
                   if(order.Additional_Emails__c != null){
                     order.Acc_Order_Confirm_Contact_To_Email__c = orderEmail +', '+ order.Additional_Emails__c;
                    } 
                    String shipEmail = getEmails(accountContactMap.get(order.Account_Name__c),PopulateAccEmails.EmailType.SHIPPING_CONTACT, String.isNotBlank(order.Shipping_Notification_Email__c) ? order.Shipping_Notification_Email__c:NULL);
                    order.Acc_Shipping_Notif_Contact_To_Email__c = shipEmail; 
                    if(order.Additional_Emails__c != null){
                      order.Acc_Shipping_Notif_Contact_To_Email__c = shipEmail +', '+ order.Additional_Emails__c;
                    }
                }
            } 
        } 
    }
    
    private static Boolean isOptin(String communicationType, Boolean accountLevel, String optinMode){
        
        Boolean optin = FALSE;
        
        switch on optinMode {
            /**When PO Contact is not present on EBS order */
            when 'AccountLevel' {
                optin =  accountLevel == TRUE ? TRUE : FALSE;
            }
            
            /**When PO Contact is present on EBS order */
            When 'ContactLevel' {
                optin =  communicationType == EMAIL ? TRUE : FALSE;
            }
            
            when else {
                optin = FALSE;
            }
        }
        //System.debug('========optin emails======='+ optin);
        return optin;
    }
    
    private static string getInsertedContactEmail(List<Contact> contactList, String orderEmail){
        
        String email = '';
        Set<String> tempContacts = new Set<String>();
        if(!contactList.isEmpty()){
            for(contact record : contactList){
                tempContacts.add(record.Email);
            }
        }
        
        if(!tempContacts.isEmpty()){
            email = tempContacts.contains(orderEmail) || orderEmail == NULL?'':orderEmail;
        }
        
        //System.debug('========getInsertedContactEmail emails======='+ email);
        return email;
    }
    
    /**
* Description : method is used to get the comma seprated email. 
* param: contactList: Hold the contact list, 2) type : type of acc fields.
*/
    private static String getEmails(List<Contact> contactList, PopulateAccEmails.EmailType type, String orderEmail){
        String emails = ''; 
        if(!contactList.isEmpty()){
            
            for(Integer index =0; index < contactList.size(); index++ ){
                //for(Contact record : contactList){
                switch on  type {
                    when PO_CONTACT {
                        If(String.isNotBlank(orderEmail) && contactList[index].Email == orderEmail){
                            if(isOptin(contactList[index].PO_Confirmation__c, contactList[index].Acc_PO_Contact__c, 'ContactLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);
                                if(!emails.contains(contactList[index].Email)){
                                    emails +=  contactList[index].Email != NULL? contactList[index].Email +', ':'';
                                }
                                  
                                //contactList.remove(index);
                            }
                        }else{
                            if(isOptin(contactList[index].PO_Confirmation__c, contactList[index].Acc_PO_Contact__c, 'AccountLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);

                                if(!emails.contains(contactList[index].Email)){
                                    emails +=  contactList[index].Email != NULL? contactList[index].Email +', ':'';
                                }
                                
                                 
                                //contactList.remove(index);
                            }
                        }
                        //System.debug('======== PO_CONTACT======='+ type);
                        
                        
                        
                    }
                    
                    when ORDER_ACKNOWLEDGEMENT {
                        
                        If(String.isNotBlank(orderEmail) && contactList[index].Email == orderEmail){
                            if(isOptin(contactList[index].Order_Acknowledgement__c, contactList[index].Acc_Order_Acknowledgement__c,'ContactLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);
                                if(!emails.contains(contactList[index].Email)){
                                    emails +=  contactList[index].Email!= NULL ? contactList[index].Email +', ':'';
                                }

                               
                                //contactList.remove(index);
                            } 
                        }else{
                            if(isOptin(contactList[index].Order_Acknowledgement__c, contactList[index].Acc_Order_Acknowledgement__c,'AccountLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);
                                if(!emails.contains(contactList[index].Email)){
                                    emails +=  contactList[index].Email!= NULL ? contactList[index].Email +', ':'';
                                }
                                
                                //contactList.remove(index);
                            }    
                        }
                        //System.debug('======== ORDER_ACKNOWLEDGEMENT======='+ type);
                        
                    }
                    
                    when SHIPPING_CONTACT {
                        If(String.isNotBlank(orderEmail) && contactList[index].Email == orderEmail){
                            if(isOptin(contactList[index].Shipment_Confirmation__c, contactList[index].Acc_Shipping_Contact__c,'ContactLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);
                                if(!emails.contains(contactList[index].Email)){
                                    emails += contactList[index].Email != NULL? contactList[index].Email +', ':'';
                                }
                                 
                                //contactList.remove(index);
                            } 
                        }else{
                            //System.debug('======== SHIPPING_CONTACT======='+ type);
                            if(isOptin(contactList[index].Shipment_Confirmation__c, contactList[index].Acc_Shipping_Contact__c,'AccountLevel') == TRUE){
                                //System.debug('======== contactList[index].Email======='+ contactList[index].Email);
                                if(!emails.contains(contactList[index].Email)){
                                    emails += contactList[index].Email != NULL? contactList[index].Email +', ':'';
                                }
                                 
                                //contactList.remove(index);
                            } 
                        }
                        
                    }
                    
                    when else {
                        emails +=  '';   
                    }
                } 
                
                //System.debug('======== emails======='+ emails);
            }
            emails += ''+ getInsertedContactEmail(contactList,orderEmail); 
        }
        
        //System.debug('======== emails======='+ emails);
        return emails.removeEnd(', '); 
    } 
    
}