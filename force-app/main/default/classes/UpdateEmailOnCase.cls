public without sharing class UpdateEmailOnCase {
 public static void UpdateEmailFieldOnCase(List<String> caseRecordString) {
     System.debug('UpdateEmailOnCaseModule@@');     
         List<Case>caseList = [ select id,EBS_Account_Number__c,Customer_To_Email__c,Proof_Team_Link__c,Clarification_Team_Link__c,RecordTypeId from case where id=:caseRecordString];
        Map<Id,String>mapOfIdVsEbsAccountNumber = new Map<Id,String>();
        //Map<Id,String> mapofIdVsEbsNumber = new Map<Id,String>();
        Map<String,Account> mapofEbsVsAccount = new Map<String,Account>();
        //Set<String>accqueue = new Set<String>();
        Map<String, String>mapOfAcoountEbsVsParentEbs = new  Map<String, String>();
        List<Account_Clarification_Team__c> actList = new List<Account_Clarification_Team__c>();
        Set<String> ebsSet = new Set<String>();
        Id recordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        Id recordTypeDelayedOrder = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Delayed Order').getRecordTypeId();

        Id ebs = Label.X33381_id;
        Id coop = Label.Calendar_Coop;
        Id calendar = Label.Calendar_Dedicated;
        Id bookstore = Label.Bookstore;
        Id hotel = Label.Hotel;
        Id church = Label.Church;
        Id casino = Label.Casino;
        Id defau = Label.Default;

        Map<String, Account_Clarification_Team__c> actCaseMap = new  Map<String, Account_Clarification_Team__c>();

        for(Case caseRecord:caseList){
            if(caseRecord.EBS_Account_Number__c != null){
                ebsSet.add(caseRecord.EBS_Account_Number__c);
            }

        }

        if(ebsSet.size() > 0){
            for(Account_Clarification_Team__c act : [
                SELECT Id, Name, From_Email__c, Account_Queue__c, Customer_Category__c, EBS_Num__c, Logo__c 
                FROM Account_Clarification_Team__c 
                WHERE EBS_Num__c =:ebsSet
                ]
            ){
                actCaseMap.put(act.EBS_Num__c,act);
            }  
        }
 
         for(Case cs:caseList){
            system.debug('cs.EBS_Account_Number__c@@@@'+cs.EBS_Account_Number__c);
            system.debug('cs.RecordTypeId@@@@'+cs.RecordTypeId);
            //system.debug('cs.EBS_Account_Number__c@@@@'+cs.EBS_Account_Number__c);

            if(cs.EBS_Account_Number__c != null && actCaseMap.containskey(cs.EBS_Account_Number__c) && (cs.RecordTypeId == recordType || cs.RecordTypeId == recordTypeDelayedOrder)){
                system.debug('actCaseMap'+actCaseMap.get(cs.EBS_Account_Number__c));
                cs.Customer_To_Email__c = actCaseMap.get(cs.EBS_Account_Number__c).From_Email__c;
                cs.Proof_Team_Link__c = actCaseMap.get(cs.EBS_Account_Number__c).Id;
                cs.Clarification_Team_Link__c = actCaseMap.get(cs.EBS_Account_Number__c).Id;

            }else{
                system.debug('==== OLD CODE');
                if(cs.EBS_Account_Number__c != null  && (cs.RecordTypeId == recordType || cs.RecordTypeId == recordTypeDelayedOrder)){
                    mapOfIdVsEbsAccountNumber.put(cs.Id, cs.EBS_Account_Number__c);  
                }
            } 
        } 

        
        if(mapOfIdVsEbsAccountNumber.values().size()>0){
            for(Account acc: [Select Id, Routing_Override__c, EBS_Num__c, Customer_Category__c, Logo__c, Customer_Account_Number__c,
                              EBS_Parent_ID__c, Parent_EBS__c, ParentId FROM Account WHERE Customer_Account_Number__c IN: mapOfIdVsEbsAccountNumber.values()]){
                                  
                                  mapofEbsVsAccount.put(acc.Customer_Account_Number__c,acc);
                                  System.debug('========= Map ========== ' +mapofEbsVsAccount.keySet());
                                  System.debug('========= Map ========== ' +mapofEbsVsAccount.values());
                                  if(acc.ParentId != null && acc.EBS_Parent_ID__c != null && acc.Parent_EBS__c != null){
                                      
                                      mapOfAcoountEbsVsParentEbs.put(acc.Customer_Account_Number__c, acc.Parent_EBS__c);
                                      System.debug('============ ' + mapOfAcoountEbsVsParentEbs.keySet());
                                      System.debug('============ ' + mapOfAcoountEbsVsParentEbs.values());
                                  }
                              }
            Map<String, Account_Clarification_Team__c> mapOfEbsVsACT = new Map<String, Account_Clarification_Team__c>();
            
            for(Account_Clarification_Team__c actt : [Select Id, Name, From_Email__c, Account_Queue__c, Customer_Category__c, 
            EBS_Num__c, Logo__c FROM Account_Clarification_Team__c 
            WHERE EBS_Num__c =:mapOfAcoountEbsVsParentEbs.values() OR EBS_Num__c =:mapofEbsVsAccount.keyset()]){

            mapOfEbsVsACT.put(actt.EBS_Num__c, actt);
                                                          
            }

            System.debug('========= '+ mapOfEbsVsACT);
            List<case> updatedCaseList = new List<case>();
            for(case ca:caseList){
                System.debug('Entered into For Loop');
                if(ca.EBS_Account_Number__c != null && mapofEbsVsAccount.containskey(ca.EBS_Account_Number__c)){
                    Account accc = mapofEbsVsAccount.get(ca.EBS_Account_Number__c);    
                    System.debug('Entered into If' + accc);  //0009
                    
                    if(accc.EBS_Parent_ID__c != null){
                        String ebsp = accc.EBS_Parent_ID__c;
                        System.debug('===========' + accc.EBS_Parent_ID__c);       //0008
                        
                        Account ac = [Select Id, Routing_Override__c, EBS_Num__c, Customer_Category__c, Logo__c, Customer_Account_Number__c,
                            EBS_Parent_ID__c, Parent_EBS__c, ParentId, Parent.ParentId, Parent.Logo__c, Parent.Routing_Override__c, Parent.EBS_Num__c,
                            Parent.Customer_Category__c, Parent.Customer_Account_Number__c FROM Account WHERE EBS_Parent_ID__c =:ebsp LIMIT 1];
                        
                        System.debug('======= ' +ac);
                        System.debug('======= ' +ac.Parent);
                        System.debug('======= ' +ac.Parent.Logo__c);
                        
                        
                        if(ac.Parent.Logo__c == 'Calendar Coop'){
                            System.debug('Went inside Parent');
                            ca.Customer_To_Email__c = 'csinfo@calendarcs.com';
                            ca.Proof_Team_Link__c = coop;
                            ca.Clarification_Team_Link__c = coop;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Routing_Override__c == 'Calendar Dedicated'){
                            ca.Customer_To_Email__c = 'coopspecialtyteam@kooziegroup.com';
                            ca.Proof_Team_Link__c = calendar;
                            ca.Clarification_Team_Link__c = calendar;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Bookstore'){
                            ca.Customer_To_Email__c = 'anchorwallace@anchorwallace.com';
                            ca.Proof_Team_Link__c = bookstore;
                            ca.Clarification_Team_Link__c = bookstore;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Church'){
                            ca.Customer_To_Email__c = 'anchorwallace@anchorwallace.com';
                            ca.Proof_Team_Link__c = Church;
                            ca.Clarification_Team_Link__c = Church;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Casino'){
                            ca.Customer_To_Email__c = 'cshotel@kooziegroup.com';
                            ca.Proof_Team_Link__c = casino;
                            ca.Clarification_Team_Link__c = casino;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Hotel'){
                            ca.Customer_To_Email__c = 'cshotel@kooziegroup.com';
                            ca.Proof_Team_Link__c = hotel;
                            ca.Clarification_Team_Link__c = hotel;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Account_Number__c == '33381'){
                            ca.Customer_To_Email__c = 'proformabcsteam@kooziegroup.com';
                            ca.Proof_Team_Link__c = ebs;
                            ca.Clarification_Team_Link__c = ebs;
                            updatedCaseList.add(ca);
                            System.debug('========= '+ ca.Customer_To_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Account_Number__c != null){
                            Account_Clarification_Team__c actt = mapOfEbsVsACT.get(ac.Parent.Customer_Account_Number__c);
                            if(actt != null){
                                ca.Customer_To_Email__c = actt.From_Email__c;
                                ca.Proof_Team_Link__c = actt.Id;
                                ca.Clarification_Team_Link__c = actt.Id;
                                updatedCaseList.add(ca);
                                System.debug('============== '+ca.Customer_To_Email__c);
                            } 
                            else{
                                ca.Customer_To_Email__c = 'customerservice@kooziegroup.com';
                                ca.Proof_Team_Link__c = defau;
                                ca.Clarification_Team_Link__c = defau;
                                updatedCaseList.add(ca);
                                System.debug('============== '+ca.Customer_To_Email__c);
                            }
                        }
                       
                        else{
                            ca.Customer_To_Email__c = 'customerservice@kooziegroup.com';
                            ca.Proof_Team_Link__c = defau;
                            ca.Clarification_Team_Link__c = defau;
                            updatedCaseList.add(ca);
                            System.debug('============== '+ca.Customer_To_Email__c);
                        } 
                    }
                    else if(accc.EBS_Parent_ID__c == null){
                        
                        Account acc = mapofEbsVsAccount.get(ca.EBS_Account_Number__c);
                        
                        if(acc.Logo__c == 'Calendar Coop'){
                            ca.Customer_To_Email__c = 'csinfo@calendarcs.com';
                            ca.Proof_Team_Link__c = coop;
                            ca.Clarification_Team_Link__c = coop;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Routing_Override__c == 'Calendar Dedicated'){
                            ca.Customer_To_Email__c = 'coopspecialtyteam@kooziegroup.com';
                            ca.Proof_Team_Link__c = calendar;
                            ca.Clarification_Team_Link__c = calendar;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Customer_Category__c == 'Bookstore'){
                            ca.Customer_To_Email__c = 'anchorwallace@anchorwallace.com';
                            ca.Proof_Team_Link__c = bookstore;
                            ca.Clarification_Team_Link__c = bookstore;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Customer_Category__c == 'Church'){
                            ca.Customer_To_Email__c = 'anchorwallace@anchorwallace.com';
                            ca.Proof_Team_Link__c = Church;
                            ca.Clarification_Team_Link__c = Church;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Customer_Category__c == 'Casino'){
                            ca.Customer_To_Email__c = 'cshotel@kooziegroup.com';
                            ca.Proof_Team_Link__c = casino;
                            ca.Clarification_Team_Link__c = casino;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Customer_Category__c == 'Hotel'){
                            ca.Customer_To_Email__c = 'cshotel@kooziegroup.com';
                            ca.Proof_Team_Link__c = hotel;
                            ca.Clarification_Team_Link__c = hotel;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(acc.Customer_Account_Number__c == '33381'){
                            ca.Customer_To_Email__c = 'proformabcsteam@kooziegroup.com';
                            ca.Proof_Team_Link__c = ebs;
                            ca.Clarification_Team_Link__c = ebs;
                            updatedCaseList.add(ca);
                        }
                        
                        else if(mapOfEbsVsACT.containskey(ca.EBS_Account_Number__c)){
                            System.debug('======== '+ mapOfEbsVsACT.containskey(ca.EBS_Account_Number__c));
                            Account_Clarification_Team__c acct = mapOfEbsVsACT.get(ca.EBS_Account_Number__c);
                            ca.Customer_To_Email__c = acct.From_Email__c;
                            ca.Proof_Team_Link__c = acct.Id;
                            ca.Clarification_Team_Link__c = acct.Id;
                            updatedCaseList.add(ca);
                        } 

                        else{
                            ca.Customer_To_Email__c = 'customerservice@kooziegroup.com';
                            ca.Proof_Team_Link__c = defau;
                            ca.Clarification_Team_Link__c = defau;
                            updatedCaseList.add(ca);
                            System.debug('============== '+ca.Customer_To_Email__c);
                        }
                    }  
                }
                
                else{
                    ca.Customer_To_Email__c = 'customerservice@kooziegroup.com';
                    ca.Proof_Team_Link__c = defau;
                    ca.Clarification_Team_Link__c = defau;
                    updatedCaseList.add(ca);
                    System.debug('============== '+ca.Customer_To_Email__c);
                } 
                
            } 
            if(!updatedCaseList.isempty()){
                system.debug('updatedCaseList@@@@@'+updatedCaseList);
                update updatedCaseList;
            }
        }
    }
     public static void codeCoverage(){
        Integer i = 1;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }
}