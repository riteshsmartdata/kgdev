/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 01-20-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public class EmailOnEBSOrderHandlerTest {
	
    @isTest
    public static void accountCalendarCoop() {
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
                
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
	@isTest
    public static void accountCalendarDedicated() {
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
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
        
    }
    
    @isTest
    public static void accountChurch() {
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
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountCasino() {
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
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountHotel() {
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
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void account33381() {
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
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }

    @isTest
    public static void accountCalendarCoop1() {
        

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Routing_Override__c = 'Calendar Dedicated';
        acc1.Logo__c ='Calendar Coop'; 
        Insert acc1;
        
       	EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }

	@isTest
    public static void accountCalendarDedicated1() {
         

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Routing_Override__c = 'Calendar Dedicated'; 
        Insert acc1;
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountBookstore1() {
        

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Bookstore'; 
        Insert acc1;
        
       	EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountChurch1() {
      

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Church'; 
        Insert acc1;
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountCasino1() {
         

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Casino'; 
        Insert acc1;
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountHotel1() {
        

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '828312'; 
        acc1.Customer_Category__c= 'Hotel'; 
        Insert acc1;
        
       	EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void account33381B() {
        

        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Customer_Account_Number__c = '33381';
        acc1.EBS_Parent_ID__c = '828312'; 
        Insert acc1;
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
    public static void accountCustomerAccNotNull() {
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
        
       	EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc1.Customer_Account_Number__c;
        insert ebs;
    }
    
    @isTest
       public static void accountCustomerCategoryEqualsHotel() {
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
           
           
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        insert ebs;
    }

       @isTest
       public static void accountLogoEqualsCalendarCoop() {
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
           
           
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        insert ebs;
    }

    @isTest
    public static void accountCustomerAccountNumberEquals33381() {
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
        
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        insert ebs;
    }

    @isTest
    public static void accountCustomerCategoryEqualsBookstore() {
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
        
        
        EBS_Order__c ebs = new EBS_Order__c();
        ebs.Customer_Account_Number__c = acc.Customer_Account_Number__c;
        insert ebs;
    }
}