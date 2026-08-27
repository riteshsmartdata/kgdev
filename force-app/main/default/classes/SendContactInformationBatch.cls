/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 07-21-2022
 * @last modified by  : Ritesh Kumar
**/
global with sharing class SendContactInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts { 

    global Database.QueryLocator start(Database.BatchableContext BC){
        String contactSOQL = 'SELECT Id, IsDeleted, MasterRecordId, AccountId, LastName, FirstName, Salutation, MiddleName, Suffix, Name, RecordTypeId, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, OtherLatitude, OtherLongitude, OtherGeocodeAccuracy, OtherAddress, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone, Fax, MobilePhone, OtherPhone, ReportsToId, Email, Title, Department, OwnerId, HasOptedOutOfEmail, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, LastCURequestDate, LastCUUpdateDate, LastViewedDate, LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced, PhotoUrl, Jigsaw, JigsawContactId, IndividualId, Contact_Status__c, Primary_Team_Member__c, Discover_Guides__c, Contact_Account_Status__c, Contact__c, Days_Since_Last_Activity__c, Account_Industry__c, Contact_Type__c, Territory__c, ASI_Number__c, Contact_Domain__c, Company__c, Website__c, Calendar_Sample_Kit_CAN__c, Calendar_Sample_Kit_US__c, Motivator_On_Board__c, Data_Import__c, Bic__c, Norwood__c, ROW_ID__c, Account_Number__c, Sales_Rep__c, SFSSDupeCatcher__Override_DupeCatcher__c, Address1_ID__c, Address2_ID__c, Address3_ID__c, Address4_ID__c, Address_Status__c, Address_Type__c, County__c, Address_Site__c, Top_Producer__c, Contact_ID__c, EmailID__c, FaxID__c, PhoneID__c, Line_Total__c, National_Sales__c, PrimaryEmailFlag__c, PrimaryFaxFlag__c, PrimaryPhoneFlag__c, PrimaryOtherPhoneFlag__c, Responsibility_Type__c, OtherPhoneID__c, Primary_ID__c, Active_Flag__c, Do_Not_Mail__c, Inside_Sales__c, Field_Sales__c, EBS__c, CRM_OD_ID__c, Verified__c, Date_Verified__c, Product_Knowledge__c, Discounts__c, Source__c, Source_ID__c, Samples__c, Storyboards__c, Communication_Styles__c, Preferred_Channel__c, Preferred_Contact__c, Age_Group__c, Role__c, Data_Upload_Identifier__c, Other_Email__c, Not_Duplicate__c, Other_Email_ID__c, PrimaryOtherEmailFlag__c, Bounce_Count__c, Primary_Sales_Team_Member_Email__c, Primary_Sales_Team_Member__c, Account_And_Record_Type__c, Primary_Responsibility_Flag__c, Email_Bounced__c, Active__c, Shared_Email__c, Salesforce_com_ID__c, Account_Queue__c, Secondary_Contact_Type__c, Closeout_Updates__c, Flyers_Special_Offers__c, New_Product_Information__c, Newsletters__c, Weekly_USB_Pricing__c, Random_Samples_Journey__c, MOB_Opt_Out__c, Onboarding_Opt_Out__c, Marketing_Cloud_Contact_Sync__c, PromoStandards_Contact__c, Case_Studies__c, DOB__c, Gender__c, Preferred_Phone_Number__c, Purchaser__c, Salesforce_Id_18Char__c, Do_Not_Call_For_Clarifications__c, Clean_Phone_Number__c, Clean_Mobile_Number__c, Account_Category__c, First_Created_Date__c, Email_LastName_Account__c, Email_LastName__c, MergePriority__c, Role_Clarification__c, Role_A_P__c, Role_Sales_Service__c, Role_Website__c, Role_End_User__c, Merged_Contact_ID__c, Role_PO_Contact__c, Email_Account__c FROM Contact';
        // contactSOQL += ' LIMIT 10';
        return Database.getQueryLocator(contactSOQL);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contactlist){
        if(contactlist.size() > 0){
            for(Contact data : contactlist){
                GenerateContactJSONData.sendSingleContactInformation(GenerateContactJSONData.insertOneContactJSON(data), 'INSERT');
            }
        }
    }


    global void finish(Database.BatchableContext BC){
        
    }
 
}