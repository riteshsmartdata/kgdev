/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 10-20-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Ver   Date         Author         Modification
* 1.0   10-13-2022   Ritesh Kumar   
* 1.1   19-10-2023   Arafat         JIRA SF-469

**/
@isTest
public class ContactRequestTest { 
    @isTest
    public static void contactRequest_UnitTest(){ 
        String Request= '{"EventRequest":{"EventBusinessID":"rob.meier@kooziegroup.com.test","EventDateTime":"2022-09-29T12:18:40","EventObject":"CUSTOMER","EventSourceSystem":"GN","EventType":"DML","CustomerData":{"SFId":"","WebId":"5c9e20578513d211813ed6e5a43","accountNumber":"24254","Email":"rob.meier@kooziegroup11.com.test","FirstName":"Rob","LastName":"Meier","userName":"rob.meier@kooziegroup.com.test","primaryPhone":"89562323651","Mobile":"89562323651"}}}';
        
        Test.startTest();
        ContactRequest dataRecord = ContactRequest.parse(Request);
        Test.stopTest(); 
        
    }
}