public with sharing class EmailMessageTriggerHandler {
    
    // Constants for email domains - used for Koozie Inbound/Outbound classification
    private static final String KOOZIE_GROUP_DOMAIN = '@kooziegroup.com';
    private static final String BIC_GRAPHIC_DOMAIN = '@bicgraphic.com';
    private static final String CALENDAR_CS_EMAIL = 'csinfo@calendarcs.com';
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EmailMessageTriggerHandler');
    
    
    /**
     * @description Handles Koozie inbound/outbound email classification
     * @param newEmailMessages List of newly inserted EmailMessage records
     */
    public static void handleKoozieEmailClassification(List<EmailMessage> newEmailMessages) {
        
        List<EmailMessage> emailsToUpdate = new List<EmailMessage>();

        //Bypass the new logic
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        
        for (EmailMessage email : newEmailMessages) {
            
            EmailMessage updatedEmail = processEmailMessage(email);
            
            if (updatedEmail != null) {
                emailsToUpdate.add(updatedEmail);
            }
        }
        
        if (!emailsToUpdate.isEmpty()) {
            update emailsToUpdate;
        }
    }
    
    /**
     * @description Processes an individual EmailMessage record
     */
    private static EmailMessage processEmailMessage(EmailMessage email) {
        
        // Skip internal-to-internal emails completely
        Boolean fromInternal = areAllInternalEmails(email.FromAddress);
        Boolean toInternal = areAllInternalEmails(email.ToAddress);
        
        System.debug('From Internal ==> ' + fromInternal);
        System.debug('To Internal ==> ' + toInternal);
        System.debug('FromAddress ==> ' + email.FromAddress);
        System.debug('ToAddress ==> ' + email.ToAddress);
        
        if (fromInternal && toInternal) {
            System.debug('Skipping internal to internal email');
            return null;
        }
        
        // Inbound Email
        if (isInboundKoozieEmail(email)) {
            
            return new EmailMessage(
                Id = email.Id,
                Koozie_Inbound__c = true
            );
        }
        
        // Outbound Email
        else if (isOutboundKoozieEmail(email)) {
            
            return new EmailMessage(
                Id = email.Id,
                Koozie_Outbound__c = true
            );
        }
        
        return null;
    }
    
    /**
     * @description Checks if an email qualifies as an inbound Koozie email
     */
    private static Boolean isInboundKoozieEmail(EmailMessage email) {
        
        // Conditions:
        // 1. Incoming = true
        // 2. Koozie_Inbound__c != true
        // 3. ToAddress contains internal domain
        // 4. FromAddress does NOT contain internal domain
        
        if (email.Incoming != true || email.Koozie_Inbound__c == true) {
            return false;
        }
        
        Boolean hasValidToAddress = containsValidDomain(email.ToAddress);
        
        if (!hasValidToAddress) {
            return false;
        }
        
        Boolean hasValidFromAddress = containsValidDomain(email.FromAddress);
        
        return !hasValidFromAddress;
    }
    
    /**
     * @description Checks if an email qualifies as an outbound Koozie email
     */
    private static Boolean isOutboundKoozieEmail(EmailMessage email) {
        
        // Conditions:
        // 1. Status = '3' (Sent)
        // 2. Incoming = false
        // 3. FromAddress contains internal domain
        // 4. Koozie_Outbound__c != true
        // 5. ToAddress does NOT contain internal domain
        
        if (
            email.Status != '3' ||
            email.Incoming != false ||
            email.Koozie_Outbound__c == true
        ) {
            return false;
        }
        
        Boolean hasValidFromAddress = containsValidDomain(email.FromAddress);
        
        if (!hasValidFromAddress) {
            return false;
        }
        
        Boolean hasValidToAddress = containsValidDomain(email.ToAddress);
        
        return !hasValidToAddress;
    }
    
    /**
     * @description Checks if ANY email address belongs to internal domains
     */
    private static Boolean containsValidDomain(String emailAddresses) {
        
        if (String.isBlank(emailAddresses)) {
            return false;
        }
        
        String normalizedEmails = emailAddresses
            .replace(';', ',')
            .toLowerCase();
        
        List<String> emails = normalizedEmails.split(',');
        
        for (String email : emails) {
            
            String cleanedEmail = extractEmailAddress(email);
            
            System.debug('Checking Email ==> ' + cleanedEmail);
            
            if (
                cleanedEmail.contains(KOOZIE_GROUP_DOMAIN) ||
                cleanedEmail.contains(BIC_GRAPHIC_DOMAIN) ||
                cleanedEmail == CALENDAR_CS_EMAIL.toLowerCase()
            ) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * @description Checks if ALL email addresses belong to internal domains
     */
    private static Boolean areAllInternalEmails(String emailAddresses) {
        
        if (String.isBlank(emailAddresses)) {
            return false;
        }
        
        String normalizedEmails = emailAddresses
            .replace(';', ',')
            .toLowerCase();
        
        List<String> emails = normalizedEmails.split(',');
        
        for (String email : emails) {
            
            String cleanedEmail = extractEmailAddress(email);
            
            Boolean isInternal =
                cleanedEmail.contains(KOOZIE_GROUP_DOMAIN) ||
                cleanedEmail.contains(BIC_GRAPHIC_DOMAIN) ||
                cleanedEmail == CALENDAR_CS_EMAIL.toLowerCase();
            
            System.debug('Email ==> ' + cleanedEmail + ' | isInternal ==> ' + isInternal);
            
            if (!isInternal) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @description Extracts actual email from formats like:
     * John Smith <john@kooziegroup.com>
     */
    private static String extractEmailAddress(String rawEmail) {
        
        if (String.isBlank(rawEmail)) {
            return '';
        }
        
        String cleaned = rawEmail.trim().toLowerCase();
        
        if (cleaned.contains('<') && cleaned.contains('>')) {
            
            Integer startPos = cleaned.indexOf('<') + 1;
            Integer endPos = cleaned.indexOf('>');
            
            cleaned = cleaned.substring(startPos, endPos);
        }
        
        return cleaned.trim();
    }
    
    public static void emailLinkCaseAssignment(List<EmailMessage> newEmailLinkList) {
       
        Boolean RunLogic = False;
        
        System.debug('emailLinkCaseAssignment called@@@@@@@' + newEmailLinkList);
        
        Set<Id> caseIds = new Set<Id>();
        Map<String, Datetime> caseIDLinkDateMap = New Map<String, Datetime>();
        
        String caseId = '';
        String emailMessageStatus = '';
        
        for (EmailMessage el : newEmailLinkList) {
            
            caseId = el.ParentId;
            emailMessageStatus = el.Status;
            
            System.debug('====emailMessageStatus====' + emailMessageStatus);
            
            if (el.ParentId != null && caseId.startsWith('500')) {
                
                caseIds.add(el.ParentId);
                caseIDLinkDateMap.put(el.ParentId, el.CreatedDate);
            }
        }
        
        Map<String, String> profileMap = new Map<String, String>();
        
        List<Profile> profileList = [
            SELECT Id, Name
            FROM Profile
            WHERE Name LIKE '%claim%'
        ];
        
        for (Profile pr : profileList) {
            profileMap.put(pr.Id, pr.Name);
        }
        
        List<Case> updateCaseList = new List<Case>();
        
        Map<Id, Schema.RecordTypeInfo> caseRecordTypeMap =
            Case.sObjectType.getDescribe().getRecordTypeInfosById();
        
        List<Case> caseList = [
            SELECT Id,
                   CreatedDate,
                   ReOpen_Date__c,
                   Status,
                   RecordTypeId,
                   OwnerId,
                   CreatedBy.ProfileId
            FROM Case
            WHERE Id = :caseIds
        ];
        
        AssignmentRule AR = [
            SELECT Id
            FROM AssignmentRule
            WHERE SObjectType = 'Case'
            AND Active = True
            LIMIT 1
        ];
        
        for (Case cs : caseList) {
            
            Long caseCreatedTime = cs.CreatedDate.getTime();
            Long currentDTLong = caseIDLinkDateMap.get(cs.Id).getTime();
            
            Long milliseconds = currentDTLong - caseCreatedTime;
            Long seconds = milliseconds / 1000;
            
            if (seconds > 4) {
                RunLogic = true;
            }
            
            if (Test.isRunningTest()) {
                RunLogic = true;
            }
            
            if (
                (RunLogic) &&
                (
                    caseRecordTypeMap.get(cs.RecordTypeId)
                        .getName()
                        .containsIgnoreCase('Clarification')
                    &&
                    (
                        cs.Status != 'Closed' &&
                        cs.Status != 'Merged - Duplicate' &&
                        cs.Status != 'Merged'
                    )
                    &&
                    emailMessageStatus != '5'
                    &&
                    emailMessageStatus != '3'
                )
            ) {
                
                cs.Status = 'Customer Response';
                
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
                
                cs.setOptions(dmlOpts);
                updateCaseList.add(cs);
            }
            
            else if (
                (RunLogic) &&
                (
                    !caseRecordTypeMap.get(cs.RecordTypeId)
                        .getName()
                        .containsIgnoreCase('Clarification')
                    &&
                    (cs.Status == 'Closed')
                    &&
                    emailMessageStatus != '5'
                    &&
                    emailMessageStatus != '3'
                )
            ) {
                
                cs.Status = 'Customer Response';
                cs.ReOpen_Date__c = DateTime.now();
                
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
                
                cs.setOptions(dmlOpts);
                updateCaseList.add(cs);
            }
            
            else if (
                (RunLogic) &&
                (
                    !caseRecordTypeMap.get(cs.RecordTypeId)
                        .getName()
                        .containsIgnoreCase('Clarification')
                    &&
                    (
                        cs.Status != 'Closed' &&
                        cs.Status != 'Merged - Duplicate' &&
                        cs.Status != 'Merged'
                    )
                    &&
                    emailMessageStatus != '5'
                    &&
                    emailMessageStatus != '3'
                )
            ) {
                
                cs.Status = 'Customer Response';
                updateCaseList.add(cs);
            }
        }
        
        System.debug('updateCaseList@@@@@@@@@@' + updateCaseList);
        
        if (!updateCaseList.isEmpty()) {
            update updateCaseList;
        }
    }
}