/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 09-27-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
public without sharing class WebsiteAccountJSON {

    final static String CUSTOMER_ACCOUNT = 'CUSTOMERACCOUNT';
    final static String EVENT_SOURCE_SYSTEM = 'Salesforce';

    public static JSONGenerator accountRequest(String accountId, String dmlType){ 
        Account accountRecord = [ 
            SELECT 
				Id, ShippingPostalCode, ShippingCountry, ShippingState, ShippingCity,ShippingStreet, BillingPostalCode, 
				BillingCountry, BillingState, BillingCity, BillingStreet,Primary_Sales_Rep_Region__c,Primary_Team_Member_Email__c, 
				Primary_Team_Member2__r.Name, Primary_Team_Member2__c, Koozie_Group_Tracker_Link__c, Account_Domain__c, 
				Name , Customer_Account_Number__c, Web_Id__c, CreatedDate, ASI_Number__c, PPAI_Number__c, Status__c,Restrict_Pricing__c
            FROM Account
            WHERE Id=: accountId
            LIMIT 1
        ];
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('EventRequest');
        gen.writeStartObject(); 
        
        if(String.isNotBlank(accountRecord.Customer_Account_Number__c)){
            gen.writeStringField('EventBusinessID',accountRecord.Customer_Account_Number__c);  
        }else{
            gen.writeNullField('EventBusinessID');
        } 
        
        if(accountRecord.CreatedDate != null){
            gen.writeDateTimeField('EventDateTime', accountRecord.CreatedDate);
        }else{
            gen.writeNullField('EventObject');
        }
        
        gen.writeStringField('EventObject',CUSTOMER_ACCOUNT );  
                
        gen.writeStringField('EventSourceSystem',EVENT_SOURCE_SYSTEM); 
        
        if(String.isNotBlank(dmlType)){
            gen.writeStringField('EventType',dmlType);  
        }else{
            gen.writeNullField('EventType');
        } 
        
        gen.writeFieldName('AccountData');
        gen.writeStartObject(); 

        if(String.isNotBlank(accountRecord.Id)){
            gen.writeStringField('sf_Id', accountRecord.Id);
        }else{
            gen.writeNullField('sf_Id');
        }
        
        if(String.isNotBlank(accountRecord.Web_Id__c)){
            gen.writeStringField('web_Id', accountRecord.Web_Id__c);
        }else{
            gen.writeNullField('web_Id');
        }

        if(String.isNotBlank(accountRecord.Customer_Account_Number__c)){
            gen.writeStringField('accountNumber', accountRecord.Customer_Account_Number__c);
        }else{
            gen.writeNullField('accountNumber');
        }

        if(String.isNotBlank(accountRecord.Name)){
            gen.writeStringField('accountName', accountRecord.Name);
        }else{
            gen.writeNullField('accountName');
        }

        if(String.isNotBlank(accountRecord.Account_Domain__c)){
            gen.writeStringField('accountDomain', accountRecord.Account_Domain__c);
        }else{
            gen.writeNullField('accountDomain');
        }
        
        if(String.isNotBlank(accountRecord.Koozie_Group_Tracker_Link__c )){
            gen.writeStringField('koozieGroupTrackerLink', accountRecord.Koozie_Group_Tracker_Link__c );
        }else{
            gen.writeNullField('koozieGroupTrackerLink');
        }
        
        if(String.isNotBlank(accountRecord.Primary_Team_Member2__c )){
            gen.writeStringField('primaryTeamMemberId', accountRecord.Primary_Team_Member2__c );
        }else{
            gen.writeNullField('primaryTeamMemberId');
        }
        
        if(String.isNotBlank(accountRecord.Primary_Team_Member2__r.Name )){
            gen.writeStringField('primaryTeamMemberName', accountRecord.Primary_Team_Member2__r.Name );
        }else{
            gen.writeNullField('primaryTeamMemberName');
        }
        
        if(String.isNotBlank(accountRecord.Primary_Team_Member_Email__c )){
            gen.writeStringField('primaryTeamMemberEmail', accountRecord.Primary_Team_Member_Email__c );
        }else{
            gen.writeNullField('primaryTeamMemberEmail');
        }
        
        if(String.isNotBlank(accountRecord.Primary_Sales_Rep_Region__c )){
            gen.writeStringField('primarySalesRep', accountRecord.Primary_Sales_Rep_Region__c );
        }else{
            gen.writeNullField('primarySalesRep');
        }

		if(String.isNotBlank(accountRecord.ASI_Number__c )){
            gen.writeStringField('ASINumber', accountRecord.ASI_Number__c );
        }else{
            gen.writeNullField('ASINumber');
        }

		if(String.isNotBlank(accountRecord.PPAI_Number__c )){
            gen.writeStringField('PPAINumber', accountRecord.PPAI_Number__c );
        }else{
            gen.writeNullField('PPAINumber');
        }
                 
        gen.writeBooleanField('RestrictPricing', accountRecord.Restrict_Pricing__c);
        
		if(String.isNotBlank(accountRecord.Status__c )){
            gen.writeStringField('isActive', accountRecord.Status__c == 'Active' ? 'true' : 'false' );
        }

        gen.writeFieldName('BillingAddress');
        gen.writeStartObject(); 
        if(String.isNotBlank(accountRecord.BillingStreet )){
            gen.writeStringField('street', accountRecord.BillingStreet );
        }else{
            gen.writeNullField('street');
        }
        
        if(String.isNotBlank(accountRecord.BillingCity )){
            gen.writeStringField('city', accountRecord.BillingCity );
        }else{
            gen.writeNullField('city');
        }
        
        if(String.isNotBlank(accountRecord.BillingState )){
            gen.writeStringField('State', accountRecord.BillingState );
        }else{
            gen.writeNullField('state');
        }
        
        if(String.isNotBlank(accountRecord.BillingCountry )){
            gen.writeStringField('country', accountRecord.BillingCountry );
        }else{
            gen.writeNullField('country');
        }
        
        if(String.isNotBlank(accountRecord.BillingPostalCode )){
            gen.writeStringField('postalCode', accountRecord.BillingPostalCode );
        }else{
            gen.writeNullField('postalCode');
        }
        
        gen.writeEndObject();
        
        gen.writeFieldName('ShippingAddress');
        gen.writeStartObject(); 
        if(String.isNotBlank(accountRecord.ShippingStreet )){
            gen.writeStringField('street', accountRecord.ShippingStreet );
        }else{
            gen.writeNullField('street');
        }
        
        if(String.isNotBlank(accountRecord.ShippingCity )){
            gen.writeStringField('city', accountRecord.ShippingCity );
        }else{
            gen.writeNullField('city');
        }
        
        if(String.isNotBlank(accountRecord.ShippingState )){
            gen.writeStringField('State', accountRecord.ShippingState );
        }else{
            gen.writeNullField('state');
        }
        
        if(String.isNotBlank(accountRecord.ShippingCountry )){
            gen.writeStringField('country', accountRecord.ShippingCountry );
        }else{
            gen.writeNullField('country');
        }
        
        if(String.isNotBlank(accountRecord.ShippingPostalCode )){
            gen.writeStringField('postalCode', accountRecord.ShippingPostalCode );
        }else{
            gen.writeNullField('postalCode');
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        System.debug('==== Account JSON ===='+gen.getAsString());
        return gen;
    }

}