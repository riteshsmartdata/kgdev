/**
 * @description       : Mock class for DataCloudIntegration to enable testing without actual HTTP callouts
 * @author            : Salesforce Developer
 * @group             : Testing
 * @last modified on  : 10-31-2025
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
**/
@isTest
public class DataCloudIntegrationMock implements HttpCalloutMock {
    
    /**
     * Implement the HttpCalloutMock interface to return predefined test data
     * @param request The HTTP request that would normally be sent
     * @return HttpResponse with mocked data matching your example
     */
    public HttpResponse respond(HTTPRequest request) {
        // Create a fake response that matches your provided example
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        // Create the response body matching your example exactly (using single line string)
        String responseBody = '{"data":{"response":[{"item_number":"ICLGEL","quantity":50,"currency_code":"USD","ship_method":null,"packing_option":"Standard","ship_from":null,"ship_to":{"address_line_1":null,"city":null,"state":"IL","zip_code":"62278","country":"US"},"freight_calculation":{"package_weight":1.602,"charges":[{"ship_method":"S/H Standard","base":0,"variable":0,"hazmat":0,"delivery_in_days":5,"total":27.03},{"ship_method":"S/H 2nd Day","base":0,"variable":0,"hazmat":0,"delivery_in_days":4,"total":44.26},{"ship_method":"S/H 3 Day","base":0,"variable":0,"hazmat":0,"delivery_in_days":5,"total":52.69},{"ship_method":"S/H Next Day (by 10:30 AM)","base":0,"variable":0,"hazmat":0,"delivery_in_days":3,"total":85.18}]}}]}}';
        
        response.setBody(responseBody);
        response.setStatusCode(200);
        
        return response;
    }
}