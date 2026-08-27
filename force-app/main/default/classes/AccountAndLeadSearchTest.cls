/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 09-25-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   09-25-2023   Ritesh Kumar   Initial Version
**/
@isTest
public class AccountAndLeadSearchTest {
    @isTest
    public static void leadAccountInsert(){
        List<Lead> leadList = new List<Lead>();
        Lead le = new Lead();
        le.LastName = 'test';
        le.Company = 'testCompany';
        le.Status = 'New';
        le.Shipping_City__c = 'Bokaro';
        le.Shipping_Street__c = 'HMT Colony';
        le.Shipping_Zip_Postal_Code__c = '829107';
        le.Industry_Association_Number__c = '123123';
        insert le;
        leadList.add(le);

        Account acc = new Account();
        acc.Name = 'testCompany';
        acc.Customer_Account_Number__c = 'test';
        acc.Parent_Account_Name__c = 'test';
        acc.BillingStreet = 'HMT Colony';
        acc.BillingPostalCode = '829107';
        acc.BillingCity = 'Bokaro';
        insert acc;

        Account acc1 = new Account();
        acc1.Name = 'testCompany123';
        acc1.Customer_Account_Number__c = 'test12';
        acc1.Parent_Account_Name__c = 'test';
        acc1.BillingStreet = 'HMT Colony';
        acc1.BillingPostalCode = '829107';
        acc1.BillingCity = 'Bokaro';
        acc1.ASI_Number__c = '123123';
        insert acc1;

        Account acc2  = new Account();
        acc2.Name = 'HelloTest';
        acc2.Customer_Account_Number__c = 'test1212312';
        acc2.Parent_Account_Name__c = 'test';
        acc2.BillingStreet = 'HMT Colony';
        acc2.BillingPostalCode = '829107543653';
        acc2.BillingCity = 'Bokaro';
        acc2.ASI_Number__c = '8708060525';
        insert acc2;

        List<Account> lstAccount = AccountAndLeadSearch.searchAccountAndLeads(le.id);
        system.assert(lstAccount.size()==2,'All Duplcaites were not found!');
        system.assert(lstAccount.size()!=3,'Incorrect duplicate were found!');
    }
}