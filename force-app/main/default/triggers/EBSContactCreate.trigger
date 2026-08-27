/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-17-2022
 * @last modified by  : Ritesh Kumar
**/
//Global Contact Trigger
trigger EBSContactCreate on Contact (after Insert, after update) { 

    //List for contacts to create in EBS
    List<Contact> contEBSInsert = new List<Contact>();
    List<ID> lstInsertId = new List<ID>(); 

    //Trigger if after insert
    if(trigger.isAfter && trigger.isInsert){ 
        
        system.debug('EBSContactCreate trigger called@@@@@@@@@@@');
        //Loop through list of contacts
        For(Contact insCont : trigger.new){
        
            String lName = insCont.LastName;

            // Addred Record type filter for EBS             
            if(//insCont.lastmodifiedbyid != '0051U000001M0nl' && (!lName.contains('@')) 
            InsCont.Responsibility_Type__c != 'WEBSITE' && 1<2 && insCont.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId()){ //
                //Make sure accounts not updated twice
                lstInsertId.add(insCont.Id);
                
                //Check Recursive
                If(!checkRecursive.SetOfIDs.contains(insCont.Id)){
                                    
                    //If contact is integration type then add to contact list
                    EBSContactDML.getJsonString(insCont.Id, 'CREATE');                
                }

                // Addred Record type filter for EBS
            } else if(//insCont.lastmodifiedbyid != '0051U000001M0nl' && 
                (lName.contains('@')) && insCont.Responsibility_Type__c != 'WEBSITE' && insCont.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId()){
                //Make sure accounts not updated twice
                lstInsertId.add(insCont.Id);
                
                //Check Recursive
                If(!checkRecursive.SetOfIDs.contains(insCont.Id)){
                                    
                    //If contact is integration type then add to contact list
                    EBSContactDML.getJsonStringNotFuture(insCont.Id, 'CREATE');                
                }
            }
        }
    } 
    //Trigger if after update
    else if(trigger.isAfter && trigger.isUpdate && !System.isFuture()){
         
        //Loop through list of contacts
        For(Contact insCont : trigger.new){

            contact cont = trigger.OldMap.get(insCont.ID);
            DateTime dtOld = cont.Date_Verified__c;
            String lName = insCont.LastName;            

            boolean contFieldsChanged = (cont.email == insCont.email && cont.Other_Email__c == insCont.Other_Email__c && 
                cont.Phone == insCont.Phone && cont.OtherPhone == insCont.OtherPhone && cont.Fax == insCont.Fax &&
                insCont.Date_Verified__c == cont.Date_Verified__c && 
                insCont.Primary_Responsibility_Flag__c == cont.Primary_Responsibility_Flag__c &&
                insCont.Responsibility_Type__c == cont.Responsibility_Type__c) ? false : true;

            // Addred Record type filter for EBS
            //Make sure 'Verified' checkbox doesn't cause recursive behaviour
            if(insCont.lastmodifiedbyid != '0051U000001M0nl' && contFieldsChanged && (!lName.contains('@')) && insCont.Responsibility_Type__c != 'WEBSITE' && insCont.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId()){
                //Check Recursive
                If(!checkRecursive.SetOfIDs.contains(insCont.Id)){
                    
                    if(insCont.Contact_ID__c != null){
                        //If contact is integration type then add to contact list
                        EBSContactDML.getJsonString(insCont.Id, 'UPDATE');    
                    } else {
                        //If contact is integration type then add to contact list
                        EBSContactDML.getJsonString(insCont.Id, 'CREATE');   

                    }            
                } 
                
                // Addred Record type filter for EBS
            } else if(insCont.lastmodifiedbyid != '0051U000001M0nl' && contFieldsChanged && (!lName.contains('@')) && insCont.Responsibility_Type__c != 'WEBSITE' && insCont.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId()){
                //Check Recursive
                If(!checkRecursive.SetOfIDs.contains(insCont.Id)){
                    
                    if(insCont.Contact_ID__c != null){
                        //If contact is integration type then add to contact list
                        EBSContactDML.getJsonStringNotFuture(insCont.Id, 'UPDATE');    
                    } else {
                        //If contact is integration type then add to contact list
                        EBSContactDML.getJsonStringNotFuture(insCont.Id, 'CREATE');   

                    }            
                }                   
            }
        }
    }
}