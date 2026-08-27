/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : Mohammad Arafat Ali
**/
public without sharing class EmailOnEBSOrderHandler {
    public static void UpdateEmailOnEBSOrder(List<EBS_Order__c>ebsList){

        Map<Id,String>mapOfIdVsEbsAccountNumber = new Map<Id,String>();
        Map<String,Account> mapofEbsVsAccount = new Map<String,Account>();
        Map<String, String>mapOfAcoountEbsVsParentEbs = new  Map<String, String>();
        List<Account_Clarification_Team__c> actList = new List<Account_Clarification_Team__c>();
        Set<String> ebsSet = new Set<String>();

        /*Id ebs = Label.X33381_id;
        Id coop = Label.Calendar_Coop;
        Id calendar = Label.Calendar_Dedicated;
        Id bookstore = Label.Bookstore;
        Id hotel = Label.Hotel; 
        Id church = Label.Church;
        Id casino = Label.Casino;
        Id defau = Label.Default;*/

        Map<String, Account_Clarification_Team__c> actEBSMap = new  Map<String, Account_Clarification_Team__c>();

        for(EBS_Order__c ebsRecord:ebsList){
            if(ebsRecord.Customer_Account_Number__c != null){
                ebsSet.add(ebsRecord.Customer_Account_Number__c);
                System.debug('======== EBS Customer Account Number ========= ' +ebsSet);
            }
        }

        if(ebsSet.size() > 0){
            for(Account_Clarification_Team__c act : [SELECT Id, Name, From_Email__c, Account_Queue__c, Customer_Category__c, EBS_Num__c, 
            Logo__c FROM Account_Clarification_Team__c WHERE EBS_Num__c =:ebsSet]){

                actEBSMap.put(act.EBS_Num__c,act);
                System.debug('========== ACT Map ======== ' +actEBSMap);
            }  
        }

        for(EBS_Order__c cs:ebsList){
            System.debug('=====cs.Customer_Account_Number__c@@@@======' +cs.Customer_Account_Number__c);
            
            if(cs.Customer_Account_Number__c != null && actEBSMap.containskey(cs.Customer_Account_Number__c)){
                System.debug('actEBSMap'+actEBSMap.get(cs.Customer_Account_Number__c));
                cs.From_Email__c = actEBSMap.get(cs.Customer_Account_Number__c).From_Email__c;
                System.debug('======== From Email ========== ' +cs.From_Email__c);

            }else{
                if(cs.Customer_Account_Number__c != null){
                    mapOfIdVsEbsAccountNumber.put(cs.Id, cs.Customer_Account_Number__c);  
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
            
            for(EBS_Order__c ca:ebsList){
                System.debug('Entered into For Loop');
                if(ca.Customer_Account_Number__c != null && mapofEbsVsAccount.containskey(ca.Customer_Account_Number__c)){
                    Account accc = mapofEbsVsAccount.get(ca.Customer_Account_Number__c);    
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
                            ca.From_Email__c = 'csinfo@calendarcs.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Routing_Override__c == 'Calendar Dedicated'){
                            ca.From_Email__c = 'coopspecialtyteam@kooziegroup.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Bookstore'){
                            ca.From_Email__c = 'anchorwallace@anchorwallace.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Church'){
                            ca.From_Email__c = 'anchorwallace@anchorwallace.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Casino'){
                            ca.From_Email__c = 'cshotel@kooziegroup.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Category__c == 'Hotel'){
                            ca.From_Email__c = 'cshotel@kooziegroup.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Account_Number__c == '33381'){
                            ca.From_Email__c = 'proformabcsteam@kooziegroup.com';
                            System.debug('========= '+ ca.From_Email__c);
                        }
                        
                        else if(ac.Parent.Customer_Account_Number__c != null){
                            Account_Clarification_Team__c actt = mapOfEbsVsACT.get(ac.Parent.Customer_Account_Number__c);
                            if(actt != null){
                                ca.From_Email__c = actt.From_Email__c;
                                System.debug('============== '+ca.From_Email__c);
                            } 
                        }
                       
                        else{
                            ca.From_Email__c = 'customerservice@kooziegroup.com';
                            System.debug('============== '+ca.From_Email__c);
                        } 
                    }
                    else if(accc.EBS_Parent_ID__c == null){
                        
                        Account acc = mapofEbsVsAccount.get(ca.Customer_Account_Number__c);
                        
                        if(acc.Logo__c == 'Calendar Coop'){
                            ca.From_Email__c = 'csinfo@calendarcs.com';
                        }
                        
                        else if(acc.Routing_Override__c == 'Calendar Dedicated'){
                            ca.From_Email__c = 'coopspecialtyteam@kooziegroup.com';
                            }
                        
                        else if(acc.Customer_Category__c == 'Bookstore'){
                            ca.From_Email__c = 'anchorwallace@anchorwallace.com';
                            }
                        
                        else if(acc.Customer_Category__c == 'Church'){
                            ca.From_Email__c = 'anchorwallace@anchorwallace.com';
                           }
                        
                        else if(acc.Customer_Category__c == 'Casino'){
                            ca.From_Email__c = 'cshotel@kooziegroup.com';
                            }
                        
                        else if(acc.Customer_Category__c == 'Hotel'){
                            ca.From_Email__c = 'cshotel@kooziegroup.com';
                            }
                        
                        else if(acc.Customer_Account_Number__c == '33381'){
                            ca.From_Email__c = 'proformabcsteam@kooziegroup.com';
                           }
                        
                        else if(mapOfEbsVsACT.containskey(ca.Customer_Account_Number__c)){
                            System.debug('======== '+ mapOfEbsVsACT.containskey(ca.Customer_Account_Number__c));
                            Account_Clarification_Team__c acct = mapOfEbsVsACT.get(ca.Customer_Account_Number__c);
                            ca.From_Email__c = acct.From_Email__c;
                            } 

                        else{
                            ca.From_Email__c = 'customerservice@kooziegroup.com';
                            System.debug('============== '+ca.From_Email__c);
                        }
                    }  
                }
                
                else{
                    ca.From_Email__c = 'customerservice@kooziegroup.com';
                    System.debug('============== '+ca.From_Email__c);
                }        
            }           
        }
    }
}