@isTest
public class AccountContactRelationHandlerTest {
    
    private class RestMockContact implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventBusinessID":"sagar.hadkar@gmail.com","EventStatus":"SUCCESS","EventStatusMessage":"Successfully Completed","CustomerData":{"SFId":"0035300000AfrYEAAZ","WebId":"633c038706681158863d1cd7","Email":"sagar.hadkar@gmail.com"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    private class RestMockContactRelation implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"EventResponse":{"EventStatusMessage":"Successfully Completed.","EventStatus":"SUCCESS","EventBusinessID":"003UR00000mtlYwYAI","AccountContactRelation":{"SfId":"003UR00000mtlYwYAI","webId__c":"04245653"}}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @TestSetup
    static void makeData(){
        TestDataFactory loadDedefault = new TestDataFactory('default');
        TestDataFactory.switchTriggerSetting();
        Test.setMock(HttpCalloutMock.class, new RestMockContactRelation()); 
        Account accountData = TestDataFactory.createAccount('Test Account', 'test2314','Customers', TRUE);
        Contact contactData = TestDataFactory.createContact('Last Test', 'First Test', accountData.Id, 'CRM Contact', TRUE);
    }
    
    @isTest
    public static void testWebSync(){
        
        Account accountData = [SELECT Id FROM Account LIMIT 1];
        Contact contactData = [SELECT Id FROM Contact LIMIT 1];
        AccountContactRelation [] eacr = [SELECT Id FROM AccountContactRelation LIMIT 1];
        AccountContactRelation acr = new AccountContactRelation();
        if(eacr.size() > 0){
            acr.Id = eacr[0].Id;
        }else{
            acr.ContactId = contactData.Id;
            acr.AccountId = accountData.Id;
            
        }
        
        acr.IsActive = TRUE;
        acr.EndDate = System.today() + 5;
        acr.StartDate = System.today();
        acr.Relationship_Strength__c = 'Strong';
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMockContactRelation());
        Upsert acr;
        AccountContactRelation [] eacr1 = [SELECT Id,webId__c FROM AccountContactRelation LIMIT 1];
        if(eacr1.size() > 0){
            System.assertEquals(TRUE, String.isNotBlank(eacr1[0].webId__c),'not sync');
        }
        
        Test.stopTest();
        
    }
    
}