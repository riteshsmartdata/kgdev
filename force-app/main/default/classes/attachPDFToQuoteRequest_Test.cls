/**
 * @description       : 
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Sandeep Reddy
**/
@isTest
public class attachPDFToQuoteRequest_Test {
  @TestSetup
  static void makeData(){
    Account acc = TestData.createAccount(false);
    acc.Name = 'test';
    acc.Customer_Account_Number__c = '12345';
    acc.Routing_Override__c = 'Calendar Dedicated';
    acc.Logo__c ='Calendar Coop';
    insert acc;
    Quote_Request__c QuoteReq = new Quote_Request__c();
    QuoteReq.Account__c = acc.id;
    QuoteReq.Stage__c = 'Request in Draft';
    insert QuoteReq;
  }
  @isTest
  public static void TestQuoteCalenderPDf(){
    Quote_Request__c QuoteReq = [SELECT Id FROM Quote_Request__c LIMIT 1];
    test.startTest();
      PageReference pageRef = Page.Calendar_Quote_PDF;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('Recordid', QuoteReq.id);
      attachPDFToQuoteRequest obj = new attachPDFToQuoteRequest();
      attachPDFToQuoteRequest.attachPDF(QuoteReq.id,'Calendar');
    test.stopTest();
  }
  @isTest
  public static void TestQuoteNonCalenderPDf(){
    Quote_Request__c QuoteReq = [SELECT Id FROM Quote_Request__c LIMIT 1];
    ContentVersion testContentVersion = new ContentVersion();
    testContentVersion.Title = 'Test Content';
    testContentVersion.VersionData = Blob.valueOf('Test Content Version Data');
    testContentVersion.PathOnClient = 'testfile.txt';
    insert testContentVersion;
    ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
    testContentDocumentLink.ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id)].Id;
    testContentDocumentLink.LinkedEntityId = QuoteReq.Id;
    testContentDocumentLink.ShareType = 'V';
    insert testContentDocumentLink;
    test.startTest();
      PageReference pageRef = Page.HS_Quote_PDF;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('Recordid', QuoteReq.id);
      attachPDFToQuoteRequest obj = new attachPDFToQuoteRequest();
      attachPDFToQuoteRequest.attachPDF(QuoteReq.id,'HS_Quote');
    test.stopTest();
  }
  @isTest
  private static void testScenario(){
    Quote_Request__c testQuoteRequest = new Quote_Request__c();
    insert testQuoteRequest;
    ApexPages.StandardController controller = new ApexPages.StandardController(testQuoteRequest);
    test.startTest();
      attachPDFToQuoteRequest controllerExtension = new attachPDFToQuoteRequest(controller);
    test.stoptest();
  }
}