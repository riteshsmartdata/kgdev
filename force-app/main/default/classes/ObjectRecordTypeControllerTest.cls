@isTest
private class ObjectRecordTypeControllerTest {
    
    @isTest
    static void testGetObjectOptions() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<ObjectRecordTypeController.ObjectOptions> objectOptions = ObjectRecordTypeController.getObjectOptions();
        Test.stopTest();
        
        System.assertNotEquals(0, objectOptions.size(), 'Object options list should not be empty.');
        System.assertEquals(3, objectOptions.size(), 'Expected 3 object options.');
    }
    
    @isTest
    static void testGetRecordTypesByObject() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<ObjectRecordTypeController.RecordTypeOptions> recordTypes = ObjectRecordTypeController.getRecordTypesByObject('Account');
        Test.stopTest();
        
        System.assertNotEquals(0, recordTypes.size(), 'Record types list should not be empty.');
    }
    
    @isTest
    static void testDuplicateEmail() {
        RecordType conRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<sObject> duplicates = ObjectRecordTypeController.duplicateEmail('Contact', conRecordType.Id, Date.today().year());
        Test.stopTest();
        
    }
    
    @isTest
    static void testDuplicateEmail2() {
        RecordType accRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<sObject> duplicates = ObjectRecordTypeController.duplicateEmail('Account', accRecordType.Id, Date.today().year());
        Test.stopTest();
        
    }
    @isTest
    static void testFilteredRecords() {
        RecordType conRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' LIMIT 1];
        List<Id> excludeIds = new List<Id>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<sObject> duplicates = ObjectRecordTypeController.getFilteredRecords('Contact', conRecordType.Id, Date.today().year(), excludeIds);
        Test.stopTest();
        
    }
    
    @isTest
    static void testFilteredRecords2() {
        RecordType conRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' LIMIT 1];
        List<Id> excludeIds = new List<Id>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<sObject> duplicates = ObjectRecordTypeController.getFilteredRecords('Account', conRecordType.Id, Date.today().year(), excludeIds);
        Test.stopTest();
        
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'Response';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}