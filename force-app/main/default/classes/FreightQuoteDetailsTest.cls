/**
 * @description       : Test class for FreightQuoteDetails
 * @author            : Salesforce Developer
 * @group             : Testing
 * @last modified on  : 10-31-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 **/
@isTest
public class FreightQuoteDetailsTest { 
    @isTest
    static void testFreightQuoteCalculation(){
        Test.startTest();

        DataCloudIntegrationMock mock = new DataCloudIntegrationMock();
        Test.setMock(HttpCalloutMock.class, mock); 
        FreightQuoteDetails.InputWrapper input = new FreightQuoteDetails.InputWrapper();
        input.itemNumber = 'ICLGEL';
        input.quantity = '50';
        input.zipCode = '62278';

        List<FreightQuoteDetails.OutputWrapper> result = FreightQuoteDetails.getFreightQuoteDetails(new List<FreightQuoteDetails.InputWrapper>{input});
        System.assert(result != null && !result.isEmpty(), 'Freight quote should not be null or empty');
        Test.stopTest();
    }

    
}