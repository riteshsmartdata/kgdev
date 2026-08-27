public without sharing class EBSContactIntegrationService {

    public static List<EBSFinanceContactBatch.EBSContactCalloutResult> sendContactDataBulk(List<Id> contactIds, String eventType ){
        
        System.debug('ContactIds --> ' + contactIds);
        System.debug('EventType --> ' + eventType); 

        List<EBSFinanceContactBatch.EBSContactCalloutResult> results = new List<EBSFinanceContactBatch.EBSContactCalloutResult>();

        if(contactIds == null || contactIds.isEmpty()){ 
            return results; 
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, FirstName, LastName, Email, Phone,Responsibility_Type__c,
                   Contact_Status__c,
                   PrimaryEmailFlag__c, PrimaryPhoneFlag__c,
                   Account.Customer_Account_Number__c,
                   CreatedDate, LastModifiedDate
            FROM Contact
            WHERE Id IN :contactIds
        ]);

        AppInfo__c appInfo = KoozieUtility.isSandbox()
            ? AppInfo__c.getValues('Sandbox')
            : AppInfo__c.getValues('WebClient');

        System.debug('Is Sandbox --> ' + KoozieUtility.isSandbox());
        System.debug('Endpoint --> ' + appInfo.endpoint__c);

        Http http = new Http();

        for(Contact con : contactMap.values()) {

            EBSFinanceContactBatch.EBSContactCalloutResult r = new EBSFinanceContactBatch.EBSContactCalloutResult();

            String requestJSON = EBSContactRequestFinance.contactRequestFromContact(con, eventType);

            System.debug('Request JSON --> ' + requestJSON);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(appInfo.endpoint__c);
            req.setMethod('POST');
            req.setTimeout(120000);

            String auth =
                'BASIC ' +
                EncodingUtil.base64Encode(
                    Blob.valueOf(appInfo.user__c + ':' + appInfo.password__c)
                );
            System.debug('auth'+auth);

            req.setHeader('Authorization', auth);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(requestJSON);

            try {
                HttpResponse res = http.send(req);

                System.debug('Response StatusCode --> ' + res.getStatusCode());

                if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
                    r.source = 'EBSContactIntegrationService';
                    r.requestBody = requestJSON;
                    r.responseBody = res.getBody();
                    r.contactId = con.Id;
                    r.objectName = 'Contact';
                    r.statusCode = res.getStatusCode();
                    r.error = 'HTTP Error';
                    r.isSuccess = false;
                } else {
                    r.isSuccess = true;
                }

            } catch (Exception e) {
                System.debug('Exception Occurred --> ' + e.getMessage());

                r.source = 'EBSContactIntegrationService';
                r.requestBody = requestJSON;
                r.contactId = con.Id;
                r.objectName = 'Contact';
                r.statusCode = 500;
                r.error = e.getMessage();
                r.isSuccess = false;
            }

            results.add(r);
        }

        return results;
    }
}