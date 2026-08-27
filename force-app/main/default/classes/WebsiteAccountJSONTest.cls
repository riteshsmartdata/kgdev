/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 10-08-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/

@IsTest
public with sharing class WebsiteAccountJSONTest {

	    private class RestMock implements HttpCalloutMock {

			public HTTPResponse respond(HTTPRequest req) {
				HTTPResponse res = new HTTPResponse();
				res.setHeader('Content-Type', 'text/json'); 
				res.setBody('{"EventResponse":{"EventBusinessID":"123450","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"003XXXXXXXXXXXXXXX","WebId":"","AccountNo":"1234543DD"}}}');
				res.setStatusCode(200);
				return res;
			}

    	}
       
	@IsTest
    public static void testAccountJSONUnit_A() {
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, new RestMock());
				Account data = TestDataFactory.createAccount('Test', '1234543DD', 'Customers', TRUE); 
				WebsiteAccountJSON.accountRequest(data.id,'DML');
			Test.stopTest();

	}

	@IsTest
    public static void testAccountJSONUNit_B() {
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, new RestMock());
				Account data = TestDataFactory.createAccount('Test', '1234543DD', 'Customers', FALSE); 
				data.Status__c = 'Active';
				data.PPAI_Number__c = '4234234';
				data.ASI_Number__c = '4534534';
				data.Koozie_Group_Tracker_Link__c = 'https://test.test';
				data.Account_Domain__c = '@test.test';
				data.Web_Id__c ='testwebis12343';
				data.BillingStreet = 'test';
				data.BillingCity = 'test';
				data.BillingState = 'test';
				data.BillingPostalCode = 'test';
				data.ShippingStreet = 'test';
				data.ShippingCity = 'test';
				data.ShippingState = 'test';
				data.ShippingPostalCode = 'test';
				data.BillingCountry = 'test';
				data.ShippingCountry = 'test';
				Insert data;

				WebsiteAccountJSON.accountRequest(data.id,'DML');
			Test.stopTest();

	}
}