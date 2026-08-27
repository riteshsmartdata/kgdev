public class OpportunityTriggerHelper {
    public static void pricerequestcaseassign(List<Opportunity> oppList) {
        Set<Id> priceId = new Set<Id>();
        
        for (Opportunity opp : oppList) {
            if (opp.Inquiry__c != null && opp.Source__c == 'Email') {
                priceId.add(opp.Inquiry__c);
            }
        }
        
        List<Inquiry__c> priceList = [SELECT Id, Name, Case__c FROM Inquiry__c WHERE Id IN :priceId AND Case__c != null];
        
        Map<Id, Id> inquiryToCaseMap = new Map<Id, Id>();
        for (Inquiry__c inquiry : priceList) {
            inquiryToCaseMap.put(inquiry.Id, inquiry.Case__c);
        }
        
        for (Opportunity opp : oppList) {
            if (inquiryToCaseMap.containsKey(opp.Inquiry__c)) {
                opp.Case__c = inquiryToCaseMap.get(opp.Inquiry__c);
            }
            Id userProfileId = UserInfo.getProfileId();
            String profileName = '';
            List<Profile> profiles = [SELECT Name FROM Profile WHERE Id = :userProfileId LIMIT 1];
            if(!profiles.isEmpty()) {
                profileName = profiles[0].Name;
            }
            if(opp.Case__c == null && opp.Source__c == 'Email' && 
               (profileName == 'BIC Standard User - Customer Service' || 
                profileName == 'BIC Standard User - Claims' ||  
                profileName == 'BIC Manager - Customer Service')) {
                    opp.addError('Case is required');
                }
        }
    }
}