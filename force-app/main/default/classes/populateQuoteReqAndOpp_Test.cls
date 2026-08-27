@isTest
private class populateQuoteReqAndOpp_Test {
    
    @isTest
    public static void testMethodForOppAndQuoteCreation(){
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Map<String,EBS_Order__c> quoteNumOrderMap = new Map<String,EBS_Order__c>();
        
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
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.CloseDate = System.today();
        //opp.Quote_Number__c = 'OQR-034477';
        opp.Contact__c = cont.Id;
        insert opp;    
        
        Opportunity oppquotenumber = [SELECT Quote_Number__c FROM Opportunity WHERE Quote_Number__c LIKE '%QR%' LIMIT 1];
        //Without Case
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc.Id;
        eo.PO_Contact__c = cont.Id;
        eo.PO_Contact_Email__c = 'contact1@ebsorder.com'; 
        eo.Customer_Account_Number__c = '1234567'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L1';
        eo.Quote_Number__c = 'QR-144031';
        eo.Quote_Number__c = oppquotenumber.Quote_Number__c;
        eo.EBS_Order_Number__c = '27903373661';
        insert eo;
        
        eo.Opportunity__c = opp.Id;
        update eo;
        Quote_Request__c qr = new Quote_Request__c();
        qr.Contact__c = cont.Id;
        qr.Account__c = acc.Id;
        qr.Opportunity__c = opp.Id;
        insert qr;
        List<EBS_Order__c> eoList = new List<EBS_Order__c>(); 
        eoList.add(eo);
        quoteNumOrderMap.put('QR-14403',eo);
        
        Map<String, List<EBS_Order__c>> orderMap = new Map<String, List<EBS_Order__c>>();
        orderMap.put('QR-14403', new List<EBS_Order__c>{eo});
        
        // Test.startTest();
        populateQuoteReqAndOpp.updateOrderWithQuoteAndOpp(orderMap);
    }
    
    @isTest
    public static void testupdateEBSOrderFromQuote() {
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Map<String,EBS_Order__c> quoteNumOrderMap = new Map<String,EBS_Order__c>();
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.RecordTypeId = accRecTypId;
        acc2.Customer_Account_Number__c = '123456789';
        acc2.Customer_PO_Number__c = '1234567';
        insert acc2;
        
        Contact cont = new Contact();
        cont.firstname = 'First';
        cont.lastname = 'Test Name';  
        cont.AccountId = acc2.Id;
        cont.Email = 'firsttestname@testing.com';
        cont.Phone = '407-508-1313';
        cont.RecordTypeId = conRecTypId;
        cont.Acc_PO_Contact__c = True;
        insert cont;
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.CloseDate = System.today(); 
        opp.Contact__c = cont.Id;
        insert opp;        
        //Without Case
        Quote_Request__c qr = new Quote_Request__c();
        qr.Contact__c = cont.Id;
        qr.Account__c = acc2.Id;
        qr.Opportunity__c = opp.Id;
        insert qr;
        Quote_Request__c quotenumber = [SELECT Quote_Number__c FROM Quote_Request__c WHERE Quote_Number__c LIKE '%Q%' LIMIT 1];
        system.debug('quotenumber---> '+quotenumber);
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc2.Id;
        eo.PO_Contact__c = cont.Id;
        eo.PO_Contact_Email__c = 'contact@ebsorder.com'; 
        eo.Customer_Account_Number__c = '123456'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L';
        eo.Quote_Number__c = quotenumber.Quote_Number__c;
        eo.EBS_Order_Number__c = '2790337366';
        insert eo;
        
        Test.startTest();
        List<EBS_Order__c> eoList = new List<EBS_Order__c>(); 
        eoList.add(eo);
        quoteNumOrderMap.put(quotenumber.Quote_Number__c,eo);
                
        
        Map<String, List<EBS_Order__c>> orderMap = new Map<String, List<EBS_Order__c>>();
        orderMap.put(quotenumber.Quote_Number__c, new List<EBS_Order__c>{eo});
        
        populateQuoteReqAndOpp.updateOrderWithQuoteAndOpp(orderMap);
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.stopTest();
        
    }
    
    @isTest
    public static void testupdateEBSOrderFromQuote2() {
        Id accRecTypId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customers').getRecordTypeId();
        Id conRecTypId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Map<String,EBS_Order__c> quoteNumOrderMap = new Map<String,EBS_Order__c>();
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        acc2.RecordTypeId = accRecTypId;
        acc2.Customer_Account_Number__c = '123456789';
        acc2.Customer_PO_Number__c = '1234567';
        insert acc2;
        
        Contact cont = new Contact();
        cont.firstname = 'First';
        cont.lastname = 'Test Name';  
        cont.AccountId = acc2.Id;
        cont.Email = 'firsttestname@testing.com';
        cont.Phone = '407-508-1313';
        cont.RecordTypeId = conRecTypId;
        cont.Acc_PO_Contact__c = True;
        insert cont;
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Proposal';
        opp.CloseDate = System.today(); 
        opp.Contact__c = cont.Id;
        insert opp;        
        //Without Case
        Quote_Request__c qr = new Quote_Request__c();
        qr.Contact__c = cont.Id;
        qr.Account__c = acc2.Id;
        qr.Opportunity__c = opp.Id;
        insert qr;
        Quote_Request__c quotenumber = [SELECT Quote_Number__c, Name  FROM Quote_Request__c WHERE Quote_Number__c LIKE '%Q%' LIMIT 1];
        EBS_Order__c eo = new EBS_Order__c();
        eo.Account_Name__c = acc2.Id;
        eo.PO_Contact__c = cont.Id;
        eo.PO_Contact_Email__c = 'contact@ebsorder.com'; 
        eo.Customer_Account_Number__c = '123456'; 
        eo.Order_Type__c = 'Standard';
        eo.Customer_PO__c = 'PK11001436L';
        eo.Quote_Number__c = quotenumber.Name;
        eo.EBS_Order_Number__c = '2790337366';
        insert eo;
        
        Test.startTest();
        List<EBS_Order__c> eoList = new List<EBS_Order__c>(); 
        eoList.add(eo);
        quoteNumOrderMap.put(quotenumber.Name,eo);
        
        
        Map<String, List<EBS_Order__c>> orderMap = new Map<String, List<EBS_Order__c>>();
        orderMap.put('OQR-12345', new List<EBS_Order__c>{eo});
        
        populateQuoteReqAndOpp.updateOrderWithQuoteAndOpp(orderMap);
        Test.setMock(HttpCalloutMock.class, new MockHTTPResponseGenerator());
        Test.stopTest();
        
    }
}