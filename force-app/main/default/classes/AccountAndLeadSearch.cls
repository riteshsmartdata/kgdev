/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 05-08-2024
 * @last modified by  : Kumar Saurav
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-07-2023   Kumar Saurav   Initial Version
**/
public without sharing class AccountAndLeadSearch {
    
    @AuraEnabled
    public static List<Account> searchAccountAndLeads(String leadId){
        Account[] accountList;
        Lead [] leadRecords;
        if(String.isNotBlank(leadId)){
            leadRecords = [SELECT Id , Company, Shipping_Street__c,Shipping_City__c,Shipping_State__c,Industry_Association_Number__c,Shipping_Zip_Postal_Code__c, Address FROM Lead WHERE Id =: leadId];
        }
        if(leadRecords.size() > 0 ){
            if (String.isNotBlank(leadId)) {
                leadRecords = [
                    SELECT Id, Company, Shipping_Street__c, Shipping_City__c, Shipping_State__c, Industry_Association_Number__c, Shipping_Zip_Postal_Code__c, Address
                    FROM Lead
                    WHERE Id = :leadId
                ];
            }
            if (leadRecords.size() > 0) {
                Lead lead = leadRecords[0];
                String query = 'SELECT Id, Name, Customer_Account_Number__c, Status__c, ASI_Number__c, Parent.Name, billingStreet, billingCity, billingState, billingPostalCode, billingCountry FROM Account WHERE';
                List<String> conditions = new List<String>();
                Map<String, Object> params = new Map<String, Object>();
                if (String.isNotBlank(lead.Company)) {
                    conditions.add('Name = :company');
                    params.put('company', lead.Company);
                }
                if (String.isNotBlank(lead.Industry_Association_Number__c)) {
                    conditions.add('ASI_Number__c = :industryAssociationNumber');
                    params.put('industryAssociationNumber', lead.Industry_Association_Number__c);
                }
                if (String.isNotBlank(lead.Shipping_Street__c) && String.isNotBlank(lead.Shipping_Zip_Postal_Code__c) && String.isNotBlank(lead.Shipping_City__c)) {
                    conditions.add('(billingStreet != NULL AND billingStreet = :shippingStreet AND billingPostalCode != NULL AND billingPostalCode = :shippingPostalCode AND billingCity != NULL AND billingCity = :shippingCity)');
                    params.put('shippingStreet', lead.Shipping_Street__c);
                    params.put('shippingPostalCode', lead.Shipping_Zip_Postal_Code__c);
                    params.put('shippingCity', lead.Shipping_City__c);
                }
                if (!conditions.isEmpty()) {
                    query += ' ' + String.join(conditions, ' OR ');
                    query+= ' ' + 'LIMIT 50000';
                    accountList = Database.queryWithBinds(query, params,AccessLevel.SYSTEM_MODE);
                }
            }          
        }
        return accountList;
    }
}