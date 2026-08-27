@isTest
public class AccountStatusSyncBatchTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.loadAppSetting(); 
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Account accountRecorda = TestDataFactory.createAccount('Test', 'test1234', 'Customers', false);
        accountRecorda.Status__c = 'Inactive';
        Insert accountRecorda ;
        
        Contact contactRecordb = TestDataFactory.createContact('Test', 'Test', accountRecorda.Id, 'CRM Contact', true);
        
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse(); 
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"test@testers.com","EventStatus":"SUCCESS","EventType":"DML","EventStatusMessage":"Successfully Completed","CustomerData":{"sf_Id":"0035300000BK8KAAA1","web_Id":"5c9e20578513d211813ed6e5a43","userName":"test@testers.com","accountNumber":"24254","firstName":"Rob","lastName":"Meier","contactType":"Other","emailId":"test@testers.com","primaryPhone":null,"Mobile":null,"preferanceTypes":[{"preferanceTypeName":"Order Communication","preferanceTypeId":"Order_Communication","preferanceTypeDetails":null,"preferanceTypeDetailsId":null,"preferances":[{"preferanceType":"PO_Confirmation","preferanceName":"PO Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Order_Acknowledgement","preferanceName":"Order Acknowledgement","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"Shipment_Confirmation","preferanceName":"Shipment Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Proof_Confirmation","preferanceName":"Proof Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]},{"preferanceType":"When_Status_changes","preferanceName":"When Status changes","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"},{"Text":"None","Value":"None","Selected":"false"}]},{"preferanceType":"Clarification_Confirmation","preferanceName":"Clarification Confirmation","preferancesMethod":[{"Text":"Email","Value":"Email","Selected":"true"},{"Text":"Text","Value":"Text","Selected":"false"},{"Text":"Both","Value":"Both","Selected":"false"}]}]}]}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @IsTest
    static void testBatch(){
        Test.setMock(HttpCalloutMock.class, new RestMock());         
        Test.startTest();
        AccountStatusSyncBatch accountSyncBatch = new AccountStatusSyncBatch();
        Database.executeBatch(accountSyncBatch);
        Test.stopTest();
        
    }
}