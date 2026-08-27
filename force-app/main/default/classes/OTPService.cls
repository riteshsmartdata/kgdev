/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-20-2024   Ritesh Kumar   Initial Version
**/
global without sharing class OTPService {

	// Inner class to handle OTP details
    public class OTPDetails {
        public String otp;
        public String email;
        public DateTime expirationTime;

        // Constructor for OTPDetails
        public OTPDetails(String email) {
            this.email = email;
            this.otp = generateOTP();
            this.expirationTime = System.now().addMinutes(10);  // OTP expiration set to 10 minutes
        }
    }

    // Generate OTP - return a 6-digit string OTP
    public static String generateOTP() {
        Integer randomOTP = Integer.valueOf(Math.floor(Math.random() * 900000) + 100000);
        return String.valueOf(randomOTP);
    }

    // Store OTP details in the custom object (OTP__c)
    private static void storeOTPInDatabase(OTPDetails otpDetails) {
        OTP__c otpRecord = new OTP__c(
            Email__c = otpDetails.email,
            OTP_Code__c = otpDetails.otp,
            Expiration_Time__c = otpDetails.expirationTime
        );
        insert otpRecord;
    }

    // Send OTP email to the recipient
    public static void sendOTPEmail(Map<String, String> emailInfo, String template) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = : System.label.Verification_Code_From_Address];
		if ( owea.size() > 0 ) {
			mail.setOrgWideEmailAddressId(owea.get(0).Id);
		}
        mail.setToAddresses(new String[] {emailInfo.get('email')});
        mail.setSubject(emailInfo.get('subject'));
        
        String emailBody = renderString(template,emailInfo);
        mail.setPlainTextBody(emailBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    // Public method to initiate OTP generation and send email
    public static void sendOTP(Map<String, String> emailInfo, String template) {
        OTPDetails otpDetails = new OTPDetails(emailInfo.get('email'));
		
		emailInfo.put('otp', otpDetails.otp);
        // Store OTP in the database
        storeOTPInDatabase(otpDetails);
		

        // Send OTP email
        sendOTPEmail(emailInfo, template);
        
        // Log for debugging
        System.debug('OTP sent to: ' + emailInfo.get('email') + ' OTP: ' + otpDetails.otp);
    }

    // Method to validate OTP (optional)
    public static Boolean validateOTP(String email, String enteredOTP) {
        // Query the OTP object to retrieve the OTP and compare it with the entered OTP
        OTP__c otpRecord = [SELECT OTP_Code__c, Expiration_Time__c FROM OTP__c WHERE Email__c = :email ORDER BY CreatedDate DESC LIMIT 1];
        
        if (otpRecord != null && otpRecord.Expiration_Time__c > System.now()) {
            return otpRecord.OTP_Code__c == enteredOTP;
        }
        return false;  // OTP expired or does not match
    } 

	// Method to render the string by replacing placeholders with actual values
    public static String renderString(String template, Map<String, String> replacements) {
        // Ensure the input string and replacements map are not null or empty
        if (String.isNotEmpty(template) && replacements != null && !replacements.isEmpty()) {
            // Iterate through the map and replace each placeholder with its corresponding value
            for (String placeholder : replacements.keySet()) {
                String placeholderKey = '<<' + placeholder + '>>';
                String replacementValue = replacements.get(placeholder);
                
                // Replace the placeholder in the template with the replacement value
                template = template.replace(placeholderKey, replacementValue);
            }
        }
        return template; // Return the modified template with replaced values
    }
    
}