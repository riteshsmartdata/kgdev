public class CloneQuoteRequestController {
    
    @AuraEnabled
    public static String createQuoteRequest(Map<String, Object> quoteRequestProxy, Id recordId, String recordTypeId)
    {
        
        Id quoteRequestCustomRecordTypeId = Schema.SObjectType.Quote_Request__c.getRecordTypeInfosByName().get('Custom Calendar').getRecordTypeId();
        Id quoteRequestNonRecordTypeId = Schema.SObjectType.Quote_Request__c.getRecordTypeInfosByName().get('Non-Calendar').getRecordTypeId();
        Id quoteProductCustomRecordTypeId = Schema.SObjectType.Quote_Product__c.getRecordTypeInfosByName().get('Custom Calendar').getRecordTypeId();
        Id quoteProductNonRecordTypeId = Schema.SObjectType.Quote_Product__c.getRecordTypeInfosByName().get('Non-Calendar').getRecordTypeId();
        
        System.debug('Custom Rec Id ===> '+quoteRequestCustomRecordTypeId);
        System.debug('Non Rec Id ===> '+quoteRequestNonRecordTypeId);
        //System.debug('Assigned to ===> '+assignedTo);
        System.debug('<=== Before QR Insert ===>');

        String assignedTo =  (String)QuoteRequestProxy.get('Assigned_To__c');
        String opportunity =  (String)QuoteRequestProxy.get('Opportunity__c');
        
        system.debug('opportunity@@@@'+opportunity);
        Quote_Request__c qr = new Quote_Request__c();
     //   qr.Previous_Quote_Number__c = (String)QuoteRequestProxy.get('Previous_Quote_Number__c');
        qr.Previous_Quote_Number__c = recordId;
        qr.Account__c = (String)QuoteRequestProxy.get('Account__c');
        if (opportunity !=null && opportunity.length() > 15)
        {
            qr.Opportunity__c = opportunity;
        }
        qr.Project_Name__c = (String)QuoteRequestProxy.get('Project_Name__c');
        qr.Contact__c = (String)QuoteRequestProxy.get('Contact__c');
        qr.Additional_Files_or_Images__c = (Boolean)QuoteRequestProxy.get('Additional_Files_or_Images__c');
        qr.Production_Site__c = (String)QuoteRequestProxy.get('Production_Site__c');
        qr.Product_Type__c = (String)QuoteRequestProxy.get('Product_Type__c');
        if(assignedTo != null && assignedTo.length() > 3)
        {
            qr.Assigned_To__c = assignedTo;
        }
        qr.Stage__c = (String)QuoteRequestProxy.get('Stage__c');
        qr.Status__c = (String)QuoteRequestProxy.get('Status__c');
        qr.Quote_Amount__c = (Decimal)QuoteRequestProxy.get('Quote_Amount__c');
        qr.Price_Point__c = (Decimal)QuoteRequestProxy.get('Price_Point__c');
        qr.Competitor_Price__c = (Decimal)QuoteRequestProxy.get('Competitor_Price__c');
        qr.Currency__c = (String)QuoteRequestProxy.get('Currency__c');
        system.debug('Before Record Type Line');
        if(recordTypeId == quoteRequestCustomRecordTypeId)
        {
            qr.Program_Manager__c = (String)QuoteRequestProxy.get('Program_Manager__c');
            qr.Quote_Request_Type__c = 'Custom Calendar';
        }
        qr.RecordTypeId = recordTypeId;
        //qr.In_Hands_Date_Event_Date__c = (Date)QuoteRequestProxy.get('In_Hands_Date_Event_Date__c');
        insert qr;
        
        
        system.debug('After Quote Request Insertion');
        
        List<Quote_Product__c> quoteProducts = [SELECT Id, Name, Quote_Request__c, RecordTypeId, Products__c, Calendar_Year__c, Description__c,
                                                Calendar_Size__c, Style_Number_of_Sheets__c, Binding__c, Artwork__c, Grid__c, Printing__c, 
                                                Same_Ad_on_All__c, Quantity__c, Additional_Quantities__c, Additional_Quantities_2__c, 
                                                Additional_Quantities_3__c, Additional_Information__c, Price_Point__c, Imprint_Location__c, 
                                                Imprint_Method__c, Number_of_Imprint_Colors__c, Addt_l_Comments__c
                                                FROM Quote_Product__c
                                                WHERE Quote_Request__c =: recordId];  
        
        System.debug('Quote Products Size'+quoteProducts.size());
        
        List<Quote_Request__c> QuoteRequestClone = [SELECT Id, Name, RecordTypeId, Account__c, Opportunity__c, Contact_Email__c FROM Quote_Request__c WHERE Id =: qr.Id];
        
        System.debug('Quote Request Clone ==> '+QuoteRequestClone);
        
        List<Quote_Product__c> clonedQuoteProducts = new List<Quote_Product__c>();
        
        if(quoteProducts.size()>0)
        {
            
            for (Quote_Product__c originalQuoteProduct : quoteProducts) 
            {
                
                Quote_Product__c clonedQuoteProduct = new Quote_Product__c();
                clonedQuoteProduct.Quote_Request__c 			= QuoteRequestClone[0].Id;
                clonedQuoteProduct.Products__c 					= originalQuoteProduct.Products__c;
                clonedQuoteProduct.Quantity__c 					= originalQuoteProduct.Quantity__c;
                clonedQuoteProduct.Additional_Quantities__c 	= originalQuoteProduct.Additional_Quantities__c;
                clonedQuoteProduct.Additional_Quantities_2__c	= originalQuoteProduct.Additional_Quantities_2__c;
                clonedQuoteProduct.Additional_Quantities_3__c	= originalQuoteProduct.Additional_Quantities_3__c;
                clonedQuoteProduct.Additional_Information__c	= originalQuoteProduct.Additional_Information__c;
                clonedQuoteProduct.Addt_l_Comments__c 			= originalQuoteProduct.Addt_l_Comments__c;
                
                if(recordTypeId == quoteRequestCustomRecordTypeId)
                {
                    
                    if(originalQuoteProduct.RecordTypeId == quoteProductCustomRecordTypeId)
                    {
                        
                        clonedQuoteProduct.Calendar_Year__c 			= originalQuoteProduct.Calendar_Year__c;
                        clonedQuoteProduct.Description__c 				= originalQuoteProduct.Description__c;
                        clonedQuoteProduct.Calendar_Size__c 			= originalQuoteProduct.Calendar_Size__c;
                        clonedQuoteProduct.Style_Number_of_Sheets__c 	= originalQuoteProduct.Style_Number_of_Sheets__c;
                        clonedQuoteProduct.Binding__c 					= originalQuoteProduct.Binding__c;
                        clonedQuoteProduct.Artwork__c 					= originalQuoteProduct.Artwork__c;
                        clonedQuoteProduct.Grid__c 						= originalQuoteProduct.Grid__c;
                        clonedQuoteProduct.Printing__c 					= originalQuoteProduct.Printing__c;
                        clonedQuoteProduct.Same_Ad_on_All__c 			= originalQuoteProduct.Same_Ad_on_All__c;
                        clonedQuoteProduct.RecordTypeId                 = originalQuoteProduct.RecordTypeId;
                        
                    }
                }
                else if(recordTypeId == quoteRequestNonRecordTypeId)
                {
                    
                    if(originalQuoteProduct.RecordTypeId == quoteProductNonRecordTypeId)
                    {
                        
                        clonedQuoteProduct.Price_Point__c 				= originalQuoteProduct.Price_Point__c;
                        clonedQuoteProduct.Imprint_Location__c 			= originalQuoteProduct.Imprint_Location__c;
                        clonedQuoteProduct.Imprint_Method__c 			= originalQuoteProduct.Imprint_Method__c;
                        clonedQuoteProduct.Number_of_Imprint_Colors__c 	= originalQuoteProduct.Number_of_Imprint_Colors__c;
                        clonedQuoteProduct.RecordTypeId                 = originalQuoteProduct.RecordTypeId;
                    }
                }
                
                clonedQuoteProducts.add(clonedQuoteProduct);
            }
            
        }
        
        System.debug('Cloned Quote Products Size ===> '+clonedQuoteProducts.size());
        
        if(clonedQuoteProducts.size()>0)
        {
            insert clonedQuoteProducts;
        }
        
        return QuoteRequestClone[0].Name;
        
    }
    
}