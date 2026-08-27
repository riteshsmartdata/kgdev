/**
 * @description       : Utility class for handling pre-chat actions
 * @last modified on  : 02-25-2025
 * @last modified by  : Ritesh Kumar
**/
global without sharing class PreChatHandler {
    
    /**
     * @description   : Checks if the current time falls within the working hours
     * @return        : Boolean indicating whether it's working hours
    **/
    @AuraEnabled(cacheable=true)
    global static Boolean checkWorkingHours(String businessHourName) {  
        try {
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = :businessHourName LIMIT 1];
            return BusinessHours.isWithin(bh.Id, System.now());
        } catch (Exception e) {
            System.debug('Error in checkWorkingHours: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while checking business hours: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean sendOTP(Map<String, String> emailInfo, String template) {  
        try {
            Boolean isContactPresent = checkContact(emailInfo.get('email'));
            if (isContactPresent) {
                OTPService.sendOTP(emailInfo, template);
                return true;
            } else {
                return false;
            }
        } catch (Exception e) { 
            System.debug('Error in sendOTP: ' + e.getMessage());
            throw e;//new AuraHandledException('An error occurred while sending the OTP: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void reSendOTP(Map<String, String> emailInfo, String template) {  
        try {
           	OTP__c [] otpRecord = [SELECT OTP_Code__c, Expiration_Time__c FROM OTP__c WHERE Email__c = :emailInfo.get('email') ORDER BY CreatedDate DESC LIMIT 1]; 
            if(otpRecord.size() > 0){
				emailInfo.put('otp', otpRecord[0].OTP_Code__c);
				OTPService.sendOTPEmail(emailInfo, template);
			}else{
				new AuraHandledException('An error occurred while resending the OTP');
			}

        } catch (Exception e) {
            System.debug('Error in reSendOTP: ' + e.getMessage());
            throw e;//new AuraHandledException('An error occurred while resending the OTP: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean validateOTP(String email, String otp) {  
        try {
            return OTPService.validateOTP(email, otp);
        } catch (Exception e) {
            System.debug('Error in validateOTP: ' + e.getMessage());
            throw e;//new AuraHandledException('An error occurred while validating the OTP: ' + e.getMessage());
        }
    }

    private static Boolean checkContact(String email) {
        try {
            Contact[] record = [SELECT Id, Email FROM Contact WHERE Email = :email AND RecordType.Name = 'CRM Contact' ORDER BY CreatedDate DESC LIMIT 1];
            return record.size() > 0;
        } catch (Exception e) {
            System.debug('Error in checkContact: ' + e.getMessage());
            throw e; //new AuraHandledException('An error occurred while checking the contact: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Chat_Setting__mdt loadChatSetting() {
        try {
            Chat_Setting__mdt config = [SELECT Verification_Error__c, Email_Subject__c, Verification_button_Label__c, 
                                        Verification_Input_Label__c, Record_Not_Found_Message__c, Email_Message__c, 
                                        Verification_Code_Message__c, Validation_Message__c, Resend_Button_Label__c, 
                                        Start_Chat_button_Label__c, Day_Off__c, Day_Off_Title__c, SystemModstamp, 
                                        QualifiedApiName, Label, NamespacePrefix, Language, MasterLabel, 
                                        DeveloperName, Id, OPT_Expired_Title__c, OPT_Expired_Message__c ,Time_Up__c
                                        FROM Chat_Setting__mdt WHERE DeveloperName = 'Koozie_Group' LIMIT 1];
            System.debug(System.LoggingLevel.INFO, '======== config ===' + config);
            return config;
        } catch (Exception e) {
            System.debug('Error in loadChatSetting: ' + e.getMessage());
            throw e;//new AuraHandledException('An error occurred while loading chat settings: ' + e.getMessage());
        }
    }
}