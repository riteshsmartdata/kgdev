/*
* @description       : Test Class for Merge duplicate Batch Class
* @author            : 
* @group             : DAMCO TEAM
* @last modified on  : 06-03-2025
* @last modified by  : Kumar Saurav
*/
@isTest
public class mergeDuplicateContactsTest {
    @testSetup
    public static void testSetup(){
        SwitchTrigger__c st = new SwitchTrigger__c(Deactivate__c=false,Name='EmailLinkTrigger');
        insert st;
        AppInfo__c ce = new AppInfo__c(Name='Sandbox',User__c='webclient',Password__c='eh8q4ya4bvnx5',Endpoint__c='https://testservices.kooziegroup.com/soa-infra/resources/external/EBSCustomerContactAPI/RestService');
        insert ce;
        Contact_Batch_Jobs__c cbj = new Contact_Batch_Jobs__c(Name='Contact Merge Batch',User_Email_Address__c='test@test.com.full',Batch_Size__c=100,Batch_Filter__c='NA');
        insert cbj;
        
        Account newAccount = new Account();
        newAccount.Name = 'Test Damco';
        newAccount.Customer_Account_Number__c = '1234';
        insert newAccount;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Contact newContact1 = new Contact();
        newContact1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact1.LastName = 'LastName';
        newContact1.FirstName = 'FirstName';
        newContact1.Email = 'testingDamco1@test.com.full';
        newContact1.Web_Id__c = 'ashdfgahsfasdf754724';
        newContact1.AccountId = newAccount.Id;
        newContact1.First_Created_Date__c = System.today();
        newContact1.Phone='8956322365';
        newContact1.MobilePhone='8956233265';
        insert newContact1;
        
        Contact newContact2 = new Contact();
        newContact2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact2.LastName = 'LastName';
        newContact2.FirstName = 'FirstName';
        newContact2.Email = 'testingDamco2@test.com.full';
        newContact2.Verified__c = true;
        newContact2.AccountId = newAccount.Id;
        newContact2.Communication_Styles__c = 'Less is more'; 
        newContact2.Mktg_Address_City__c ='Delhi';
        newContact2.MailingCity = 'Delhi';
        newContact2.MailingCountry = 'India';
        newContact2.MailingStreet='Saket';
        newContact2.MailingPostalCode ='110017';
        newContact2.MailingState='Delhi';
        newContact2.Fax='7845121245';
        newContact2.Phone='8956322365';
        newContact2.MobilePhone='8956233265';
        newContact2.Active_Flag__c='Delhi';
        newContact2.Address_Site__c='Delhi';
        newContact2.Address1_ID__c='Delhi';
        newContact2.Address_Status__c='Delhi';
        newContact2.Address2_ID__c='Delhi';
        newContact2.Address4_ID__c='Delhi';
        newContact2.Address3_ID__c='Delhi';
        newContact2.Age_Group__c='18-25';
        insert newContact2;
        
        Contact newContact3 = new Contact();
        newContact3.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact3.LastName = 'LastName';
        newContact3.FirstName = 'FirstName';
        newContact3.Email = 'testingDamco3@test.com.full';
        newContact3.AccountId = newAccount.Id;
        newContact3.Communication_Styles__c = 'Less is more'; 
        newContact3.Source__c = 'Web User';
        newContact3.Suffix= 'Test';
        newContact3.Title = 'Test'; 
        newContact3.FaxID__c = '287563236748';
        newContact3.MailingCity = 'Delhi';
        newContact3.MailingCountry = 'India';
        newContact3.MailingStreet='Saket';
        newContact3.MailingPostalCode ='110017';
        newContact3.MailingState='Delhi';
        newContact3.Fax='7845121245';
        newContact3.Phone='8956322365';
        newContact3.MobilePhone='8956233265';
        newContact3.Active_Flag__c='Delhi';
        newContact3.Address_Site__c='Delhi';
        newContact3.Address1_ID__c='Delhi';
        newContact3.Address_Status__c='Delhi';
        newContact3.Address2_ID__c='Delhi';
        newContact3.Address4_ID__c='Delhi';
        newContact3.Address3_ID__c='Delhi';
        newContact3.Age_Group__c='18-25'; 
        insert newContact3; 
        
        Contact newContact4 = new Contact();
        newContact4.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact4.LastName = 'LastName';
        newContact4.FirstName = 'FirstName';
        newContact4.Email = 'testingDamco4@test.com.full';
        newContact4.Verified__c=true;
        newContact4.AccountId = newAccount.Id;
        newContact4.Communication_Styles__c = 'Less is more'; 
        newContact4.Source__c = 'Web User';
        newContact4.Suffix= 'Test';
        newContact4.Title = 'Test'; 
        newContact4.FaxID__c = '287563236748';
        newContact4.MailingCity = 'Delhi';
        newContact4.MailingCountry = 'India';
        newContact4.MailingStreet='Saket';
        newContact4.MailingPostalCode ='110017';
        newContact4.MailingState='Delhi';
        newContact4.Fax='7845121245';
        newContact4.Phone='8956322365';
        newContact4.MobilePhone='8956233265';
        newContact4.Active_Flag__c='Delhi';
        newContact4.Address_Site__c='Delhi';
        newContact4.Address1_ID__c='Delhi';
        newContact4.Address_Status__c='Delhi';
        newContact4.Address2_ID__c='Delhi';
        newContact4.Address4_ID__c='Delhi';
        newContact4.Address3_ID__c='Delhi';
        newContact4.Age_Group__c='18-25'; 
        insert newContact4;
        
        Contact newContact5 = new Contact();
        newContact5.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact5.LastName = 'LastName1';
        newContact5.FirstName = 'FirstName1';
        newContact5.Email = 'testingDamco5@test.com.full';
        newContact5.AccountId = newAccount.Id;
        newContact5.Communication_Styles__c = 'Less is more'; 
        newContact5.Source__c = 'Web User';
        newContact5.Suffix= 'Test';
        newContact5.Title = 'Test'; 
        newContact5.FaxID__c = '287563236748';
        newContact5.MailingCity = 'Delhi';
        newContact5.MailingCountry = 'India';
        newContact5.MailingStreet='Saket';
        newContact5.MailingPostalCode ='110017';
        newContact5.MailingState='Delhi';
        newContact5.Fax='7845121245';
        newContact5.Phone='8956322365';
        newContact5.MobilePhone='8956233265';
        newContact5.Active_Flag__c='Delhi';
        newContact5.Address_Site__c='Delhi';
        newContact5.Address1_ID__c='Delhi';
        newContact5.Address_Status__c='Delhi';
        newContact5.Address2_ID__c='Delhi';
        newContact5.Address4_ID__c='Delhi';
        newContact5.Address3_ID__c='Delhi';
        newContact5.Age_Group__c='18-25'; 
        insert newContact5;
        
        Contact newContact6 = new Contact();
        newContact6.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        newContact6.LastName = 'LastName1';
        newContact6.FirstName = 'FirstName1';
        newContact6.Email = 'testingDamco6@test.com.full';
        newContact6.AccountId = newAccount.Id;
        newContact6.Communication_Styles__c = 'Less is more'; 
        newContact6.Source__c = 'Web User';
        newContact6.Suffix= 'Test';
        newContact6.Title = 'Test'; 
        newContact6.FaxID__c = '287563236748';
        newContact6.MailingCity = 'Delhi';
        newContact6.MailingCountry = 'India';
        newContact6.MailingStreet='Saket';
        newContact6.MailingPostalCode ='110017';
        newContact6.MailingState='Delhi';
        newContact6.Fax='7845121245';
        newContact6.Phone='8956322365';
        newContact6.MobilePhone='8956233265';
        newContact6.Active_Flag__c='Delhi';
        newContact6.Address_Site__c='Delhi';
        newContact6.Address1_ID__c='Delhi';
        newContact6.Address_Status__c='Delhi';
        newContact6.Address2_ID__c='Delhi';
        newContact6.Address4_ID__c='Delhi';
        newContact6.Address3_ID__c='Delhi';
        newContact6.Age_Group__c='18-25'; 
        insert newContact6;        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BatchExecutionHelper.getLastProcessedDate();
    }
    @isTest
    public static void testScheduler(){
        Test.startTest();
        system.schedule('Test Merge Duplicate', '0 0 * * * ?', new mergeDuplicateContacts());
        Test.stopTest();
    }    
    @isTest
    static void testFullPrioritySequenceMerge() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acct = new Account(Name='Test Account');
        insert acct;
        
        Id crmRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        
        // Create 4 distinct contacts initially
        Contact c1 = new Contact(LastName = 'InactiveOld', Email = 'merge1@example.com', RecordTypeId = crmRTId, Contact_Status__c = 'Inactive', AccountId = acct.Id);
        Contact c2 = new Contact(LastName = 'Verified', Email = 'merge2@example.com', RecordTypeId = crmRTId, Verified__c = true, AccountId = acct.Id);
        Contact c3 = new Contact(LastName = 'ActiveOnly', Email = 'merge3@example.com', RecordTypeId = crmRTId, Contact_Status__c = 'Active', AccountId = acct.Id);
        Contact c4 = new Contact(LastName = 'HasWebId', Email = 'merge4@example.com', RecordTypeId = crmRTId, Web_Id__c = 'WEB-123', AccountId = acct.Id);
        
        insert new List<Contact>{c1, c2, c3, c4};
            
            // Update all to same email to create duplicates
            String dupEmail = 'prioritytest@example.com';
        for (Contact c : new List<Contact>{c2, c3, c4}) {
            c.Email = dupEmail;
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        for (Contact c : new List<Contact>{c2, c3, c4}) c.setOptions(dml);
        update new List<Contact>{c2, c3, c4};
            
            Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts(), 1);
        Test.stopTest();
        
        List<Contact> postMerge = [SELECT Id, Web_Id__c FROM Contact WHERE Email = :dupEmail];
        System.assertEquals(1, postMerge.size(), 'Only one master contact should remain.');
        System.assertEquals('WEB-123', postMerge[0].Web_Id__c, 'Master contact should have WebId.');
    }
    @isTest
    public static void duplicateContactTest1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        // Step 1: Prepare duplicates
        List<Contact> contactList = [
            SELECT Id, Email 
            FROM Contact 
            WHERE Email = 'testingDamco2@test.com.full' 
            OR Email = 'testingDamco3@test.com.full'
        ];
        List<Contact> updateContactList = new List<Contact>();
        for (Contact con : contactList) {
            con.Email = 'testingDamco1@test.com.full';
            updateContactList.add(con);
        }
        
        // Allow duplicates to be updated
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        for (Contact con : updateContactList) {
            con.setOptions(dml);
        }
        Database.update(updateContactList, dml);
        // Step 2: Run merge batch
        Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts());
        Test.stopTest();
        // Step 3: Assert only one contact remains
        List<Contact> contacts = [SELECT Id, Email 
                                  FROM Contact 
                                  WHERE Email = 'testingDamco1@test.com.full'
                                 ]; System.debug('Contacts remaining: ' + contacts.size());
        // System.assertEquals(1, contacts.size(), 'Only one contact should remain after merge.');
    }
    @isTest
    public static void duplicateContactTest2(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Contact> contactList = [Select Id,Email from Contact Where Email = 'testingDamco4@test.com.full' OR Email = 'testingDamco5@test.com.full'];
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con:contactList){
            con.email = 'testingDamco2@test.com.full';
            updateContactList.add(con);
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(updateContactList, dml);
        Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts());
        Test.stopTest();
    }
    @isTest
    public static void duplicateContactTest3(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Contact> contactList = [Select Id,Email from Contact Where Email = 'testingDamco4@test.com.full' OR Email = 'testingDamco5@test.com.full' OR Email = 'testingDamco6@test.com.full'];
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con:contactList){
            con.email = 'testingDamco3@test.com.full';
            updateContactList.add(con);
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(updateContactList, dml);
        Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts());
        Test.stopTest();
    }
    @isTest
    public static void  duplicateContactTest4(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Account> account = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contactWebId = [SELECT Id,Web_Id__c,Email FROM Contact WHERE Web_Id__c!=null LIMIT 1];
        List<Contact> contactList = [Select Id,Email,Web_Id__c from Contact Where Email = 'testingDamco2@test.com.full'];
        List<Contact> updateContactList = new List<Contact>();
        for(Contact con:contactList){
            con.email = 'testingDamco1@test.com.full';
            con.Web_Id__c='27547234872';
            updateContactList.add(con);
        }
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.update(updateContactList, dml);
        Test.startTest();
        database.executeBatch(new mergeDuplicateContacts());
        Test.stopTest();
    }
    @isTest
    static void testMoreThanThreeDuplicates() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id crmRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Account acc = new Account(Name='Test Acc 3+');
        insert acc;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 1; i <= 4; i++) {
            contacts.add(new Contact(
                FirstName='First',
                LastName='Last',
                Email='4plus@test.com',
                RecordTypeId=crmRTId,
                AccountId=acc.Id
            ));
        }
        insert contacts;
        Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts(), 1);
        Test.stopTest();
    }
    @isTest
    static void testDuplicateWithWebIdEmailAlert() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Id crmRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Account acc = new Account(Name='Alert Acc');
        insert acc;
        Contact c1 = new Contact(LastName='WebDup1', Email='alertdup@test.com', RecordTypeId=crmRTId, AccountId=acc.Id, Web_Id__c='123');
        Contact c2 = new Contact(LastName='WebDup2', Email='alertdup@test.com', RecordTypeId=crmRTId, AccountId=acc.Id, Web_Id__c='456');
        insert new List<Contact>{c1, c2};
            Test.startTest();
        Database.executeBatch(new mergeDuplicateContacts(), 1);
        Test.stopTest();
        
        // There's no assert here, but this ensures the email logic is reached
    }
}