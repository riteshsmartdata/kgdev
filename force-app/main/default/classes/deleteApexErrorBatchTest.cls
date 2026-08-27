//Created by Kumar Saurav
@IsTest
public class deleteApexErrorBatchTest {
    @isTest static void test_method_one() {
        Apex_Errors__c ae = new Apex_Errors__c();
        ae.Object_API_Name__c = 'Contact';
        ae.createdDate = Date.today().addDays(-30);
        insert ae; 
        
        Test.setCreatedDate(ae.Id, Date.today().addDays(-30));
        System.assert(ae != null);
        Test.startTest();
        deleteApexErrorBatch c = new deleteApexErrorBatch();
        Database.executeBatch(c);
        deleteApexErrorSchedule sc = new deleteApexErrorSchedule();
        String sch = '0 0 23 * * ?';
		system.schedule('Test status Check', sch, sc );
        Test.stopTest();
        
    }
}