/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Ritesh Kumar
**/

@isTest
public class SendContactCallOutTest {
    
     @testSetUp
    public static void dataSetUp(){
        AppInfo__c ce = new AppInfo__c();
        ce.Name = 'Sandbox';
        ce.User__c = 'webclient';
        ce.Password__c = 'eh8q4ya4bvnx5';
        ce.Endpoint__c = 'https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService';
        insert ce;
    }
    
    @isTest
    public static void GenerateContactJSON(){
        
        Contact con = new Contact();
        con.Phone = '9999999999';  
        con.Responsibility_Type__c = 'CLARIFICATION'; 
        con.OtherPhone = '';
        con.Other_Email__c = '';
        con.EmailID__c = '';
        con.Date_Verified__c = System.Today();
        con.FaxID__c = ''; 
        con.MiddleName = 'J';
        con.MailingPostalCode = '250002';
        con.MailingCity = 'Texas';
        con.MailingCountry = 'US';
        con.MailingState = 'Nevada';
        con.MailingStreet = 'JASON Street';
        con.Other_Email_ID__c = '';
        con.LastName = 'Graham';
        con.Fax = '';
        con.PrimaryOtherPhoneFlag__c = True;
        con.Address_Type__c = ''; 
        con.Email = 'test@testers.com'; 
        con.Contact_Type__c = 'Permanent';  
        con.MobilePhone = '99999999999'; 
        con.Address_Status__c = '99999999999'; 
        con.Title = 'Mr'; 
        con.OtherPhoneID__c = '';
        con.PhoneID__c = ''; 
        con.FirstName = 'Buller'; 
        con.Suffix = 'Mr'; 
        con.Source__c = '';
        con.Contact_Status__c = 'Active'; 
        con.Salutation = 'Mr';
        insert con;
        
        Contact con1 = new Contact();
        con1.Phone = '9999999923';  
        con1.Responsibility_Type__c = 'SALES_SERVICE'; 
        con1.OtherPhone = '7845122145';
        con1.Other_Email__c = 'test@test.com';
        con1.EmailID__c = '1245'; 
        con1.FaxID__c = '125445'; 
        con1.MiddleName = 'SD';
        con1.MailingPostalCode = '250s02';
        con1.MailingCity = 'TexasA';
        con1.MailingCountry = 'IND';
        con1.MailingState = 'NevadaA';
        con1.MailingStreet = 'JASON StreetS';
        con1.Other_Email_ID__c = '895623';
        con1.LastName = 'GrahamA';
        con1.Fax = '895623235698';
        con1.PrimaryOtherPhoneFlag__c = True;
        con1.Address_Type__c = ''; 
        con1.Email = 'tests@testers.com'; 
        con1.Contact_Type__c = 'Permanents';  
        con1.MobilePhone = '999999555999'; 
        con1.Address_Status__c = '995698999999'; 
        con1.Title = 'Mr'; 
        con1.OtherPhoneID__c = '89562323';
        con1.PhoneID__c = ''; 
        con1.FirstName = 'Bullers'; 
        con1.Suffix = 'Mr'; 
        con1.Source__c = 'web';
        con1.Contact_Status__c = 'Active'; 
        con1.Salutation = 'Mr';
        con1.PromoStandards_Contact__c = true;
        con1.PrimaryOtherEmailFlag__c = true;
        con1.Top_Producer__c = true; 
        
        Map<Id, Contact> oldContactMap = new Map<Id, Contact>();
        oldContactMap.put(con.Id, con1);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        SendContactCallOut.sendContactInformation(new List<Contact>{con},oldContactMap ,'INSERT'); 
        SendContactCallOut.sendContactInformation(new List<Contact>{con},oldContactMap ,'UPDATE');         
        Test.stopTest();
        
    } 
}