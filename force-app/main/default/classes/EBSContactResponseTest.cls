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

@isTest
public class EBSContactResponseTest {
    
    
    @isTest
    public static void parse_TEST(){
        String jsonInfo = '{"EventRequest":{"EventType":"UPDATE","EventSourceSystem":"Salesforce","EventRecordSystem":"EBS","EventObject":"CUSTOMER_CONTACT","EventDateTime":"2024-03-20T09:42:42.822Z","EventBusinessID":"1234567890","CustomerContacts":{"CustomerContact":[{"ResponsibilityType":"INVOICE EMAIL","PrimaryResponsibilityFlag":"Y","PrimaryFlag":null,"ContactStatus":"A","ContactLastUpdateDate":"2024-03-20T09:42:41.000Z","ContactLastName":"AP","ContactID":"2630237","ContactFirstName":"AP","ContactCreateDate":"2022-07-28T21:27:39.000Z","ContactAddress":{"ContactAddresses":[{"State":"WI","Province":"WI","PostalCode":"53227","County":null,"Country":"US","City":"GREENFIELD","AddressLine4":"","AddressLine3":"","AddressLine2":"","AddressLine1":"10201 W OKLAHOMA AVE,,,","AddressID":"7591877"}]},"Communications":{"CommunicationArray":[{"PrimaryFlag":"true","CommunicationMethod":"EMAIL","CommunicationInfo":"mary@pressworksprinting.com.full44","CommunicationID":"2022074","ActiveFlag":"A"},{"PrimaryFlag":"false","CommunicationMethod":"PHONE","CommunicationInfo":"414-329-3540","CommunicationID":"2022075","ActiveFlag":"A"}]},"ActiveFlag":"A"}],"CustomerAccountNumber":"745318"}}}';

        Test.StartTest();
        	EBSContactResponse data = EBSContactResponse.parse(jsonInfo);
        	System.assertEquals(TRUE , data != NULL );
        Test.StopTest();
    }

}