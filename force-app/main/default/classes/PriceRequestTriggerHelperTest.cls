@isTest
private class PriceRequestTriggerHelperTest {
    @testSetup
    static void setup() {
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert testCase;
        
        Inquiry__c testInquiry = new Inquiry__c(
            Source__c = 'Email' 
        );
        insert testInquiry;
    }
    
    @isTest
    static void testPriceRequestAddValidation() {
        
        List<Inquiry__c> inquiryList = [SELECT Id, Source__c, Case__c FROM Inquiry__c WHERE Source__c = 'Email' LIMIT 1];
        
        Test.startTest();
        PriceRequestTriggerHelper.priceRequestAddValidation(inquiryList);
        Test.stopTest();
        
    }
}