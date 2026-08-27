/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 02-25-2025
 * @last modified by  : Ritesh Kumar
**/
@isTest
public class PreChatHandlerTest {

	private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"EventResponse":{"EnterpriseEventID":"415336316","EventBusinessID":"1234567890","EventStatus":"SUCCESS","EventErrorCode":null,"EventStatusMessage":"SUCCESS","MustRetryFlag":false,"CustomerContacts":{"CustomerAccountNumber":"745318","CustomerContact":[{"ContactID":"2630237","ContactFirstName":"AP","ContactLastName":"AP","ContactStatus":"A","JobTitle":" ","ContactCreateDate":"2022-07-28T16:27:39.000-05:00","ContactLastUpdateDate":"2024-03-20T04:42:41.000-05:00","ResponsibilityType":"INVOICE EMAIL","PrimaryResponsibilityFlag":"Y","ContactAddress":{"ContactAddresses":[{"AddressID":"7591877","AddressLine1":"10201 W OKLAHOMA AVE,,,","AddressLine2":" ","AddressLine3":" ","AddressLine4":" ","County":" ","City":"GREENFIELD","State":"WI","Country":"US","PostalCode":"53227","Status":" "}]},"Communications":{"CommunicationArray":[{"CommunicationID":"2022074","CommunicationMethod":"EMAIL","CommunicationInfo":"mary@pressworksprinting.com.full44","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"true"},{"CommunicationID":"2022075","CommunicationMethod":"PHONE","CommunicationInfo":"414-329-3540","QueueRouteNumber":" ","ActiveFlag":"A","PrimaryFlag":"false"}]}}]}}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

	@TestSetup
    static void setup() {
      	TestDataFactory.loadAppSetting(); 
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountInfo  = TestDataFactory.createAccount('Test Account','0123645','Customers',TRUE);
        Contact contactInfo = TestDataFactory.createContact('Test', 'Test', accountInfo.Id, 'CRM Contact', FALSE);
		contactInfo.email = 'test@test.com.full';
        Insert contactInfo;
    }
    
    @isTest
    static void testcheckWorkingHours() {
        Test.startTest();        
        Boolean result = PreChatHandler.checkWorkingHours('Regular Business Hours');
        Test.stopTest();
        System.assertEquals(true, result);
    }

	@IsTest
	static void testloadChatSetting() {
		Test.startTest();
			Chat_Setting__mdt chatSetting = PreChatHandler.loadChatSetting();
			System.assertEquals(true, chatSetting != null);
		Test.stopTest();
	}

	@IsTest
	static void testSendOTP() {

		Chat_Setting__mdt chatSetting = PreChatHandler.loadChatSetting();
		Map<String, String> replacements = new Map<String, String>{
			'Firstname' => 'Test',
			'Lastname' => 'Test',
			'email' => 'test@test.com.full'
		};

		String testEmailBody =  chatSetting.Email_Message__c;
		Test.startTest();
			Boolean isPresent = PreChatHandler.sendOTP(replacements, testEmailBody);
			System.assertEquals(true, isPresent);
		Test.stopTest();
	}
    
    @IsTest
	static void testreSendOTP() {

		Chat_Setting__mdt chatSetting = PreChatHandler.loadChatSetting();
		Map<String, String> replacements = new Map<String, String>{
			'Firstname' => 'Test',
			'Lastname' => 'Test',
			'email' => 'test@test.com.full'
		};
         
		Test.startTest();
        	String testEmailBody =  chatSetting.Email_Message__c;
        	Boolean isPresent = PreChatHandler.sendOTP(replacements, testEmailBody);
			PreChatHandler.reSendOTP(replacements, testEmailBody);
		Test.stopTest();
	}
    
    @IsTest
	static void testvalidateOTP() {

		Chat_Setting__mdt chatSetting = PreChatHandler.loadChatSetting();
		Map<String, String> replacements = new Map<String, String>{
			'Firstname' => 'Test',
			'Lastname' => 'Test',
			'email' => 'test@test.com.full'
		};
         
		Test.startTest();
        	String testEmailBody =  chatSetting.Email_Message__c;
        	Boolean isPresent = PreChatHandler.sendOTP(replacements, testEmailBody);
        	OTP__c otpRecord = [SELECT OTP_Code__c, Expiration_Time__c FROM OTP__c WHERE Email__c = :replacements.get('email') ORDER BY CreatedDate DESC LIMIT 1];
			Boolean isSuccess = PreChatHandler.validateOTP(replacements.get('email'), otpRecord.OTP_Code__c);
       		 System.assertEquals(true, isSuccess);
		Test.stopTest();

	}

	@isTest
    static void testcheckWorkingHoursException() {
       
		Test.startTest();
        try {
            Boolean result = PreChatHandler.checkWorkingHours(null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should not be null');
        }
        Test.stopTest();
    }
	

	@isTest
    static void  testSendOTPException() {
        Test.startTest();
        try {
            Boolean isPresent = PreChatHandler.sendOTP(null, null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should not be null');
        }
        Test.stopTest();
    }

	@isTest
    static void  testreSendOTPException() {
        Test.startTest();
        try {
            PreChatHandler.reSendOTP(null, null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should not be null');
        }
        Test.stopTest();
    }

	@isTest
    static void testValidateOTPException() {
        Test.startTest();
        try {
            Boolean result = PreChatHandler.validateOTP(null, null);
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception e) {
            System.assert(e != null, 'Exception should not be null');
        }
        Test.stopTest();
    }
}