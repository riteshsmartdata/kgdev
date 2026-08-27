/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-29-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
@SuppressWarnings('PMD.AvoidDebugStatements,PMD.ExcessiveParameterList')
public without sharing class DataCloudIntegration {

    /**
     * Method to get Freight Quote from Data Cloud
     * @param customerAccountNumber
     * @param itemNumber
     * @param quantity
     * @param city
     * @param state
     * @param zipCode
     * @param country
     * @return FreightQuoteResponse
     * @Description : Method to get Freight Quote from EBS system.
     */
    public static FreightQuoteResponse contactSync(
        String customerAccountNumber,
        String itemNumber,
        String quantity,
        String zipCode
    ) {
        FreightQuoteResponse freightQuote = new FreightQuoteResponse();
        //Rest Request
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Get Integration Credentials from Custom Metadata
        Data_Cloud_Integration__mdt integrationCreds = [ // NOPMD
            SELECT
                End_Point_URL__c, Password__c, User__c
            FROM
                Data_Cloud_Integration__mdt
            WHERE
                DeveloperName = 'Fright_Quote'
            LIMIT 1
        ];

        String jsonSrting = FreightQuoteRequest.quoteRequest(customerAccountNumber, itemNumber, quantity, zipCode).getAsString();
        request.setEndpoint(integrationCreds.End_Point_URL__c);
        request.setMethod(DataCloudConstants.METHOD_POST);
        Blob headerValue = Blob.valueOf(integrationCreds.User__c + ':' + integrationCreds.Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Accept', DataCloudConstants.APPLICATION_JSON);
        request.setHeader('Content-Type', DataCloudConstants.APPLICATION_JSON);
        request.setBody(jsonSrting);
        request.setTimeout(DataCloudConstants.TIMEOUT);
        HTTPResponse response;
        response = http.send(request);
        System.debug(LoggingLevel.INFO, '====== request ======' + request.getBody());
        System.debug(LoggingLevel.INFO, '====== Response ======' + response.getBody());
        if (DataCloudConstants.SUCCESS_CODES.contains(response.getStatusCode())) {
            freightQuote = FreightQuoteResponse.parse(response.getBody());
        } else {
            freightQuote = new FreightQuoteResponse();
        }

        System.debug(LoggingLevel.INFO, '====== JSON ======' + FreightQuoteResponse.parse(response.getBody()));
        return freightQuote;
    }
}