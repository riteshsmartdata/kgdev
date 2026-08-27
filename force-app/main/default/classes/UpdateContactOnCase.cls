/**
* @description       : 
* @author            : Kumar Saurav
* @group             : 
* @last modified on  : 01-10-2023
* @last modified by  : Kumar Saurav
**/  
public without sharing class UpdateContactOnCase {
    
    public static void UpdateCaseContact(List<Case> newcaseList) {  
        Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('CaseTrigger');
        if(triggerSetting.Is_Active__c == TRUE){
            
            
            if(checkRecursive.isFirstTime==true){
                checkRecursive.isFirstTime=false;
                System.debug('========= UpdateCaseContact@@@@========');        
                Set<String> ebsAccountNumberSet = new Set<String>();
                Map<String,Account> accountMap = new Map<String,Account>();
                Map<String,Account> accountDomainMap = new Map<String,Account>();
                Set<String> caseEmailSet = new Set<String>();
                Map<String, Contact> contactMap = new Map<String,Contact>();
                List<Case> updateCaseList = new List<Case>();
                Map<String,Case> caseWithoutContactMap = new Map<String,Case>();
                Boolean isSetCaseId = true;
                List<Contact> insertContactList = new List<Contact>();
                List<Contact_Roles__c> insertContactRoleList = new List<Contact_Roles__c>();
                List<Contact_Roles__c> insertNewContactRoleList = new List<Contact_Roles__c>();
                List<Contact> updateContactList = new List<Contact>();
                Map<Id,  Contact_Roles__c> contactWithRolesMap = new Map<Id,  Contact_Roles__c>(); 
                Map<String,Contact> duplicateCheckMap = new Map<String,Contact>();
                //Account accountRecord;
                Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
                Id orphanaccountId = System.Label.Orphan_Account_Id;
                Id koozieGroupAccountId = System.Label.Koozie_Group_Account_Id;
                Set<Id> contactIdSet = new Set<Id>();
                List<Contact> newContactList = new List<Contact>();
                Map<String,Contact> existingContactMap = new Map<String,Contact>();
                List<Contact> contactsToBeInserted = new List<Contact>();
                Id caseClarificationId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
                String domain = '@kooziegroup.com';
                for(Case caseRecord : newcaseList){
                    if(caseRecord.contactId == null){
                        if(String.isNotBlank(caseRecord.EBS_Account_Number__c)){ 
                            ebsAccountNumberSet.add(caseRecord.EBS_Account_Number__c);
                            System.debug('====ebsAccountNumberSet===='+ebsAccountNumberSet);
                        }
                        
                        if(String.isNotBlank(caseRecord.SuppliedEmail)){
                            caseEmailSet.add(caseRecord.SuppliedEmail); 
                            System.debug('====caseEmailSet===='+caseEmailSet);
                        }
                    }else{
                        System.debug('========= caseRecord.contactId========'+caseRecord.contactId);
                        contactIdSet.add(caseRecord.contactId);
                    } 
                }
                System.debug('========= caseEmailSet========'+caseEmailSet);
                
                System.debug('========= ebsAccountNumberSet========'+ebsAccountNumberSet.size());
                
                if(ebsAccountNumberSet.size() > 0){
                    for(Account accountRecord : [
                        SELECT Id, Customer_Account_Number__c,Status__c  
                        FROM Account 
                        WHERE Customer_Account_Number__c != NULL AND 
                        Customer_Account_Number__c IN: ebsAccountNumberSet ORDER BY CreatedDate DESC
                    ])
                    {
                        System.debug(':::::::::: Enetred in SOQL ::::::::');
                        accountMap.put(accountRecord.Customer_Account_Number__c, accountRecord);
                        System.debug('accountMap :::::: '+accountMap);
                        
                    } 
                }
                
                System.debug('========= accountMap========'+accountMap);
                
                Set<String> domainSet = new Set<String>();
                
                if(caseEmailSet.size() > 0 ){
                    for(String caseEmail : caseEmailSet){
                        System.debug('========== Emal ========'+caseEmail.split('@')[1]);
                        domainSet.add(caseEmail.split('@')[1]);
                        System.debug('====Supplied email domain===='+domainSet);
                    }
                } 
                if(domainSet.size() > 0){
                    for(Account accountRecord : [
                        SELECT Id, Account_Domain__c,Status__c FROM Account 
                        WHERE Account_Domain__c IN:  domainSet ORDER BY CreatedDate DESC
                    ])
                    {
                        
                        if(accountRecord.Account_Domain__c !=null){
                            accountDomainMap.put(accountRecord.Account_Domain__c, accountRecord);
                        }
                    } 
                }
                
                System.debug('========= accountDomainMap========'+accountDomainMap);
                
                if(caseEmailSet.size() > 0){
                    if( !(ebsAccountNumberSet.size() > 0)){
                        for(Contact contactRecord : [
                            SELECT  Id, Email, AccountID, LastName,FirstName,Account.Status__c, Contact_Status__c,Account.Customer_Account_Number__c, Responsibility_Type__c
                            FROM Contact 
                            WHERE Email =: caseEmailSet AND 
                            RecordType.Name = 'CRM Contact' ORDER BY CreatedDate DESC
                        ]){
                            System.debug('========= contactRecord========'+contactRecord.LastName);
                            System.debug('========= contactRecord========'+contactRecord.FirstName);
                            contactMap.put(contactRecord.Email, contactRecord);
                            System.debug('========= contactMap========'+contactMap);
                            contactIdSet.add(contactRecord.Id); 
                            
                        }
                        
                    }   
                    if((ebsAccountNumberSet.size() > 0)){            
                        
                        for(Contact contactRecord : [
                            SELECT  Id, Email, AccountID, LastName,FirstName,Contact_Status__c,Account.Status__c, Account.Customer_Account_Number__c, Responsibility_Type__c
                            FROM Contact 
                            WHERE Email =: caseEmailSet AND 
                            RecordType.Name = 'CRM Contact'
                            AND Account.Customer_Account_Number__c IN: accountMap.keySet() ORDER BY CreatedDate DESC LIMIT 1
                        ]){
                            System.debug('========= contactRecord========'+contactRecord.LastName);
                            System.debug('========= contactRecord========'+contactRecord.FirstName);
                            contactMap.put(contactRecord.Email, contactRecord);
                            contactIdSet.add(contactRecord.Id);
                            System.debug('========= contactMap========'+contactMap);
                            System.debug('========= contactIdSet========'+contactIdSet);
                        }
                    }
                }
                
                
                System.debug('========= contactIdSet========'+contactIdSet);
                if(contactIdSet.size() > 0 ){           
                    for( Contact_Roles__c contactRole :[ 
                        SELECT Contact__c, Contact__r.AccountId, Id,Contact_Role_Name__c
                        FROM Contact_Roles__c
                        WHERE Contact__c IN: contactIdSet AND (Contact_Role_Name__c = 'CLARIFICATIONS' OR Contact_Role_Name__c = 'SALES_SERVICE') ORDER BY CreatedDate DESC
                    ]){
                        contactWithRolesMap.put(contactRole.Contact__c , contactRole);
                    }
                }
                System.debug('========= contactWithRolesMap========'+contactWithRolesMap);
                System.debug('========= contactMap========'+contactMap);
                
                for(Case caseRecord : newcaseList){ 
                    if(caseRecord.contactId == null){
                        Case tempCase = new Case();               
                        Contact contactData = new Contact();
                        if(contactMap.containsKey(caseRecord.SuppliedEmail) && caseRecord.EBS_Account_Number__c != null){ 
                            system.debug('insdie if @@@');
                            tempCase.Id = caseRecord.Id;
                            tempCase.ContactId = contactMap.get(caseRecord.SuppliedEmail).Id;
                            tempCase.AccountId = contactMap.get(caseRecord.SuppliedEmail).AccountId;
                            updateCaseList.add(tempCase);
                            if(contactMap.get(caseRecord.SuppliedEmail).Account.Status__c == 'Active'){
                                
                                contactData.Id = tempCase.ContactId;
                                contactData.Contact_Status__c = 'Active';
                                if(!updateContactList.contains(contactData)){
                                    system.debug('Case to update entered');
                                    updateContactList.add(contactData);    
                                }
                                
                            }
                        } 
                        else if(contactMap.containsKey(caseRecord.SuppliedEmail) && caseRecord.EBS_Account_Number__c == null){ 
                            tempCase.ContactId = contactMap.get(caseRecord.SuppliedEmail).Id;
                            System.debug('====tempCase.ContactId===='+tempCase.ContactId);
                            
                            contactData.Id = tempCase.ContactId;
                            if(contactMap.get(caseRecord.SuppliedEmail).AccountId != null){
                                system.debug('entered in if condition');
                                tempCase.AccountId = contactMap.get(caseRecord.SuppliedEmail).AccountId;
                                tempCase.Id = caseRecord.Id;
                                updateCaseList.add(tempCase);
                                if(!updateContactList.contains(contactData)){
                                    system.debug('Case to update entered1');
                                    updateContactList.add(contactData);    
                                }
                            }
                            else{
                                if(accountDomainMap.containsKey(caseRecord.SuppliedEmail.split('@')[1])){
                                    tempCase.Id = caseRecord.Id;
                                    tempCase.AccountId = accountDomainMap.get(caseRecord.SuppliedEmail.split('@')[1]).Id;
                                    contactData.AccountId = accountDomainMap.get(caseRecord.SuppliedEmail.split('@')[1]).Id;
                                    updateCaseList.add(tempCase);
                                    if(!updateContactList.contains(contactData)){
                                        system.debug('Case to update entered2');
                                        updateContactList.add(contactData);    
                                    }
                                }
                                else{
                                    tempCase.AccountId = orphanaccountId;
                                    contactData.AccountId = orphanaccountId;
                                    tempCase.Id = caseRecord.Id;
                                    updateCaseList.add(tempCase);
                                }
                                
                            }
                            
                            if(contactMap.get(caseRecord.SuppliedEmail).Account.Status__c == 'Active'){
                                
                                contactData.Contact_Status__c = 'Active';
                                if(!updateContactList.contains(contactData)){
                                    system.debug('Case to update entered in if condition');
                                    updateContactList.add(contactData);    
                                }
                                
                            }
                        }                
                        else if(!contactMap.containsKey(caseRecord.SuppliedEmail)){
                            caseWithoutContactMap.put(caseRecord.SuppliedEmail,caseRecord);
                        }
                        if(contactData.Id != null && (!contactWithRolesMap.containsKey(contactData.Id))){
                            
                            Contact_Roles__c contactRoleRecord = new Contact_Roles__c();
                            contactRoleRecord.Contact__c = contactData.id;
                            contactRoleRecord.Account__c = contactMap.get(caseRecord.SuppliedEmail).AccountId; 
                            if(caseRecord.RecordTypeId == caseClarificationId){
                                contactRoleRecord.Contact_Role_Name__c = 'CLARIFICATIONS';
                            }else{
                                contactRoleRecord.Contact_Role_Name__c = 'SALES_SERVICE';
                            }
                            insertContactRoleList.add(contactRoleRecord);
                            
                        } 
                    }
                }
                
                System.debug('==== caseWithoutContactMap ===='+caseWithoutContactMap.values().size());        
                if(caseWithoutContactMap.values().size() > 0){
                    for(String caseEmail : caseWithoutContactMap.keySet()){
                        if(caseEmail != null) {
                            Contact newContact = new Contact();
                            newContact.LastName = 'Customer';
                            newContact.FirstName = 'Valued';
                            newContact.Email = caseEmail;  
                            newContact.Contact_Status__c = 'Active'; 
                            newContact.RecordTypeId = RecordTypeId;
                            newContact.Source__c = 'UpdateContactOnCase'; 
                            System.debug('======= accountMap ======= '+caseWithoutContactMap.get(caseEmail).EBS_Account_Number__c);
                            if(accountMap.containsKey(caseWithoutContactMap.get(caseEmail).EBS_Account_Number__c)){
                                newContact.AccountId =  accountMap.get(caseWithoutContactMap.get(caseEmail).EBS_Account_Number__c).Id;
                               newContactList.add(new Contact(FirstName = 'Valued', LastName = 'Customer', AccountId = newContact.AccountId, Email = caseEmail, RecordTypeId = recordTypeID)); 
                            }else if(caseEmail.contains(domain) && !(accountMap.containsKey(caseWithoutContactMap.get(caseEmail).EBS_Account_Number__c))){
                                newContact.AccountId = koozieGroupAccountId;
                            }else if(accountDomainMap.containsKey(caseWithoutContactMap.get(caseEmail).Supplied_Email_Domain__c)){
                                newContact.AccountId =  accountDomainMap.get(caseWithoutContactMap.get(caseEmail).Supplied_Email_Domain__c).Id;
                            }
                            else{
                                //newContact.AccountId =  caseWithoutContactMap.get(caseEmail).AccountId;
                                newContact.AccountId = orphanaccountId;
                                
                            }
                            
                            if(newContact.Email!=null && !duplicateCheckMap.containsKey(recordTypeID+newContact.Email+newContact.AccountId)){
                                duplicateCheckMap.put(recordTypeID+newContact.Email+newContact.AccountId,newContact);
                            }
                            System.debug('===== duplicateCheckMap ==='+duplicateCheckMap);
                           	insertContactList.add(newContact);
                            System.debug('========= newContact========'+newContact);
                        }
                    }
                }
                System.debug('========= insertContactList========'+insertContactList);
                if(insertContactList.size() > 0){
                    existingContactMap = foundExistingContact(insertContactList); 
                    System.debug('===existingContactMap==='+existingContactMap); //This is coming as null
                    if(duplicateCheckMap != null) {
                        for(Contact contactRecord : duplicateCheckMap.values()){
                            if(!existingContactMap.containsKey(recordTypeID+contactRecord.Email+contactRecord.AccountId)){
                                contactsToBeInserted.add(contactRecord);
                            }
                        }
                    }
                    if(contactsToBeInserted.size() > 0){
                        System.debug('=== contactsToBeInserted === '+contactsToBeInserted);
                        Database.Insert(contactsToBeInserted);
                    }
                   
                    for(Contact contactRecord : contactsToBeInserted){
                        
                        // Contact Role....
                        System.debug('======= contactRecord ====='+contactRecord);
                        Contact_Roles__c contactRoleRecord = new Contact_Roles__c();
                        contactRoleRecord.Contact__c = contactRecord.id;
                        
                        contactRoleRecord.Account__c = contactRecord.AccountId;  
                        
                        if(caseWithoutContactMap.get(contactRecord.Email).RecordtypeId == caseClarificationId){
                            contactRoleRecord.Contact_Role_Name__c = 'CLARIFICATIONS';
                        }else{
                            contactRoleRecord.Contact_Role_Name__c = 'SALES_SERVICE';
                        }
                        
                        System.debug('====== contactRoleRecord ===='+contactRoleRecord);                
                        insertContactRoleList.add(contactRoleRecord);
                        
                        
                        //Case Update....
                        Case tempCase = new Case();
                        tempcase.id = caseWithoutContactMap.get(contactRecord.Email).Id;
                        tempcase.contactId = contactRecord.Id; 
                        tempCase.accountId = contactRecord.AccountId; 
                        updateCaseList.add(tempcase); 
                    }
                    
                    System.debug('====== insertContactRoleList====='+insertContactRoleList.size());
                    
                    
                }
                
                System.debug('====== updateCaseList====='+updateCaseList.size());
                
                if(updateCaseList.size()>0){
                    System.debug('Case updated');
                    Database.update(updateCaseList);
                }
                
                if(updateContactList.size() > 0){
                    System.debug('Contact updated');
                    Database.Update(updateContactList);
                }
                
                if(insertContactRoleList.size() > 0){
                    Database.insert(insertContactRoleList);
                } 
                
            }
        } 
    }
    private static Map<String,Contact> foundExistingContact(List<Contact> newContactList){
        System.debug('Entered into this method');
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CRM Contact').getRecordTypeId();
        Set<Id> accountIds = new Set<Id>();
        Set<String> contactEmail = new Set<String>();
        Map<String,Contact> foundExistingContactMap = new Map<String,Contact>();
        for(Contact contactRecord : newContactList){
            if(contactRecord.AccountId!=null && contactRecord.Email!=null){
                accountIds.add(contactRecord.AccountId);
                contactEmail.add(contactRecord.Email);
                System.debug('===accountIds==='+accountIds);
                 System.debug('===contactEmail==='+contactEmail);
            }
        }
        if(!accountIds.isEmpty() && !contactEmail.isEmpty()){
            List<Contact> existingContactList = [SELECT Id,Email,AccountId FROM Contact WHERE AccountId IN: accountIds AND Email IN:contactEmail AND RecordTypeId =:RecordTypeId];
            System.debug('===existingContactList==='+existingContactList);
            for(Contact contactRecord: existingContactList){
                if(!foundExistingContactMap.containsKey(RecordTypeId+contactRecord.Email+contactRecord.AccountId)){
                    foundExistingContactMap.put(RecordTypeId+contactRecord.Email+contactRecord.AccountId,contactRecord);
                    System.debug('===foundExistingContactMap==='+foundExistingContactMap);
                }  
            } 
        }
        return foundExistingContactMap;
    }
}