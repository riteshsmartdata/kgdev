/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ritesh Kumar
**/ 

global class callingFenerateContactJSONData {
    
    @InvocableMethod(label='Send Contact Information' description='Send contact information to third party system.' category='Contact')
    global static void sendContactInformation(List<ContactRequest> ContactRequestList){ 
        System.debug('======= sendContactInformation ====== ');
        System.debug('======= ContactRequestList ====== '+ContactRequestList);
        
        for( ContactRequest contactDataWrapper : ContactRequestList){ 

            if(contactDataWrapper.oldContact != null && contactDataWrapper.newContact != null){
                //Update Operaation
                System.debug('======= Old Contact ====== '+contactDataWrapper.oldContact);
                Set<String> fieldDifference = new Set<String>();
                fieldDifference = getFieldDifference(contactDataWrapper.newContact, contactDataWrapper.oldContact);               
                GenerateContactJSONData.generateJSONForSingleContactInsert( GenerateContactJSONData.updateOneContactJSON(contactDataWrapper.newContact, fieldDifference),'UPDATE');
    
            }else{
                //Insert operation 
                System.debug('======= New Contact ====== '+contactDataWrapper.newContact);
                if(contactDataWrapper.newContact != null){    
                    GenerateContactJSONData.generateJSONForSingleContactInsert(GenerateContactJSONData.insertOneContactJSON(contactDataWrapper.newContact),'INSERT');
                }
            } 
        }
        System.debug('@@@@@@@@@@ sendContactInformation @@@@@@@@@@');
        
    } 

    global static Set<String> getFieldDifference(Contact newContact,Contact oldContact){

        Set<String> fieldDifferenc = new Set<String>();
        if(newContact.Phone != oldContact.Phone ){
            fieldDifferenc.add('Phone');
        }

        if(newContact.PromoStandards_Contact__c != oldContact.PromoStandards_Contact__c ){
            fieldDifferenc.add('PromoStandards_Contact__c');
        }

        if(newContact.PrimaryOtherEmailFlag__c != oldContact.PrimaryOtherEmailFlag__c ){
            fieldDifferenc.add('PrimaryOtherEmailFlag__c');
        }

        if(newContact.Top_Producer__c != oldContact.Top_Producer__c ){
            fieldDifferenc.add('Top_Producer__c');
        }

        if(newContact.Responsibility_Type__c != oldContact.Responsibility_Type__c ){
            fieldDifferenc.add('Responsibility_Type__c');
        }

        if(newContact.Account_Industry__c != oldContact.Account_Industry__c ){
            fieldDifferenc.add('Account_Industry__c');
        }

        if(newContact.OtherPhone != oldContact.OtherPhone ){
            fieldDifferenc.add('OtherPhone');
        }

        if(newContact.Other_Email__c != oldContact.Other_Email__c ){
            fieldDifferenc.add('Other_Email__c');
        }

        if(newContact.PrimaryEmailFlag__c != oldContact.PrimaryEmailFlag__c ){
            fieldDifferenc.add('PrimaryEmailFlag__c');
        }

        if(newContact.EmailID__c != oldContact.EmailID__c){
            fieldDifferenc.add('EmailID__c');
        }


        if(newContact.Date_Verified__c != oldContact.Date_Verified__c ){
            fieldDifferenc.add('Date_Verified__c');
        }

        if(newContact.FaxID__c != oldContact.FaxID__c ){
            fieldDifferenc.add('FaxID__c');
        }

        if(newContact.Verified__c != oldContact.Verified__c ){
            fieldDifferenc.add('Verified__c');
        }

        if(newContact.MiddleName != oldContact.MiddleName ){
            fieldDifferenc.add('MiddleName');
        }

        if(newContact.PrimaryFaxFlag__c != oldContact.PrimaryFaxFlag__c ){
            fieldDifferenc.add('PrimaryFaxFlag__c');
        }

        if(newContact.MailingPostalCode != oldContact.MailingPostalCode ){
            fieldDifferenc.add('MailingPostalCode');
        }

        if(newContact.MailingCity != oldContact.MailingCity ){
            fieldDifferenc.add('MailingCity');
        }

        if(newContact.MailingCountry != oldContact.MailingCountry ){
            fieldDifferenc.add('MailingCountry');
        }

        if(newContact.MailingState != oldContact.MailingState ){
            fieldDifferenc.add('MailingState');
        }

        if(newContact.MailingStreet != oldContact.MailingStreet ){
            fieldDifferenc.add('MailingStreet');
        }

        if(newContact.Other_Email_ID__c != oldContact.Other_Email_ID__c ){
            fieldDifferenc.add('Other_Email_ID__c');
        }    

        if(newContact.LastName != oldContact.LastName ){
            fieldDifferenc.add('LastName');
        }

        if(newContact.Fax != oldContact.Fax ){
            fieldDifferenc.add('Fax');
        }

        if(newContact.PrimaryOtherPhoneFlag__c != oldContact.PrimaryOtherPhoneFlag__c ){
            fieldDifferenc.add('PrimaryOtherPhoneFlag__c');
        }

        if(newContact.Account_Number__c != oldContact.Account_Number__c ){
            fieldDifferenc.add('Account_Number__c');
        }

        if(newContact.Address_Type__c != oldContact.Address_Type__c ){
            fieldDifferenc.add('Address_Type__c');
        }

        if(newContact.Salesforce_com_ID__c != oldContact.Salesforce_com_ID__c ){
            fieldDifferenc.add('Salesforce_com_ID__c');
        }

        if(newContact.Clean_Phone_Number__c != oldContact.Clean_Phone_Number__c ){
            fieldDifferenc.add('Clean_Phone_Number__c');
        } 

        if(newContact.CreatedById != oldContact.CreatedById ){
            fieldDifferenc.add('CreatedById');
        }

        if(newContact.Email != oldContact.Email ){
            fieldDifferenc.add('Email');
        }

        if(newContact.LastModifiedById != oldContact.LastModifiedById ){
            fieldDifferenc.add('LastModifiedById');
        }

        if(newContact.Contact_Type__c != oldContact.Contact_Type__c ){
            fieldDifferenc.add('Contact_Type__c');
        }

        if(newContact.Contact_Account_Status__c != oldContact.Contact_Account_Status__c ){
            fieldDifferenc.add('Contact_Account_Status__c');
        }

        if(newContact.IsDeleted != oldContact.IsDeleted ){
            fieldDifferenc.add('IsDeleted');
        }

        if(newContact.MobilePhone != oldContact.MobilePhone ){
            fieldDifferenc.add('MobilePhone');
        }

        if(newContact.Territory__c != oldContact.Territory__c ){
            fieldDifferenc.add('Territory__c');
        }

        if(newContact.Address_Status__c != oldContact.Address_Status__c ){
            fieldDifferenc.add('Address_Status__c');
        }

        if(newContact.RecordTypeId != oldContact.RecordTypeId ){
            fieldDifferenc.add('RecordTypeId');
        }

        if(newContact.LastModifiedDate != oldContact.LastModifiedDate ){
            fieldDifferenc.add('LastModifiedDate');
        }

        if(newContact.Source_ID__c != oldContact.Source_ID__c ){
            fieldDifferenc.add('Source_ID__c');
        }

        if(newContact.Title != oldContact.Title ){
            fieldDifferenc.add('Title');
        }

        if(newContact.OwnerId != oldContact.OwnerId ){
            fieldDifferenc.add('OwnerId');
        }

        if(newContact.CreatedDate != oldContact.CreatedDate ){
            fieldDifferenc.add('CreatedDate');
        }

        if(newContact.OtherPhoneID__c != oldContact.OtherPhoneID__c ){
            fieldDifferenc.add('OtherPhoneID__c');
        }

        if(newContact.PhoneID__c != oldContact.PhoneID__c ){
            fieldDifferenc.add('PhoneID__c');
        }

        if(newContact.HasOptedOutOfEmail != oldContact.HasOptedOutOfEmail ){
            fieldDifferenc.add('HasOptedOutOfEmail');
        }

        if(newContact.FirstName != oldContact.FirstName ){
            fieldDifferenc.add('FirstName');
        } 

        if(newContact.Do_Not_Mail__c != oldContact.Do_Not_Mail__c ){
            fieldDifferenc.add('Do_Not_Mail__c');
        }


        if(newContact.Suffix != oldContact.Suffix ){
            fieldDifferenc.add('Suffix');
        }

        if(newContact.AccountId != oldContact.AccountId ){
            fieldDifferenc.add('AccountId');
        }

        if(newContact.PrimaryPhoneFlag__c != oldContact.PrimaryPhoneFlag__c ){
            fieldDifferenc.add('PrimaryPhoneFlag__c');
        }

        if(newContact.Source__c != oldContact.Source__c ){
            fieldDifferenc.add('Source__c');
        }


        if(newContact.Contact_Status__c != oldContact.Contact_Status__c ){
            fieldDifferenc.add('Contact_Status__c');
        }


        if(newContact.LastModifiedDate != oldContact.LastModifiedDate ){
            fieldDifferenc.add('LastModifiedDate');
        }

        if(newContact.Salutation != oldContact.Salutation ){
            fieldDifferenc.add('Salutation');
        } 
        if(newContact.Contact_ID__c != oldContact.Contact_ID__c ){
            fieldDifferenc.add('Contact_ID__c');
        } 
        if(newContact.Merged_Contact_ID__c != oldContact.Merged_Contact_ID__c ){
            fieldDifferenc.add('Merged_Contact_ID__c');
        } 
        if(newContact.LastModifiedDate != oldContact.LastModifiedDate ){
            fieldDifferenc.add('LastModifiedDate');
        } 
        return fieldDifferenc;
        
    } 
    
    global class ContactRequest {

        @InvocableVariable(required=true description='New Contact List' label='new Contact')
        public Contact newContact;

        @InvocableVariable(required=false description='Old Contact List' label='old contact')
        public Contact oldContact; 
        
        public ContactRequest(){
            oldContact = new Contact();
            newContact = new Contact();
        }

    }

}