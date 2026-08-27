public class PriceRequestTriggerHelper {
    public static void priceRequestAddValidation(List<Inquiry__c> inqList) {
        for(Inquiry__c inq : inqList){
            Id userProfileId = UserInfo.getProfileId();
            String profileName = '';
            List<Profile> profiles = [SELECT Name FROM Profile WHERE Id = :userProfileId LIMIT 1];
            if(!profiles.isEmpty()) {
                profileName = profiles[0].Name;
            }
            
            if(inq.Case__c == null && inq.Source__c == 'Email' && 
               (profileName == 'BIC Standard User - Customer Service' || 
                profileName == 'BIC Standard User - Claims' ||  
                profileName == 'BIC Manager - Customer Service' )) {
                    inq.addError('Case is required');
                }
        }
    }
}