public with sharing class EBSContactRequestFinance {
    
    final static String SALESFORCE = 'Salesforce';
    final static String EBS = 'EBS';
    final static String CUSTOMER_CONTACT = 'CUSTOMER_CONTACT';
    final static String EVENT_BUSINESS_ID = '1234567890';
    final static String STATUS_ACTIVE ='Active';
    final static String EMPTY = 'EMPTY';
    final static String CREATE_DML = 'CREATE'; 
    final static String EMAIL_COMMUNICATION = 'EMAIL';
    final static String PHONE_COMMUNICATION = 'PHONE';
    final static String FAX_COMMUNICATION = 'FAX';
    
    public static String contactRequestFromContact(
        Contact contactData,
        String eventType
    ){

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
            gen.writeFieldName('EventRequest');
            gen.writeStartObject();
                gen.writeStringField('EventType', eventType);
                gen.writeStringField('EventSourceSystem', 'Salesforce');
                gen.writeStringField('EventRecordSystem', 'EBS');
                gen.writeStringField('EventObject', 'CUSTOMER_CONTACT');
                gen.writeDateTimeField('EventDateTime', System.now());
                gen.writeStringField('EventBusinessID', '1234567890');

                gen.writeFieldName('CustomerContacts');
                gen.writeStartObject();
                    gen.writeFieldName('CustomerContact');
                    gen.writeStartArray();
                        gen.writeStartObject();

                            gen.writeStringField(
                                'ContactStatus',
                                contactData.Contact_Status__c == 'Active' ? 'A' : 'I'
                            );
                            gen.writeStringField('ContactLastName', contactData.LastName);
                            gen.writeStringField('ContactFirstName', contactData.FirstName ?? '');
                            gen.writeDateTimeField('ContactCreateDate', contactData.CreatedDate);
        
        				    gen.writeStringField( 'ResponsibilityType',  contactData.Responsibility_Type__c ?? ''); 

                            gen.writeDateTimeField(
                                'ContactLastUpdateDate',
                                contactData.LastModifiedDate
                            );

                            gen.writeFieldName('Communications');
                            gen.writeStartObject();
                                gen.writeFieldName('CommunicationArray');
                                gen.writeStartArray();
                                    setCommunications(gen, contactData);
                                gen.writeEndArray();
                            gen.writeEndObject();

                            gen.writeStringField('ActiveFlag', 'A');

                        gen.writeEndObject();
                    gen.writeEndArray();

                    gen.writeStringField( 'CustomerAccountNumber', contactData.Account?.Customer_Account_Number__c ?? '');

                gen.writeEndObject();
            gen.writeEndObject();
        gen.writeEndObject();

        return gen.getAsString();
    }

    public static void setCommunications(
        JSONGenerator gen,
        Contact contactData
    ){

        if(String.isNotBlank(contactData.Email)){
            gen.writeStartObject();
                gen.writeStringField(
                    'PrimaryFlag',
                    contactData.PrimaryEmailFlag__c ? 'true' : 'false'
                );
                gen.writeStringField('CommunicationMethod', 'EMAIL');
                gen.writeStringField('CommunicationInfo', contactData.Email);
                gen.writeStringField('ActiveFlag', 'A');
            gen.writeEndObject();
        }

        if(String.isNotBlank(contactData.Phone)){
            gen.writeStartObject();
                gen.writeStringField(
                    'PrimaryFlag',
                    contactData.PrimaryPhoneFlag__c ? 'true' : 'false'
                );
                gen.writeStringField('CommunicationMethod', 'PHONE');
                gen.writeStringField('CommunicationInfo', contactData.Phone);
                gen.writeStringField('ActiveFlag', 'A');
            gen.writeEndObject();
        }
    }
}