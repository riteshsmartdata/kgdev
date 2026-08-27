/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 11-06-2024
* @last modified by  : Ritesh Kumar 
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   11-06-2024   Ritesh Kumar   Initial Version
**/
@RestResource(urlMapping='/GetClaims')
global class Getclaimwebservice {
    @HttpPost
    global static void handleClaimRetrieval() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        // Create a response map to hold the response data
        Map<String, Object> responseMap = new Map<String, Object>();
        
        try {
            // Parse the incoming JSON request
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
            
            // Extract necessary fields from the request JSON
            Map<String, Object> eventRequest = (Map<String, Object>)requestMap.get('EventRequest');
            String eventBusinessID = (String)eventRequest.get('EventBusinessID');
            List<Object> requestRecords = (List<Object>)((Map<String, Object>)eventRequest.get('RequestRecords')).get('RequestRecord');
            
            // Variables to store key values
            String customerAccountNumber;
            String poNumber ='';
            String salesOrder='';
            String claimID= '';
            Integer paginationIndexNumber = 0;
            Integer recordCount = 25;
            String claimStatus='';
            String claimStartDate='';
            String claimEndDateRange='';
            
            // Loop through the request records to extract the values
            for (Object recordObj : requestRecords) {
                Map<String, Object> record = (Map<String, Object>)recordObj;
                String keyName = (String)record.get('KeyName');
                String keyValue = (String)record.get('KeyValue');
                
                if (keyName == 'CustomerAccountNumber') customerAccountNumber = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'PONumber') poNumber = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'SalesOrder') salesOrder = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'ClaimID') claimID = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'PaginationIndexNumber') paginationIndexNumber = Integer.valueOf(keyValue);
                else if (keyName == 'RecordCount') recordCount = Integer.valueOf(keyValue);
                else if (keyName == 'ClaimStatus') claimStatus = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'ClaimStartDate') claimStartDate = keyValue.contains('null')? '':keyValue;
                else if (keyName == 'ClaimEndDateRange') claimEndDateRange = keyValue.contains('null')? '':keyValue;
            }
            
            String claimsRecordTypeId = getClaimsRecordTypeId();
            PageRecord recordInfo = new PageRecord();
            recordInfo = getPageDetails(PaginationIndexNumber,RecordCount);
            
            string  poNum = poNumber; 
            // Query to fetch cases
            String queryString = 'SELECT Id, PO_Number__c, EBS_Order__c, Subject, Description, Status, Comments, CaseNumber, EBS_Order_Number__c, Claim_Start_Date__c, Resolution_Note__c, Website_Description__c, CreatedDate FROM Case WHERE RecordTypeId = \''+claimsRecordTypeId+'\'';
            
            if (String.isNotBlank(poNumber)) {
                queryString += ' AND PO_Number__c = \''+poNumber+'\'';
            }
            if (String.isNotBlank(salesOrder)) {
                queryString += ' AND EBS_Order_Number__c =\''+salesOrder+'\'';
            }
            if (String.isNotBlank(claimID)) {
                system.debug('claimID====> '+ claimID);
                queryString += ' AND CaseNumber  =\''+claimID+'\'';
            }
            if (String.isNotBlank(customerAccountNumber)) {
                queryString += ' AND Account.Customer_Account_Number__c=\''+customerAccountNumber+'\'';
            }
            if (String.isNotBlank(ClaimStatus) && ClaimStatus.contains('New')) {
                queryString += ' AND Status IN (\'New\')';
                
            }if (String.isNotBlank(ClaimStatus) && ClaimStatus.contains('InProgress') ) {
                queryString += ' AND Status IN (\'In Progress\', \'Working\',\'Escalated\',\'Notified Customer\',\'Awaiting Response (Internal)\',\'Customer Response\',\'Response Received\') ';
                
            } else if  (String.isNotBlank(ClaimStatus) && ClaimStatus.contains('AwaitingCustomerResponse')) {
                queryString += ' AND Status IN (\'Awaiting Customer Response\', \'Awaiting Response (Customer)\') ';
                
            } else if (String.isNotBlank(ClaimStatus) && ClaimStatus.contains('Closed')) {
                queryString += ' AND Status IN (\'Closed\', \'COMPLETED-Final Comm\') ';
            }
            
            if (String.isNotBlank(claimStartDate) && String.isNotBlank(ClaimEndDateRange)) {
                queryString += ' AND Claim_Start_Date__c >= '+claimStartDate+'AND Claim_Start_Date__c <= '+ClaimEndDateRange;
                
            } else if ( String.isNotBlank(claimStartDate) && String.isBlank(ClaimEndDateRange)) {
                queryString += ' AND Claim_Start_Date__c = '+claimStartDate;
                
            }else if ( String.isBlank(claimStartDate) && String.isNotBlank(ClaimEndDateRange)) {
                queryString += ' AND Claim_Start_Date__c = '+ClaimEndDateRange;
            }
            
            queryString += ' ORDER BY CreatedDate DESC LIMIT '+ recordInfo.limitSet+' OFFSET '+recordInfo.offSet+''; //:recordCount OFFSET :paginationIndexNumber';
            
            // Execute the dynamic query
            Case [] caseList = Database.query(queryString);
            Map<Id, Case> CaseMap = new Map<Id, Case>(caseList); 
            
            // Check if caseList is empty and populate ClaimData
            if (!caseList.isEmpty()) {
                
                Map<Id,List<FileAttachment>> attachmentsInfo =  getAttachment(CaseMap.keySet()); 
                
                List<Map<String, Object>> claimDataList = new List<Map<String, Object>>();
                for (Case c : caseList) {
                    claimDataList.add(new Map<String, Object>{
                        'attachments' => attachmentsInfo.containsKey(c.id) ? attachmentsInfo.get(c.id) : new List<FileAttachment>(),
                        'ResolutionNote' => c.Resolution_Note__c,
                        'SalesforceID' => c.Id,
                        'ClaimID' => c.CaseNumber,
                        'PONumber' => c.PO_Number__c,
                        'SalesOrder' => c.EBS_Order_Number__c,
                        'Subject' => c.Subject,
                        'WebsiteDescription' => c.Website_Description__c,
                        'Comments' => c.Comments,
                        'ClaimStatus' => c.Status,
                        'SubmittedDate'=>c.CreatedDate
                    });
                }
                responseMap.put('EventResponse', new Map<String, Object>{
                    'EventBusinessID' => eventBusinessID,
                    'EventStatus' => 'SUCCESS',
                    'EventStatusMessage' => 'Successfully Completed.',
                    'ClaimData' => claimDataList
               });
            } else {
                responseMap.put('EventResponse', new Map<String, Object>{
                    'EventBusinessID' => eventBusinessID,
                        'EventStatus' => 'SUCCESS',
                        'EventStatusMessage' => 'No records found.',
                        'ClaimData' => null
                        });
            }
            
            // Set the response
            res.statusCode = 200;
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            
        } catch (Exception e) {
            // Prepare error response
            responseMap.put('EventResponse', new Map<String, Object>{
                'EventBusinessID' => null,
                    'EventStatus' => 'FAILURE',
                    'EventStatusMessage' => 'An error occurred: ' + e.getMessage()
                    });
            
            res.statusCode = 500;
            res.addHeader('Content-Type', 'application/json');
            ApexLogUtill.createApexLog('Getclaimwebservice.handleClaimRetrieval', 'responseMap' , e.getMessage(), null, 'Case', e.getMessage(), res.statusCode);
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        }
    }
    
    private static String getClaimsRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Claims' LIMIT 1];
        return rt != null ? rt.Id : null;
    }
    
    public static Map<Id,List<FileAttachment>> getAttachment(Set<Id> caseIds){
        System.debug('==========='+caseIds);
        Map<Id,List<fileattachment>> attachments = new Map<Id,List<fileattachment>>();
        for(ContentDocumentLink file : [
            SELECT 
            	ContentDocument.Id, ContentDocument.Title, ContentDocument.Description, ContentDocument.FileType, LinkedEntityId  
            FROM 
            	ContentDocumentLink 
            WHERE 
            LinkedEntityId =: caseIds AND 
            ContentDocument.Title != null  AND 
             ContentDocument.FileType != null AND 
             ContentDocument.Description != null
        ]){
            System.debug('==========='+file);
           
            System.debug('=====file.ContentDocument.FileType======'+file.ContentDocument.FileType);
            System.debug('=====file.ContentDocument.Description======'+file.ContentDocument.Description);
            
            FileAttachment fileInfo = new FileAttachment();
             
            fileInfo.filename = String.valueOf(file.ContentDocument.Title).trim();
            fileInfo.fileType = String.valueOf(file.ContentDocument.FileType).trim();
            fileInfo.fileurl =  String.valueOf(file.ContentDocument.Description).trim();
            
            if(attachments.containsKey(file.LinkedEntityId)){
                attachments.get(file.LinkedEntityId).add(fileInfo); 
            }else{
                attachments.put(file.LinkedEntityId,new List<fileattachment>{fileInfo}); 
                
            } 
            
        }
        return attachments;
        
    }
    
    public static PageRecord getPageDetails(Integer indexNumber, Integer recordCount){
        
        Integer startNumber = (indexNumber * recordCount) - recordCount;
        PageRecord recordInfo = new PageRecord();
        if(startNumber <= 2000){
            recordInfo.offset = startNumber;
            recordInfo.limitSet = recordCount;    
        }else{
            recordInfo.offset = 2000;
            recordInfo.limitSet = 50000;
        } 
        
        return recordInfo;
        
    }
    
    public class PageRecord{
        public Integer offSet;
        public Integer limitSet;
        
        public PageRecord(){
            this.offset  = 0;
            this.limitSet = 50000;
        }
    }
    
    public class FileAttachment{
        public String filename;
        public String fileType;
        public String fileurl;
        
        public FileAttachment(){
            this.filename = '';
            this.fileType = '';
            this.fileurl = '';
        }
    }
    
}