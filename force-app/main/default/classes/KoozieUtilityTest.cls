/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-13-2023   Ritesh Kumar   Initial Version
**/

@IsTest
public without sharing class KoozieUtilityTest {
    @IsTest
    static void isAsyncApexRunning_unitTest() {
        Test.startTest();
            Boolean job = KoozieUtility.isAsyncApexRunning('BatchClass', 'ApexBatch'); 
        Test.stopTest();
        System.assertEquals(FALSE, job);
    }
    @IsTest
    static void recordTypeId_unitTest() {
        Test.startTest();
            String recordtypeId = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact'); 
        Test.stopTest();
        System.assertEquals(TRUE, String.isNotBlank(recordtypeId));
    }
     @IsTest
    static void getObjectNameById_unitTest() {
        Lead leadRecord = new Lead();
        leadRecord.LastName = 'Test Lead'; 
        leadRecord.Company = 'Koozie';
        Insert leadRecord;
        Test.startTest();
        String ObjectName = KoozieUtility.getObjectNameById(leadRecord.Id); 
        System.assertEquals('Lead', ObjectName);
        Test.stopTest();
    }
    @isTest
    static void isSandbox_unitTest(){
        Test.startTest();
            Boolean isSandbox = KoozieUtility.isSandbox();
        Test.stopTest();
    } 
    @isTest
    static void getAllfieldValuesSobject_unitTest(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = TestData.createAccount(true);
        List<Account> lstAccount =  KoozieUtility.getAllFieldValues('Account', acc.Id);
    }
}