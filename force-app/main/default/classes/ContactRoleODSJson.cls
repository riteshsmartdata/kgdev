/**
* @description       : 
* @author            : Ritesh Kumar
* @group             : 
* @last modified on  : 01-31-2024
* @last modified by  : Ritesh Kumar
* Modifications Log
* Ver   Date         Author         Modification
* 1.0   08-25-2023   Ritesh Kumar   JIRA SF-986
**/
public without sharing class ContactRoleODSJson {
    /**
* Method is used to genrate JSON.
*/
    
    final static Integer TIMEOUT = 120000;
    
    public static Apex_Errors__c syncContactRoleODS(Contact_Roles__c contactRoleRecord, Contact_And_Contact_Role_Settings__mdt apiSetting){ 
        Apex_Errors__c errorRecord  = new Apex_Errors__c();
        Set<Integer> successStatuCode = new Set<Integer>();
        successStatuCode.add(200);
        successStatuCode.add(201); 
        String endpoint = apiSetting.End_Point__c; 
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        endpoint += 'action/replaceOne'; 
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json');
        request.setHeader('api-key', apiSetting.API_Key__c);  
        String requestBody = ''+contactRoleJSON(contactRoleRecord, apiSetting);
        request.setBody(requestBody);
        
        request.setTimeout(TIMEOUT);
        HttpResponse response = http.send(request);
        System.debug('========= End Point ======='+endpoint);
        System.debug('========= Request ======='+requestBody);
        System.debug('========= Status Code ======='+response.getStatusCode());
        System.debug('========= Response ======='+response.getBody());
        
        if(!successStatuCode.contains(response.getStatusCode())){  
            errorRecord = ApexLogUtill.assignApexLog('ODS : Contact Role Sync', requestBody, response.getBody(), contactRoleRecord.Id, 'Contact_Roles__c', response.getBody(), response.getStatusCode());
        }
        
        return errorRecord;
    }
    
    private static JSONGenerator writeField(String fieldKey, String fieldValue, JSONGenerator gen){ 
        if(fieldValue != null){
            gen.writeStringField(fieldKey, fieldValue);
        }else{
            gen.writeNullField(fieldKey);
        }
        
        return gen;
    }
    
    private static JSONGenerator witeDateField(String fieldKey, DateTime fieldValue, JSONGenerator gen){
        if(fieldValue != null){
            gen.writeFieldName(fieldKey);
            gen.writeStartObject();
            gen.writeFieldName('$date');
            gen.writeStartObject();
            gen.writeStringField('$numberLong', String.valueOf(fieldValue.getTime()));
            gen.writeEndObject();
            gen.writeEndObject();
        }else{
            gen.writeNullField(fieldKey);
        }
        
        return gen;
    }
    
    private static String contactRoleJSON(Contact_Roles__c contactRoleRecord,  Contact_And_Contact_Role_Settings__mdt apiSetting){ 
        Boolean flag = true;
        JSONGenerator gen = JSON.createGenerator(flag);
        if(contactRoleRecord != null){  
            gen.writeStartObject();
            gen.writeStringField('dataSource', apiSetting.Data_Source__c);
            gen.writeStringField('database', apiSetting.Database__c);
            gen.writeStringField('collection',apiSetting.Collection__c);
            gen.writeFieldName('filter');
            gen.writeStartObject();   
            gen = writeField('recordId',contactRoleRecord.Id,gen); 
            gen.writeEndObject();
            gen.writeFieldName('replacement');
            gen.writeStartObject(); 
            gen = writeField('recordId',contactRoleRecord.Id,gen);
            gen = writeField('accountName',contactRoleRecord.Account__c,gen);
            gen = writeField('contactRoleName', contactRoleRecord.Name, gen); 
            gen = writeField('createdBy', contactRoleRecord.CreatedById, gen);
            if(contactRoleRecord.Primary__c != null){
                gen.writeBooleanField('primary', contactRoleRecord.Primary__c);
            }else{
                gen.writeNullField('primary');
            }
            gen = writeField('lastModifiedBy',contactRoleRecord.LastModifiedById,gen);
            gen = writeField('responsibilityType',contactRoleRecord.Contact_Role_Name__c,gen);
            gen = witeDateField('lastModifiedDate', contactRoleRecord.LastModifiedDate, gen);
            gen = writeField('accountNo',contactRoleRecord.Customer_Account_Number__c,gen);
            gen = writeField('salesforceId',contactRoleRecord.Contact__c,gen); 
            gen = witeDateField('ODSLastModifiedDate', contactRoleRecord.LastModifiedDate, gen);             
            gen.writeEndObject(); 
            gen.writeBooleanField('upsert',true);
            gen.writeEndObject(); 
        }  
        return gen.getAsString();
    } 
}