/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 01-20-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   11-25-2024   Ritesh Kumar   Initial Version
**/
@RestResource(urlMapping='/CreateCaseClaims')
global with sharing class CreateClaimEventService {
    
    // Updated class to represent the incoming request structure
    global class EventRequestWrapper {
        public EventRequest EventRequest;
    }
    
    global class EventRequest {
        public String EventObject;
        public String EventDateTime;
        public String EventSourceSystem;
        public String EventBusinessID;
        public SFClaimData SFClaimData;
    }
    
    // Separate class for SFClaimData
    global class SFClaimData {
        public String AccountNo;
        public String SalesOrder;
        public String Subject;
        public String WebsiteDescription;
        public String Comment;
        public String ContactID;
        public Boolean WebClaim;
        public string ResolutionNote;
        public List<fileattachment> attachments;
    }
    
    global class fileattachment{
        public String filename;
        public String fileType;
        public String fileurl;
    }
    
    @HttpPost
    global static ClaimResponse handleClaimEvent() {
        // Get the request body directly from the RestRequest
        RestRequest req = RestContext.request;
        String jsonInput = req.requestBody.toString();
        
        // Parse the incoming JSON string to an EventRequestWrapper object
        EventRequestWrapper eventRequestWrapper;
        ClaimResponse claimResponse = new ClaimResponse();
        try {
            eventRequestWrapper = (EventRequestWrapper) JSON.deserialize(jsonInput, EventRequestWrapper.class);
        } catch (Exception e) {
            // Handle JSON deserialization error
            claimResponse.EventResponse.EventStatus = 'ERROR';
            claimResponse.EventResponse.EventStatusMessage = 'Invalid JSON input: ' + e.getMessage();
            ApexLogUtill.createApexLog('CreateClaimEventService.handleClaimEvent', 'claimResponse' , e.getMessage(), null, 'RestRequest', e.getMessage(), 0);
            return claimResponse;
        }
        
        // Initialize the response object
        EventRequest eventRequest = eventRequestWrapper.EventRequest;
        claimResponse.EventResponse.EventBusinessID = eventRequest.EventBusinessID;
        
        // Get the RecordType for the case
        String recordTypeId = KoozieUtility.getRecordTypeId('Case', 'Claims');
        // RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Claims' LIMIT 1];
        
        try {
            // Create a new Case record
            Case newCase = new Case();
            newCase.Subject = eventRequest.SFClaimData.Subject;
            newCase.Website_Description__c = eventRequest.SFClaimData.WebsiteDescription;
            newCase.Resolution_Note__c = eventRequest.SFClaimData.ResolutionNote;
            newCase.Status = 'New'; // Set the default status
            newCase.Origin = eventRequest.EventSourceSystem;
            newCase.Comments = eventRequest.SFClaimData.Comment;
            if(String.isNotBlank(eventRequest.SFClaimData.ContactID) && eventRequest.SFClaimData.ContactID != 'null'){
            	newCase.ContactId = eventRequest.SFClaimData.ContactID ;
            }
            
            newCase.Web_Claim__c = eventRequest.SFClaimData.WebClaim;
            newCase.RecordTypeId = recordTypeId;
            
            // Retrieve the Account ID based on AccountNo
            Account account = new Account();
            try {
                account = [SELECT Id FROM Account WHERE Customer_Account_Number__c  = :eventRequest.SFClaimData.AccountNo LIMIT 1];
                newCase.AccountId = account.Id;
            } catch (Exception e) {
                claimResponse.EventResponse.EventStatus = 'ERROR';
                claimResponse.EventResponse.EventStatusMessage = 'Account not found for AccountNo: ' + eventRequest.SFClaimData.AccountNo;
                ApexLogUtill.createApexLog('CreateClaimEventService.handleClaimEvent', 'claimResponse' , e.getMessage(), null, 'Account', e.getMessage(), 0);
                return claimResponse;
            }
            
            // Retrieve the EBS Order ID based on SalesOrder
            EBS_Order__c ebs;
            try {
                ebs = [SELECT Id, EBS_Order_Number__c FROM EBS_Order__c  WHERE EBS_Order_Number__c = :eventRequest.SFClaimData.SalesOrder LIMIT 1];
                newCase.EBS_Order__c = ebs.Id;
            } catch (Exception e) {
                claimResponse.EventResponse.EventStatus = 'ERROR';
                claimResponse.EventResponse.EventStatusMessage = 'EBS Order not found for SalesOrder: ' + eventRequest.SFClaimData.SalesOrder;
                ApexLogUtill.createApexLog('CreateClaimEventService.handleClaimEvent', 'claimResponse' , e.getMessage(), null, 'EBS_Order__c', e.getMessage(), 0);
                return claimResponse;
            }
            
            insert newCase; 
            // // Call the Queueable Apex to handle attachments
            if(eventRequest.SFClaimData.attachments != null && eventRequest.SFClaimData.attachments.size() > 0) {
                System.enqueueJob(new HandleFileAttachmentsJob(eventRequest.SFClaimData.attachments, newCase.Id)); 
            }
            
            
            case  newCase1 = [SELECT CaseNumber FROM Case WHERE Id = :newCase.Id LIMIT 1];
            
            // Set the response data
            claimResponse.EventResponse.EventStatus = 'SUCCESS';
            claimResponse.EventResponse.EventStatusMessage = 'Successfully Completed.';
            //claimResponse.EventResponse.ClaimData = new ClaimResponse.EventResponse.ClaimData();
            claimResponse.EventResponse.ClaimData.SalesforceID = newCase.Id;
            claimResponse.EventResponse.ClaimData.ClaimID = newCase1.CaseNumber;
        } catch (Exception e) {
            // Handle any exceptions that occur during processing 
            claimResponse.EventResponse.EventStatus = 'ERROR';
            claimResponse.EventResponse.EventStatusMessage = 'Failed to create case: ' + e.getMessage();
            ApexLogUtill.createApexLog('CreateClaimEventService.handleClaimEvent', 'claimResponse' , e.getMessage(), null, 'case', e.getMessage(), 0);
        }
        
        return claimResponse;
    }
    
    // Queueable Apex to handle file attachments asynchronously with a callout
    global class HandleFileAttachmentsJob implements Queueable, Database.AllowsCallouts {
        private List<fileattachment> attachments;
        private String recordId;
        
        global HandleFileAttachmentsJob(List<fileattachment> attachments, String recordId) {
            this.attachments = attachments;
            this.recordId = recordId;
        }
        
        global void execute(QueueableContext context) {
            List<ContentVersion> fileVersion = new List<ContentVersion>();
            List<ContentDocumentLink> fileLink = new List<ContentDocumentLink>();
            Set<Id> cvids = new Set<Id>();
            
            // Loop through the attachments and create ContentVersion
            for (fileattachment fileINFO : attachments) {              
                fileVersion.add(new ContentVersion(
                    Title = fileINFO.filename,
                    PathOnClient = fileINFO.fileType,
                    VersionData = downloadFileAndSaveToSalesforce(fileINFO.fileurl),
                    Description = fileINFO.fileurl
                ));
            }
            
            if (fileVersion.size() > 0) {
                insert fileVersion;
            }
            
            for (ContentVersion cv : fileVersion) {
                cvids.add(cv.Id);
            }
            
            // Link the ContentVersion to the Case
            ContentVersion[] insertedContent = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvids];
            for (ContentVersion cv : insertedContent) {
                fileLink.add(new ContentDocumentLink(
                    ContentDocumentId = cv.ContentDocumentId,
                    LinkedEntityId = recordId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
            }
            
            if (fileLink.size() > 0) {
                insert fileLink;
            }
        }
        
        
        // Method to perform the actual callout (e.g., downloading the file)
        global Blob downloadFileAndSaveToSalesforce(String fileurl) {
            // Make a callout here (e.g., to an external service to fetch the file)
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(fileurl); // Example URL
            request.setMethod('GET');
            
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                return response.getBodyAsBlob(); // Return the file's blob content
            } else {
                throw new CalloutException('Failed to download the file');
            }
        }
    }
    
}