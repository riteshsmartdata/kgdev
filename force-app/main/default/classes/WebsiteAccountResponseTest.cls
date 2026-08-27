/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 10-03-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/

@isTest
public without sharing class WebsiteAccountResponseTest {
    
@IsTest
static void accountJSONTest() {
	String response ='{"EventResponse":{"EventBusinessID":"24254","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","AccountData":{"SFId":"0011U00000QLklCQAT","WebId":"603bf49e210fc60f94f90ccb","AccountNo":"24254"}}}';
	Test.startTest();
		WebsiteAccountResponse accountRecord = WebsiteAccountResponse.parse(response);
	Test.stopTest();
}

}