/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class FreightQuoteRequest {
    public static JSONGenerator quoteRequest(
        String customerAccountNumber,
        String itemNumber,
        String quantity,
        String zipCode 
    ) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('data');
        gen.writeStartObject();
        gen.writeStringField('customerAccountNumber', customerAccountNumber != null ? customerAccountNumber : '');
        gen.writeFieldName('request');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('item_number', itemNumber != null ? itemNumber : '');
        gen.writeStringField('quantity', quantity != null ? quantity : '');
        gen.writeStringField('currency_code', DataCloudConstants.CURRENCY_USD);
        gen.writeStringField('packing_option', DataCloudConstants.PACKING_OPTION_STANDARD);
        gen.writeFieldName('ship_to');
        gen.writeStartObject();
        gen.writeStringField('city','');
        gen.writeStringField('state', KoozieUtility.getZipCode(zipCode) != null ? KoozieUtility.getZipCode(zipCode).State_Abbre__c : '' );
        gen.writeStringField('zip_code', zipCode != null ? zipCode : '');
        gen.writeStringField('country', KoozieUtility.getZipCode(zipCode) != null ? KoozieUtility.getZipCode(zipCode).Country_Abbre__c : DataCloudConstants.COUNTRY_US);
        gen.writeBooleanField('isResidentialFlag', DataCloudConstants.RESIDENTIAL_FLAG_FALSE);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();
        System.debug(LoggingLevel.INFO, '====== Request Payload ======' + gen.getAsString());
        return gen;
    }
}