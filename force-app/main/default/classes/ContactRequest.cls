/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-04-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
 * Ver   Date         Author         Modification
 * 1.0   10-13-2022   Ritesh Kumar   
 * 1.1   19-10-2023   Arafat         JIRA SF-469 Code Line 30
**/

public class ContactRequest{
	public EventRequest EventRequest;
	public class EventRequest {
		public String EventBusinessID;	//sagar.hadkar@kooziegroup.com
		public String EventDateTime;	//2022-09-12T16:56:56
		public String EventObject;	//CUSTOMER
		public String EventSourceSystem;	//GN
		public String EventType;	//UPDATE
		public CustomerData CustomerData;
	}
	public class CustomerData {
		public String SFId;	//SalesforceID
		public String WebId;	//WebsiteID
		public String userName;	//C000090
		public String accountNumber;	//24254
		public String firstName;	//Sagar
		public String lastName;	//Hadkar
		public String contactType;	//Admin
		public String industryType;
		public String Email;	//sagar.hadkar@kooziegroup.com
		public String primaryPhone;	//9594543003
		public String Mobile;	//9594543003
		public boolean isMobile;
		public string accountName;
		public string sfAccountId;
		public string sfRecordTypeName;
		public string sfRecordTypeId;
        public string marketingLink;
		public DateTime contactCreatedDate;
		public DateTime lastLoginDate;
		public boolean contactActiveStatus;
		public PreferanceTypes[] preferanceTypes;
		public accountPreferences accountPreferences;
	}
	public class PreferanceTypes {
		public String preferanceTypeName;	//ORDER
		public String preferanceTypeId;
		public String preferanceTypeDetails;
		public String preferanceTypeDetailsId;
		public Preferances[] preferances;
	}
	public class Preferances {
		public String preferanceType;	//PO_Confirmation
		public String preferanceName;	//PO Confirmation
		public PreferancesMethod[] preferancesMethod;
	}
	public class PreferancesMethod {
		public String Text;	//Email
		public String Value;	//Email
		public String Selected;	//true
	}

	public class AccountPreferences {
		//public String firstName;	//Rob
		//public String lastName;	//Meier
		//public String emailId;	//ROB@GREATVALUEPROMOS.COM
		//public String mobileNo;	//555-555-555
       // public String salesforceId;
		public boolean Acc_poConfirmation;
		public boolean Acc_orderAcceptance;
		public boolean Acc_shipmentConfirmation;
		public boolean Acc_proofConfirmation;
		public boolean Acc_clarificationConfirmation;
		public String selectedMethod;	//Email
	}

	public static ContactRequest parse(String json){
		return (ContactRequest) System.JSON.deserialize(json, ContactRequest.class);
	}
 
}