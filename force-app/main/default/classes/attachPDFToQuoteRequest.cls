/**
 * @description       : 
 * @author            : Sandeep Reddy
 * @group             : 
 * @last modified on  : 12-19-2022
 * @last modified by  : Sandeep Reddy
**/
public class attachPDFToQuoteRequest {
    private final Quote_Request__c QRequest; //Account object
    public string recordId;
    public Quote_Request__c QuoteRequestDetails{get;set;}
  //  public AccountTeamMember atm{get;set;}
    public Account acnt{get;set;}
    
    //constructor extension
    public attachPDFToQuoteRequest(ApexPages.StandardController standardPageController) {
        
        QRequest = (Quote_Request__c)standardPageController.getRecord(); //instantiate the Quote_Request__c object for the current record
        
    }
    
    //constructor
    public attachPDFToQuoteRequest() {
        
        // fetch the record id from the url then do soql and fetch out the quote detals on the basis of record id 
        string  recordId = apexpages.currentpage().getparameters().get('Recordid');
        QuoteRequestDetails = [SELECT Name,Imprint_Location__c,Imprint_Colors__c,Imprint_Method__c,Program_Manager__r.name,Program_Manager__r.Email,Program_Manager__r.Phone,Account__r.Primary_Team_Member2__r.name, Quote_Number__c, Account__c, Production_Site__c, Assigned_To__r.Name, Account__r.Primary_Team_Member2__c,
                               Account__r.Name, Account__r.AccountNumber, Account__r.Currency__c, Account__r.EBS_Num__c, Account__r.ShippingStreet,
                               Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingPostalCode, Account__r.ShippingCountry,
                               Contact__r.Name, Contact__r.Email, Opportunity__r.Name, Valid_Through__c, Quote_Request_Closed_Date__c,
                               (SELECT Id,Imprint_Location__c,Number_of_Imprint_Colors__c,Imprint_Method__c, Name, Calendar_Size__c,Style_Number_of_Sheets__c, Binding__c,
                                Artwork__c,Price__c, Grid__c, Printing__c, Description__c,
                                Proofs__c, Production_Lead_Time__c, Quantity__c,Additional_Quantities__c,Additional_Quantities_2__c,Additional_Quantities_3__c,Additional_Qty_1_Price__c,Additional_Qty_2_Price__c,Additional_Qty_3_Price__c, Ships_From__c, 
                                Misc_Comments__c, Packing_approx__c, Sample_Lead_Time__c, Ocean_Transit__c,
                                Products__r.Name, Products__r.Product_ID__c
                                FROM Quote_Products__r)
                               FROM Quote_Request__c WHERE Id=:recordId];

        /*acnt = [SELECT Name, AccountNumber, Currency__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry 
                FROM Account WHERE Id =: QuoteRequestDetails.Account__c];
        ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry
        
        system.debug('Account Address1 ---> '+acnt.ShippingCity);
        system.debug('Account Address2 ---> '+acnt.ShippingStreet);*/
        
      /*  if(!test.isRunningTest()){
            atm = [SELECT Id, AccountId, UserId, User.Name, User.Email, TeamMemberRole FROM AccountTeamMember Where 
                   AccountId =: QuoteRequestDetails.Account__c AND TeamMemberRole = 'Program Manager'];
        }*/
          
    }
    
    @AuraEnabled
    public static void attachPDF(string recordId,String Type) {
        
        set<string> documentidset = new set<string>();
        list<ContentDocumentLink> ContentDocumentLinkList =[select id,contentdocumentid from ContentDocumentLink where LinkedEntityId =:recordId];
        if(!ContentDocumentLinkList.isempty()){
             for(ContentDocumentLink CDL : ContentDocumentLinkList){
            documentidset.add(CDL.contentdocumentid);
        }
        }
       
        string Condition = '';
        //generate and attach the PDF document
        Blob pdfBlob; //create a blob for the PDF content
        if(Type =='Calendar'){
            Condition = 'Calendar%';
            PageReference pdfPage = Page.Calendar_Quote_PDF;
            System.debug('pdfPage : '+pdfPage);
             
            pdfPage.getParameters().put('Recordid',recordId);
            
            if (!Test.isRunningTest()) {
                pdfBlob = pdfPage.getContent(); //generate the pdf blob
            } else { 
                pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
            }
        }
        else{
            Condition ='HS_Quote%';
            PageReference pdfPage = Page.HS_Quote_PDF; 
            pdfPage.getParameters().put('Recordid',recordId);
            
            if (!Test.isRunningTest()) { 
                pdfBlob = pdfPage.getContent(); //generate the pdf blob
            } else { 
                pdfBlob = Blob.valueOf('Some Text for a boring PDF file...');
            }
            
        }
        //  Attachment attach = new Attachment(parentId = recordId, Name = DocName, body = pdfBlob); //create the attachment object
        //insert attach; //insert the attachment
        List<ContentVersion> contentVersionList = new List<ContentVersion> ();
        if(documentidset !=null){
                     contentVersionList = [SELECT Id, Title, ContentDocumentId 
                                                   FROM ContentVersion WHERE ContentDocumentId IN :documentidset and title like:Condition];
        }

        Integer Version =contentVersionList.size() + 1;
        String DocName = Type+'Quote_Version'+Version+'.pdf';
        
        ContentVersion contentVersion_1 = new ContentVersion(
            Title=DocName, 
            PathOnClient =DocName,
            VersionData = pdfBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = recordId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }
    
}