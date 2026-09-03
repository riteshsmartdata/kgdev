/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 03-20-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-15-2024   Ritesh Kumar   Initial Version
**/
public class EBSContactResponse {
    public EventResponse EventResponse;
    public class EventResponse {
        public String EnterpriseEventID;	//414184567
        public String EventBusinessID;	//1234567890
        public String EventStatus;	//SUCCESS
        public EventErrorCode EventErrorCode;
        public String EventStatusMessage;	//SUCCESS
        public boolean MustRetryFlag;
        public CustomerContacts CustomerContacts;
    }
    
    public class EventErrorCode {
    }
    
    public class CustomerContacts {
        public String CustomerAccountNumber;	//745318
        public CustomerContact[] CustomerContact;
    }
    
    public class CustomerContact {
        public String ContactID;	//2630237
        public String ContactFirstName;	//AP
        public String ContactLastName;	//AP
        public String ContactStatus;	//A
        public String JobTitle;	// 
        public String ContactCreateDate;	//2022-07-28T16:27:39.000-05:00
        public String ContactLastUpdateDate;	//2024-03-20T04:42:41.000-05:00
        public String ResponsibilityType;	//INVOICE EMAIL
        public String PrimaryResponsibilityFlag;	//Y
        public ContactAddress ContactAddress;
        public Communications Communications;
    }
    
    public class ContactAddress {
        public ContactAddresses[] ContactAddresses;
    }
    
    public class ContactAddresses {
        public String AddressID;	//7591877
        public String AddressLine1;	//10201 W OKLAHOMA AVE,,,
        public String AddressLine2;	// 
        public String AddressLine3;	// 
        public String AddressLine4;	// 
        public String County;	// 
        public String City;	//GREENFIELD
        public String State;	//WI
        public String Country;	//US
        public String PostalCode;	//53227
        public String Status;	// 
    }
    
    public class Communications {
        public CommunicationArray[] CommunicationArray;
    }
    
    public class CommunicationArray {
        public String CommunicationID;	//2022074
        public String CommunicationMethod;	//EMAIL
        public String CommunicationInfo;	//mary@pressworksprinting.com.full44
        public String QueueRouteNumber;	// 
        public String ActiveFlag;	//A
        public String PrimaryFlag;	//true
    }
    
    public static EBSContactResponse parse(String json){
        return (EBSContactResponse) System.JSON.deserialize(json, EBSContactResponse.class);
    }
    
}