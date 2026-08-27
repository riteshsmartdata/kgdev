@isTest
public class RelatedQuoteRequestsControllerTest {

    @isTest
    public static void testGetRelatedQuoteRequests() {
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;
        Quote_Request__c quoteRequest = new Quote_Request__c(Opportunity__c = opp.Id);
        insert quoteRequest;
        Quote_Product__c quoteProduct = new Quote_Product__c(
            Quote_Request__c = quoteRequest.Id
        );
        insert quoteProduct;
        List<Quote_Product__c> result = RelatedQuoteRequestsController.getRelatedQuoteRequests(opp.Id);
        System.assertEquals(1, result.size());
        System.assertEquals(quoteProduct.Id, result[0].Id);
    }
}