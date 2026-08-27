/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-31-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
public without sharing class PopulateFromEmailOnOrder {

    //Variable to hold from email values
    private static final string CALENDAR_COOP = 'csinfo@calendarcs.com';
    private static final string CALENDAR_DEDICATED = 'coopspecialtyteam@kooziegroup.com';
    private static final string ANCHOR_WALLACE = 'anchorwallace@anchorwallace.com'; 
    private static final string CS_HOTEL = 'cshotel@kooziegroup.com';
    private static final string ACCOUNT_33381 = 'proformabcsteam@kooziegroup.com';
    private static final string CUSTOMER_SERVICE = 'customerservice@kooziegroup.com';
    private static final string GARY_CONTAINERS = 'customerservice@garycontainers.com';


    /**
     * Description : method is used in Order trigger to populate FromEmail Value on Order
     * param : newOrderList holds Order records
     */
    public static void populateFromEmail(List<EBS_Order__c> newOrderList){
		System.debug('===== populateFromEmail ====='+ newOrderList);
        Set<String> customerAccountSet = new Set<String>();
        Map<String, Account_Clarification_Team__c> accountTeamMap = new  Map<String, Account_Clarification_Team__c>();
        Map<String,String> parentAccountMap = new Map<String,String>();
        Map<String,Account> accountMap = new Map<String,Account>();
        
        if(!newOrderList.isEmpty()){
            for(EBS_Order__c order : newOrderList){
                if(order.Customer_Account_Number__c != null){
                    customerAccountSet.add(order.Customer_Account_Number__c); 
                }
            }
        }

        if(!customerAccountSet.isEmpty()){
           parentAccountMap = getParentAccounts(customerAccountSet);
           //System.debug('===== parentAccountMap ====='+ parentAccountMap);
        }

        if(!parentAccountMap.isEmpty()){
            customerAccountSet.addAll(parentAccountMap.values());
        }
       //System.debug('===== customerAccountSet ====='+ customerAccountSet);

        if(!customerAccountSet.isEmpty()){
             accountMap = getAccounts(customerAccountSet);
             accountTeamMap = getAccountTeams(customerAccountSet);
            //System.debug('===== Account ====='+ accountMap);
            //System.debug('===== accountTeamMap ====='+ accountTeamMap);
        }

        if(!newOrderList.isEmpty()){
            for(EBS_Order__c order : newOrderList){

                if(String.isNotBlank(order.Customer_Account_Number__c)){

                    if(parentAccountMap.containsKey(order.Customer_Account_Number__c)){
                        order.From_Email__c = getFromEmail(parentAccountMap.get(order.Customer_Account_Number__c), accountMap, accountTeamMap, 'P');
                    }else{
                        order.From_Email__c  = getFromEmail(order.Customer_Account_Number__c, accountMap, accountTeamMap, 'C');
                    }
                }else{
                    order.From_Email__c = CUSTOMER_SERVICE;
                }
            }
        } 
    }

    /**
     * Description : method to get Accounts related to EBS Order 
     * param : customerAccountSet holds Customer Account numbers
     */
    private static Map<String,Account> getAccounts(Set<String> customerAccountSet){
        Map<String,Account> accounts = new Map<String,Account>();
        for(Account record : [
            SELECT Id, Routing_Override__c, EBS_Num__c, Customer_Category__c, Logo__c, Customer_Account_Number__c, EBS_Parent_ID__c, 
                Parent_EBS__c, ParentId
            FROM Account 
            WHERE Customer_Account_Number__c IN: customerAccountSet LIMIT 50000
        ]){
            accounts.put(record.Customer_Account_Number__c, record);
        }
        return accounts;
    }


    /**
     * Description : method used to get ACT related to Account
     * param : customerAccountSet holds Customer Account numbers
     */
    private static Map<String, Account_Clarification_Team__c> getAccountTeams(Set<String> customerAccountSet){

        Map<String, Account_Clarification_Team__c> acccountTeams = new Map<String, Account_Clarification_Team__c>();

        for(Account_Clarification_Team__c record : [
            SELECT Id, Name, From_Email__c, Account_Queue__c, Customer_Category__c, EBS_Num__c, Logo__c 
            FROM Account_Clarification_Team__c 
            WHERE EBS_Num__c IN: customerAccountSet LIMIT 50000
        ]){
            acccountTeams.put(record.EBS_Num__c , record);
        }

        return  acccountTeams;
    }

    /**
     * Description : method used to get the Parent Account related to Account on EBS Order
     * param : customerAccountSet holds Customer Account numbers
     */
    private static Map<String,String> getParentAccounts (Set<String> customerAccountSet){
        Map<String,String> accounts = new Map<String,String>();

        for(Account record : [SELECT Id, Customer_Account_Number__c, Parent.EBS_Num__c, ParentId FROM Account WHERE Customer_Account_Number__c IN: customerAccountSet]){
            if(String.isNotBlank(record.Parent.EBS_Num__c)){
                accounts.put(record.Customer_Account_Number__c, record.Parent.EBS_Num__c);
            }
        }

        return accounts;
    } 


    /**
     * Description : method used to get From Email field values related to EBS Order
     * param 1 : customerAccountNumber holds the customer account number
     * param 2 : accounts holds account record with customer number
     * param 3 : acccountTeams holds ACT records with Customer Number
     * param 4 : relation holds the relation type C refers Child & P refers Parent
     */
    private static String getFromEmail(String customerAccountNumber, Map<String,Account> accounts, Map<String, Account_Clarification_Team__c> acccountTeams, String relation){

        String fromEmail = '';
       //System.debug('==== Account ===== '+accounts.get(customerAccountNumber));
       //System.debug('==== ACT ===== '+acccountTeams.get(customerAccountNumber));
        if(accounts.containsKey(customerAccountNumber)){ 

            if(accounts.get(customerAccountNumber).Logo__c == 'Calendar Coop'){ 
                fromEmail = CALENDAR_COOP; 
               //System.debug('==== Calendar Coop ======'+fromEmail);

            }else if(accounts.get(customerAccountNumber).Routing_Override__c == 'Calendar Dedicated'){
                fromEmail = CALENDAR_DEDICATED ; 
               //System.debug('==== Calendar Dedicated ======'+fromEmail);

            } else if(accounts.get(customerAccountNumber).Customer_Category__c == 'Bookstore'){
                fromEmail = ANCHOR_WALLACE; 
               //System.debug('==== Bookstore ======'+fromEmail);

            } else if(accounts.get(customerAccountNumber).Customer_Category__c == 'Church'){
                fromEmail = ANCHOR_WALLACE;
               //System.debug('==== Church ======'+fromEmail);

            } else if(accounts.get(customerAccountNumber).Customer_Category__c == 'Casino'){
                fromEmail = CS_HOTEL;
               //System.debug('==== Casino ======'+fromEmail);

            } else if(accounts.get(customerAccountNumber).Customer_Category__c == 'Hotel'){
                fromEmail = CS_HOTEL;
               //System.debug('==== Hotel ======');
                
            } else if(customerAccountNumber == '33381' && relation == 'P'){
                fromEmail = ACCOUNT_33381; 
               //System.debug('==== 33381 ======');

            } else if(customerAccountNumber == '741016' && relation == 'P'){
                fromEmail = ANCHOR_WALLACE;
               //System.debug('==== 741016 ======');

            } else if(customerAccountNumber == '22452' && relation == 'P'){ // Gary Containers
                fromEmail = GARY_CONTAINERS;
               //System.debug('==== 22452 ======');

            } else{
                fromEmail = acccountTeams.containsKey(customerAccountNumber)? acccountTeams.get(customerAccountNumber).From_Email__c : CUSTOMER_SERVICE;
            } 

        }else{
            fromEmail = acccountTeams.containsKey(customerAccountNumber)? acccountTeams.get(customerAccountNumber).From_Email__c : CUSTOMER_SERVICE; 

        }
        //System.debug('==== FromEmail ======'+fromEmail);
        //System.debug('==== customerAccountNumber ======'+customerAccountNumber); 
        //System.debug('==== relation ======'+relation); 

        return fromEmail;
    }
}