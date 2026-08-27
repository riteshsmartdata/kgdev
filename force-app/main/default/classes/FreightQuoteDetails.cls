/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-23-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FreightQuoteDetails {

    public class InputWrapper {
        @InvocableVariable(label='Account Id' description='Account Id from Salesforce')
        public String accountId;
        @InvocableVariable(label='Item Number' description='Item Number')
        public String itemNumber;
        @InvocableVariable(label='Quantity' description='Quantity')
        public String quantity;
        @InvocableVariable(label='Zip Code' description='Zip Code')
        public String zipCode; 
    }

    public class OutputWrapper {
        @InvocableVariable(label='Freight Quote Response' description='Freight Quote Response from EBS System')
        public FreightQuoteResponse freightQuoteResponse;
        @InvocableVariable(label='Product URL' description='Product URL from EBS System')
        public String productUrl;
    }
    
    @InvocableMethod(label='Get Freight Quote Details' description='Get Freight Quote Details from EBS System')
    public static List<OutputWrapper> getFreightQuoteDetails(List<InputWrapper> requests) {
        List<OutputWrapper> freightQuotes = new List<OutputWrapper>();
        String productUrl =System.Label.Website_ULR + '/';
        for (InputWrapper req : requests) {

            FreightQuoteResponse freightQuote = DataCloudIntegration.contactSync(
                getCustomerAccountNumber(req.accountId),
                req.itemNumber,
                req.quantity,
                req.zipCode
                
            );
            OutputWrapper output = new OutputWrapper();
            output.freightQuoteResponse = freightQuote;
            output.productUrl = productUrl + req.itemNumber;
            freightQuotes.add(output);
        }
        return freightQuotes;   
    }

    private static String getCustomerAccountNumber(String accountId) {
        // Implement logic to retrieve customer account number if needed
        if (String.isNotBlank(accountId)) {
            // Logic to retrieve and return the customer account number
            Account [] acc = [SELECT Customer_Account_Number__c FROM Account WHERE Id = :accountId LIMIT 1];
            return acc.size() > 0 ? acc[0].Customer_Account_Number__c : null;
        }
        return null;

    }
}