/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-24-2022
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest 
public class caseTriggerHandlerTest {
    
    @isTest
    public static void accountCalendarCoop() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Routing_Override__c = 'Calendar Dedicated';
        acc.Logo__c ='Calendar Coop';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.Routing_Override__c = 'Calendar Dedicated';
        acc1.Logo__c ='Calendar Coop';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCalendarDedicated() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Routing_Override__c = 'Calendar Dedicated';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.Routing_Override__c = 'Calendar Dedicated';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountBookstore() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c= 'Bookstore';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.Customer_Category__c= 'Bookstore';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountChurch() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c= 'Church';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.Customer_Category__c= 'Church';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCasino() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c= 'Casino';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.Customer_Category__c= 'Casino';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountHotel() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c= 'Hotel';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void account33381() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '33381';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '12345';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCalendarCoop1() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Routing_Override__c = 'Calendar Dedicated';
        acc1.Logo__c ='Calendar Coop'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCalendarDedicated1() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Routing_Override__c = 'Calendar Dedicated'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountBookstore1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Bookstore'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountChurch1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Church'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCasino1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Casino'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountHotel1() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Hotel'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void account33381B() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '33381';
        acc1.EBS_Parent_ID__c = '828312'; 
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCustomerAccNotNull() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '2345';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312';
        acc1.EBS_Parent_ID__c = '2345';
        acc1.ParentId = acc.Id;
        Insert acc1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCustomerCategoryEqualsHotel() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c = 'Hotel';
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Hotel';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountLogoEqualsCalendarCoop() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Logo__c = 'Calendar Coop';
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc; 
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 804 Facilis Brand Addition';
        act.From_Email__c = 'csinfo@calndercs.com';
        act.EBS_Num__c = '12345';
        act.Logo__c = 'Calendar Coop';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email'; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCustomerAccountNumberEquals33381() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '33381';
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'proformabcsteam@kooziegroup.com';
        act.EBS_Num__c = '33381';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email'; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c = '33381';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCustomerCategoryEqualsBookstore() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c = 'Bookstore';
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.EBS_Num__c = '12345';
        act.From_Email__c = 'anchorwallace@anchorwallace.com';
        act.Customer_Category__c = 'Bookstore';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email' */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c = '12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountRoutingOverrideEqualsCalendarDedicated() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Routing_Override__c = 'Calendar Dedicated';
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.EBS_Num__c = '12345';
        act.From_Email__c = 'coopspecialtyteam@kooziegroup.com';
        act.Account_Queue__c = 'Calendar Dedicated';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email'; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void accountCustomerAccountNumberEqualsActEbsNumberAndCaseEbsAccountNumber() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'test@test.com';
        act.EBS_Num__c = '12345';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email'; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    @isTest
    public static void caseEbsAccountNumberDoesNotExistsInActAndAccount() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Customer_Account_Number__c = ' ';
        insert acc;
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'HG Custom';
        act.From_Email__c = 'customerservice@kooziegroup.com';
        act.EBS_Num__c = '';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
css.Customer_To_Email__c = act.From_Email__c;
css.Case_Reason_Type__c = 'Email'; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c = '12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    @isTest
    public static void accountCustomerCategoryEqualsChurch() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c = 'Church';
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Church';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    @isTest
    public static void accountCustomerCategoryEqualsCasino() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345';
        acc.Customer_Category__c = 'Casino';
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        insert acc;
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerCategoryEqualsCasino() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Customer_Category__c = 'Casino';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerCategoryEqualsHotel() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Customer_Category__c = 'Hotel';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerCategoryEqualsBookstore() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Customer_Category__c = 'Bookstore';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerCategoryEqualsChurch() {
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Customer_Category__c = 'Church';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentLogoEqualsCalendarCoop() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Logo__c = 'Calendar Coop';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentRoutingOverrideEqualsCalendarDedicated() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        parentRecord.Routing_Override__c = 'Calendar Dedicated';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Casino';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'Email';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerAccountNumberEquals33381() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '33381';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '33381';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    
    @isTest
    public static void parentAccountCustomerAccountNumberEqualsActEbsNumber() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '54321';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
    @isTest
    public static void parentAccountCustomerAccountNumberEqualsActEbsNumberWhenRecordTypeIsDelayedOrder() {
        
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Account parentRecord = new Account();
        parentRecord.Name = 'test';
        parentRecord.Customer_Account_Number__c = '54321';
        insert parentRecord;
        
        Account childRecord = new Account();
        childRecord.Name = 'test';
        childRecord.Customer_Account_Number__c = '12345';
        childRecord.EBS_Parent_ID__c = '54321';
        childRecord.ParentId = parentRecord.Id;
        insert childRecord;
        
        
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        //acc.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '54321';
        insert act;
        
        
        Case css = new Case();
        /* css.AccountId = acc.Id;
css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
css.Case_Reason_Type__c = 'Email';
css.Customer_To_Email__c = act.From_Email__c; */
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Delayed Order').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css;
    }
}