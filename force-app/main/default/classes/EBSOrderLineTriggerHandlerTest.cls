@isTest
public class EBSOrderLineTriggerHandlerTest {
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @testSetup
    static void testDataForDelayedOrderCaseCreation()
    {
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = accRecTypId;
        acc.Customer_Account_Number__c = '12345678';
        acc.Customer_PO_Number__c = '123456';
        insert acc;
        
        Contact cont = new Contact();
        cont.firstname = 'First';
        cont.lastname = 'Test Name';  
        cont.AccountId = acc.Id;
        cont.Email = 'firsttestname@testing.com';
        cont.Phone = '407-508-1313';
        cont.RecordTypeId = conRecTypId;
        cont.Acc_PO_Contact__c = True;
        insert cont;
        
        //Without Case
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact__c = cont.Id;
        eo.PO_Contact_Email__c = 'contact@ebsorder.com'; 
        eo.Customer_Account_Number__c = '123456'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L';
        eo.EBS_Order_Number__c = '279033736';
        insert eo;
        
        List<EBS_Order_Line__c> eolInsertList = new List<EBS_Order_Line__c>();  
        EBS_Order_Line__c eol = new EBS_Order_Line__c();
        eol.Order__c = eo.Id;
        eol.Order_Number__c = '279033736';
        eol.TOV_Line_Status__c = 'Awaiting Shipping';
        eol.Scheduled_Ship_Date__c = date.today()+5;
        eol.Promise_Date__c = date.today()+10;
        eolInsertList.add(eol);
        insert eolInsertList;
        
        //With Case which is closed
        EBS_Order__c eo1 = new EBS_Order__c();
        eo1.Account_Name__c = acc.Id;
        eo1.Customer_Account_Number__c = '1234567'; 
        eo1.Order_Type__c = 'Standard US';
        eo1.Customer_PO__c = 'PK11001436P';
        eo1.EBS_Order_Number__c = '279033737';
        insert eo1;
        
        
        List<EBS_Order_Line__c> eolInsertList1 = new List<EBS_Order_Line__c>();  
        EBS_Order_Line__c eol1 = new EBS_Order_Line__c();
        eol1.Order__c = eo1.Id;
        eol1.Order_Number__c = '279033737';
        eol1.TOV_Line_Status__c = 'In Storage';
        eol1.Scheduled_Ship_Date__c = date.today()+3;
        eol1.Promise_Date__c = date.today()+7;
        eolInsertList1.add(eol1);
        insert eolInsertList1;
        
        Case css = new Case();
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Delayed Order').getRecordTypeId();
        css.EBS_Account_Number__c ='828312';
        css.AccountId = eol1.Order__r.Account_Name__c;
        css.EBS_Order_Line__c = eolInsertList1[0].Id;
        css.EBS_Order__c = eo1.Id;
        css.Status = 'Closed';
        css.Origin = 'ASI Rating';
        insert css;
        
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
    }
    
    @isTest
    static void DelayedOrderCaseCreationTestForNoCase()
    {
        List<EBS_Order_Line__c> eolInsertedList = [SELECT Id, TOV_Line_Status__c, Order__c, Scheduled_Ship_Date__c, Order__r.Order_Type__c,
                                                   Order_Type__c, Promise_Date__c FROM EBS_Order_Line__c 
                                                   WHERE TOV_Line_Status__c = 'Awaiting Shipping' LIMIT 1];
        List<EBS_Order_Line__c> eolUpdateList = new List<EBS_Order_Line__c>();
        eolInsertedList[0].Scheduled_Ship_Date__c = date.today()+15;
        eolUpdateList.add(eolInsertedList[0]);
        
        Test.startTest();
        update eolUpdateList;
        Map<Id,EBS_Order_Line__c> oldEOLMap = new Map<Id,EBS_Order_Line__c>();
        for (EBS_Order_Line__c el : eolInsertedList)
        {
            oldEOLMap.put(el.Id, el);
        }
        EBSOrderLineTriggerHandler.DelayedOrderCaseCreation(eolUpdateList, oldEOLMap);        
        Test.stopTest();
    }
    
    @isTest
    static void DelayedOrderCaseCreationTestForClosedCase()
    {
        List<EBS_Order_Line__c> eolInsertedList = [SELECT Id, TOV_Line_Status__c, Order__c, Scheduled_Ship_Date__c, Order__r.Order_Type__c,
                                                   Order_Type__c, Promise_Date__c FROM EBS_Order_Line__c 
                                                   WHERE TOV_Line_Status__c = 'In Storage' LIMIT 1];
        List<EBS_Order_Line__c> eolUpdateList = new List<EBS_Order_Line__c>();
        eolInsertedList[0].Scheduled_Ship_Date__c = date.today()+11;
        eolUpdateList.add(eolInsertedList[0]);
        
        Test.startTest();
        update eolUpdateList;
        Map<Id,EBS_Order_Line__c> oldEOLMap = new Map<Id,EBS_Order_Line__c>();
        for (EBS_Order_Line__c el : eolInsertedList)
        {
            oldEOLMap.put(el.Id, el);
        }
        EBSOrderLineTriggerHandler.DelayedOrderCaseCreation(eolUpdateList, oldEOLMap);        
        Test.stopTest();
    }
    
    @isTest
    static void DelayedOrderCaseCreationTestForOpenCase()
    {
        List<EBS_Order_Line__c> eolInsertedList = [SELECT Id, TOV_Line_Status__c, Order__c, Scheduled_Ship_Date__c, Order__r.Order_Type__c,
                                                   Order_Type__c, Promise_Date__c FROM EBS_Order_Line__c 
                                                   WHERE TOV_Line_Status__c = 'In Storage' LIMIT 1];
        List<Case> newCase = new List<Case>();
        Case cs = [Select Id, Status From Case Where EBS_Order_Line__c =: eolInsertedList[0].Id LIMIT 1];
        cs.Status = 'New';
        newCase.add(cs);
        List<EBS_Order_Line__c> eolUpdateList = new List<EBS_Order_Line__c>();
        eolInsertedList[0].Scheduled_Ship_Date__c = date.today()+9;
        eolUpdateList.add(eolInsertedList[0]);
        update newCase;
        
        Test.startTest();
        update eolUpdateList;
        Map<Id,EBS_Order_Line__c> oldEOLMap = new Map<Id,EBS_Order_Line__c>();
        for (EBS_Order_Line__c el : eolInsertedList)
        {
            oldEOLMap.put(el.Id, el);
        }
        EBSOrderLineTriggerHandler.DelayedOrderCaseCreation(eolUpdateList, oldEOLMap);        
        Test.stopTest();
    }
   
}