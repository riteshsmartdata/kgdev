/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 09-18-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
public without sharing class WebsiteAccountResponse {
	public EventResponse EventResponse;
	public class EventResponse {
		public String EventBusinessID;
		public String EventStatus;
		public String EventStatusMessage;
		public AccountData accountData;
	}
	public class AccountData {
		public String SFId;	
		public String WebId;	
		public String AccountNo;
	}
	public static WebsiteAccountResponse parse(String json){
		return (WebsiteAccountResponse) System.JSON.deserialize(json, WebsiteAccountResponse.class);
	} 
     
}