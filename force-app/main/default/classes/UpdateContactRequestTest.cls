/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 10-13-2022
* @last modified by  : Ritesh Kumar 
*  Ver   Date         Author         Modification
* 1.0   10-19-2023   Ritesh Kumar   
* 1.1   10-20-2023   Ritesh Kumar   JIRA SF-469
**/
@isTest
public class UpdateContactRequestTest { 
    @isTest
    public static void updateContactRequest_UnitTest(){ 
        String Request= '{"EventRequest":{"EventBusinessID":"rob.meier@kooziegroup.com.test","EventDateTime":"2022-09-28T07:43:58","EventObject":"CUSTOMER","EventSourceSystem":"GN","EventType":"Update","CustomerData":{"sf_Id":"0035300000AgKZNAA3","web_Id":"5c9e20578513d813ed6e5a43","userName":"rob.meier@kooziegroup.com","accountNumber":"24254","firstName":"Rob","lastName":"Meier","contactType":"Accounting;Customer Service","emailId":"rob.meier@kooziegroup.com.test","primaryPhone":"9594543003","Mobile":"9594543003","preferanceTypes":[{"preferanceTypeName":"Order","preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"true"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"true"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"true"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"true"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"true"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"false"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"true"}]}]}]}}}';
        
        Test.startTest();
        UpdateContactRequest dataRecord = UpdateContactRequest.parse(Request);
        Test.stopTest();
        
    }
    
}