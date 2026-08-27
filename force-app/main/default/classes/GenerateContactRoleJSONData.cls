/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 01-31-2024
 * @last modified by  : Ritesh Kumar
**/
public class GenerateContactRoleJSONData {
    
   @future(callout=true)
    public static void sendContactRoleInformation( String  jsonData, String crudMode){ 

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');

        System.debug('====== future sendContactRoleInformation===== '); 
         
        String endpoint = API_SETTING.End_Point__c;
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(crudMode == 'UPDATE'){
            endpoint += 'action/updateOne';
        }else if(crudMode == 'INSERT'){
            endpoint += 'action/insertOne';
        }
        system.debug('======endpoint===='+endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        request.setHeader('api-key', API_SETTING.API_Key__c); 
        request.setHeader('User-agent', 'Salesforce-integration-client');
        request.setHeader('Authorization','Bearer');
        request.setBody(jsonData);
        request.setTimeout(120000);
        
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        System.debug('===== Response Body ======: '+response.getBody());
        System.debug('===== Status Code ======: '+response.getStatusCode());    
        System.debug('===== response ======: '+response );    
        System.debug('===== Insert JSON ======: '+jsonData );    
    }

    public static void sendContactRoleData( String  jsonData, String crudMode){ 

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');

        System.debug('====== future sendContactRoleInformation===== '); 

        String endpoint = API_SETTING.End_Point__c;
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if(crudMode == 'UPDATE'){
            endpoint += 'action/updateOne';
        }else if(crudMode == 'INSERT'){
            endpoint += 'action/insertOne';
        }
        system.debug('======endpoint===='+endpoint);

        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        request.setHeader('api-key', API_SETTING.API_Key__c); 
        request.setHeader('User-agent', 'Salesforce-integration-client');
        request.setHeader('Authorization','Bearer');
        request.setBody(jsonData);
        request.setTimeout(120000);
        
        // Set the body as a JSON object
        HttpResponse response = http.send(request);
        System.debug('===== Response Body ======: '+response.getBody());
        System.debug('===== Status Code ======: '+response.getStatusCode());    
        System.debug('===== response ======: '+response );    
        System.debug('===== Insert JSON ======: '+jsonData );    
    }


    public static String insertManyContactRoleJSON(Contact_Roles__c contactRoleRecord){

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');

        JSONGenerator gen = JSON.createGenerator(true);
        if(contactRoleRecord != null){

            System.debug('===== Contact Role ====== ' +contactRoleRecord);

            gen.writeStartObject();
            gen.writeStringField('dataSource', API_SETTING.Data_Source__c);
            gen.writeStringField('database', API_SETTING.Database__c);
            gen.writeStringField('collection', API_SETTING.Collection__c);
            gen.writeFieldName('document');
            gen.writeStartObject(); 

            gen.writeStringField('recordId', contactRoleRecord.Id);

            if(contactRoleRecord.Account__c != null){
                gen.writeStringField('accountName', contactRoleRecord.Account__c);
            }else{
                gen.writeNullField('accountName');
            }

            if(contactRoleRecord.Name != null){
                gen.writeStringField('contactRolesName', contactRoleRecord.Name);
            }else{
                gen.writeNullField('contactRolesName');
            }
            if(contactRoleRecord.CreatedById != null){
                gen.writeStringField('createdBy', contactRoleRecord.CreatedById);
            }else{
                gen.writeNullField('createdBy');
            }
            if(contactRoleRecord.Primary__c != null){
                gen.writeBooleanField('primary', contactRoleRecord.Primary__c);
            }else{
                gen.writeNullField('primary');
            }
            if(contactRoleRecord.LastModifiedById != null){
                gen.writeStringField('lastModifiedBy', contactRoleRecord.LastModifiedById);
            }else{
                gen.writeNullField('lastModifiedBy');
            }
            if(contactRoleRecord.Contact_Role_Name__c != null){
                gen.writeStringField('responsibilityType', contactRoleRecord.Contact_Role_Name__c);
            }else{
                gen.writeNullField('responsibilityType');
            }
            if(contactRoleRecord.LastModifiedDate != null){
                gen.writeDateTimeField('lastModifiedDate', contactRoleRecord.LastModifiedDate);
            }else{
                gen.writeNullField('lastModifiedDate');
            }
            if(contactRoleRecord.Customer_Account_Number__c != null){
                gen.writeStringField('accountNo', contactRoleRecord.Customer_Account_Number__c);
            }else{
                gen.writeNullField('accountNo');
            }
            if(contactRoleRecord.Contact__c != null){
                gen.writeStringField('salesforceId', contactRoleRecord.Contact__c); //Field does not exist on the object 
            }else{
                gen.writeNullField('salesforceId');
            }
            if(contactRoleRecord.LastModifiedDate != null){
                gen.writeDateTimeField('ODSLastModifiedDate', contactRoleRecord.LastModifiedDate); 
            }else{
                gen.writeNullField('ODSLastModifiedDate');
            }
            if(contactRoleRecord.CreatedDate != null){
                gen.writeDateTimeField('createdDate', contactRoleRecord.CreatedDate);
            }else{
                gen.writeNullField('createdDate');
            }
            gen.writeEndObject();
            gen.writeEndObject();
        }
        System.debug('======== Insert JSON ======== ' +gen.getAsString()); 
        return gen.getAsString();

    }
    

    public static String UpdateoneContactRoleJSON(Contact_Roles__c contactRoleRecord, Set<String> contactRoleFields){

        Contact_And_Contact_Role_Settings__mdt API_SETTING = Contact_And_Contact_Role_Settings__mdt.getInstance('Send_Contact_Role_Information');

        JSONGenerator gen = JSON.createGenerator(true);
        if(contactRoleRecord != null){

            System.debug('===== Contact Role ====== ' +contactRoleRecord);

            gen.writeStartObject();
            gen.writeStringField('dataSource', API_SETTING.Data_Source__c);
            gen.writeStringField('database', API_SETTING.Database__c);
            gen.writeStringField('collection', 'ContactRole');

            gen.writeFieldName('filter');
            gen.writeStartObject();
            if(contactRoleRecord.Contact__c != null){
                gen.writeStringField('salesforceId', contactRoleRecord.Contact__c);
            }else{
                gen.writeNullField('salesforceId');
            }
            
            gen.writeEndObject();

            gen.writeFieldName('update');
            gen.writeStartObject();

            gen.writeFieldName('$set');
            gen.writeStartObject();

            if(contactRoleRecord.Id != null){
                gen.writeStringField('recordId', contactRoleRecord.Id);
            }else{
                gen.writeNullField('recordId');
            }

            

            if(contactRoleRecord.Account__c != null && contactRoleFields.contains('Account__c')){
                gen.writeStringField('accountName', contactRoleRecord.Account__c);
            }else if(contactRoleRecord.Account__c == null && contactRoleFields.contains('Account__c')){
                gen.writeNullField('accountName');
            } 

            if(contactRoleRecord.Primary__c != null && contactRoleFields.contains('Primary__c')){
                gen.writeBooleanField('primary', contactRoleRecord.Primary__c);
            }else if(contactRoleRecord.Primary__c == null && contactRoleFields.contains('Primary__c')){
                gen.writeNullField('primary');
            }

            if(contactRoleRecord.LastModifiedById != null && contactRoleFields.contains('LastModifiedById')){
                gen.writeStringField('lastModifiedBy', contactRoleRecord.LastModifiedById);
            }else if(contactRoleRecord.LastModifiedById == null && contactRoleFields.contains('LastModifiedById')){
                gen.writeNullField('lastModifiedBy');
            }

            if(contactRoleRecord.Contact_Role_Name__c != null && contactRoleFields.contains('Contact_Role_Name__c')){
                gen.writeStringField('responsibilityType', contactRoleRecord.Contact_Role_Name__c);
            }else if(contactRoleRecord.Contact_Role_Name__c == null && contactRoleFields.contains('Contact_Role_Name__c')){
                gen.writeNullField('responsibilityType');
            }

            /*
            if(contactRoleRecord.LastModifiedDate != null && contactRoleFields.contains('LastModifiedDate')){
                gen.writeDateTimeField('lastModifiedDate', contactRoleRecord.LastModifiedDate);
            }else if(contactRoleRecord.LastModifiedDate == null && contactRoleFields.contains('LastModifiedDate')){
                gen.writeNullField('lastModifiedDate');
            }
            */
            System.debug('========= contactRoleRecord.LastModifiedDate =====: '+contactRoleRecord.LastModifiedDate);
            gen.writeDateTimeField('lastModifiedDate', contactRoleRecord.LastModifiedDate);

            if(contactRoleRecord.Customer_Account_Number__c != null && contactRoleFields.contains('Customer_Account_Number__c')){
                gen.writeStringField('accountNo', contactRoleRecord.Customer_Account_Number__c);
            }else if(contactRoleRecord.Customer_Account_Number__c == null && contactRoleFields.contains('Customer_Account_Number__c')){
                gen.writeNullField('accountNo');
            }
 

           /*
            if(contactRoleRecord.LastModifiedDate != null && contactRoleFields.contains('LastModifiedDate')){
                gen.writeDateTimeField('ODSLastModifiedDate', contactRoleRecord.LastModifiedDate);     
            }else if(contactRoleRecord.LastModifiedDate == null && contactRoleFields.contains('LastModifiedDate')){
                gen.writeNullField('ODSLastModifiedDate');
            }
            */
            gen.writeDateTimeField('ODSLastModifiedDate', contactRoleRecord.LastModifiedDate);

            if(contactRoleRecord.CreatedDate != null && contactRoleFields.contains('CreatedDate')){
                gen.writeDateTimeField('createdDate', contactRoleRecord.CreatedDate);     
            }else if(contactRoleRecord.CreatedDate == null && contactRoleFields.contains('CreatedDate')){
                gen.writeNullField('createdDate');
            }
            
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeBooleanField('upsert', false); 
            gen.writeEndObject(); 
        }
        System.debug('======== Update JSON ======== ' +gen.getAsString());
        return gen.getAsString();

    } 

}