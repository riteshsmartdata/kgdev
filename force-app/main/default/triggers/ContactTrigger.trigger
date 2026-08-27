/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 02-13-2025
* @last modified by  : Ritesh Kumar
**/
trigger ContactTrigger on Contact (After insert , After update, After Delete) {
    
    Trigger_Settings__mdt [] triggerSetting  = [SELECT DeveloperName, Is_Active__c, Object_Name__c FROM Trigger_Settings__mdt   WHERE DeveloperName ='ContactTrigger' LIMIT 1];
    
    if(triggerSetting.size() >0  && triggerSetting[0].Is_Active__c == true){
        
        if(SendContactCallOut.isfirstRun == true){
            /*if(Trigger.isAfter){
                if(Trigger.isUpdate){
                    SendContactCallOut.sendContactInformation(Trigger.new, Trigger.oldMap, 'UPDATE'); 
                }
                if(Trigger.isInsert){
                    System.debug('===Insert trigger called===');
                    SendContactCallOut.sendContactInformation(Trigger.new, Trigger.oldMap, 'INSERT');
                }
            }*/
            
            if( Trigger.isAfter){
                if(Trigger.isInsert ){
                    ContactRoleHandler.handelRole(Trigger.new);
                }
                if(Trigger.isUpdate){
                    ContactRoleHandler.handelRole(Trigger.new);
                  /* List<Contact> contactsToMarkAsWinner = new List<Contact>();
                    
                    for (Contact newContact : Trigger.new) {
                        if (ContactMergeHelper.contactIds.contains(newContact.Id)) {
                            continue;
                        }
                        
                        Contact oldContact = Trigger.oldMap.get(newContact.Id);
                        if(!(oldContact.MailingStreet != newContact.MailingStreet || oldContact.MailingCity != newContact.MailingCity || oldContact.MailingPostalCode != newContact.MailingPostalCode || oldContact.MailingCountry  != newContact.MailingCountry)){
                           
                        }
                    }
                    ContactMergeHelper.contactIds.clear();*/
                }
                if (Trigger.isDelete) {
                    Set<Id> deletedContactIds = Trigger.oldMap.keySet();
                    List<Contact> conList = Trigger.oldMap.values();
                    List<Contact_Roles__c> controlesList = [SELECT Id, Contact__c,CreatedDate, Contact_Role_Name__c 
                                                            FROM Contact_Roles__c 
                                                            WHERE Contact__c IN :deletedContactIds];
                    
                    ContactMergeHelper.handleContactPostMerge(conList);
                }
                
            }
            
        }
        SendContactCallOut.isfirstRun = false;
    }  
}