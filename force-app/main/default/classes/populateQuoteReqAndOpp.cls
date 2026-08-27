public without sharing class populateQuoteReqAndOpp { 
    
    public static void updateOrderWithQuoteAndOpp(Map<String, List<EBS_Order__c>> quoteNumOrderMap) {
        
        if (quoteNumOrderMap.isEmpty()) {
            return;
        }
        
        Set<String> oqrSet = new Set<String>(); 
        Set<String> qrOrQSet = new Set<String>(); 
        
        // Categorize numbers
        for (String num : quoteNumOrderMap.keySet()) {
            if (String.isBlank(num)) {
                continue;
            }
            if (num.startsWith('OQR')) {
                oqrSet.add(num);
            } else if (num.startsWith('QR') || num.startsWith('Q-')) {
                qrOrQSet.add(num);
            }
        }
        
        Map<String, Opportunity> quoteNumberOppMap = new Map<String, Opportunity>();
        Map<String, Quote_Request__c> quoteReqMap  = new Map<String, Quote_Request__c>(); 
        
        // Fetch Opportunities for OQR
        if (!oqrSet.isEmpty()) {
            for (Opportunity oppRec : [
                SELECT Id, Quote_Number__c 
                FROM Opportunity 
                WHERE Quote_Number__c IN :oqrSet
            ]) {
                quoteNumberOppMap.put(oppRec.Quote_Number__c, oppRec);
            }
        }
        
        if (!qrOrQSet.isEmpty()) {
            for (Quote_Request__c qrRec : [
                SELECT Id, Name, Quote_Number__c, Opportunity__c
                FROM Quote_Request__c 
                WHERE Name IN :qrOrQSet 
                   OR Quote_Number__c IN :qrOrQSet
            ]) {
                quoteReqMap.put(qrRec.Name, qrRec);
                if (String.isNotBlank(qrRec.Quote_Number__c)) {
                    quoteReqMap.put(qrRec.Quote_Number__c, qrRec);
                }
            }
        }
        
        // Update orders
        for (String qNum : quoteNumOrderMap.keySet()) {
            
            if (String.isBlank(qNum)) {
                continue;
            }
            
            for (EBS_Order__c order : quoteNumOrderMap.get(qNum)) {
                
                if (qNum.startsWith('OQR')) {
                    if (quoteNumberOppMap.containsKey(qNum)) {
                        order.Opportunity__c = quoteNumberOppMap.get(qNum).Id;
                    } else {
                        System.debug('No Opportunity found for Quote Number: ' + qNum);
                    }
                } 
                else if (qNum.startsWith('QR') || qNum.startsWith('Q-')) {
                    if (quoteReqMap.containsKey(qNum)) {
                        Quote_Request__c qr = quoteReqMap.get(qNum);
                        order.Quote_Request__c = qr.Id;
                        order.Opportunity__c   = qr.Opportunity__c;
                    } else {
                        System.debug('No Quote Request found for: ' + qNum);
                    }
                }
            }
        }
    }
}