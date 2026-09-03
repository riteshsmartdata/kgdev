global class MergeDuplicateContactsVerifiedOffset implements Database.Batchable<sObject>,Database.stateful {
    
    Contact masterRecord;
    Integer batchSize = 0;
    set<string> accIds = new set<string>();
    global MergeDuplicateContactsVerifiedOffset(set<string> accId){
        accIds=accId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Finance Contact').getRecordTypeId(); 
        Id recTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IB Contact').getRecordTypeId(); 
        Set<Id> excludedRecordTypeIds = new Set<Id>{recTypeId, recTypeId1};
            set<string> emailset = new set<string>();
        set<string> accIDset = new set<string>();
        List<contact> conList = new List<Contact>();
        
        if(Test.isRunningTest()) {
            conList = [SELECT Id, Email, Phone,Mobile__c, AccountId, verified__c,
                       Date_Verified__c, MobilePhone  
                       FROM Contact 
                       where verified__c=true 
                       And Email !=null
                       And AccountId Not In: accIds
                       And RecordTypeId NOT IN  :excludedRecordTypeIds
                       order by  Date_Verified__c desc
                       limit 50000 ];
            
        } else {
            conList = [SELECT Id, Email, Phone,Mobile__c, AccountId, verified__c,
                       Date_Verified__c, MobilePhone  
                       FROM Contact 
                       where verified__c=true 
                       And Email !=null
                       And AccountId Not In: accIds
                       And RecordTypeId NOT IN  :excludedRecordTypeIds
                       AND Date_Verified__c =   Today
                       AND Date_Verified__c < Tomorrow
                       order by  Date_Verified__c desc
                       limit 50000 ];
        }
        
        
        for(contact con:conList){
            accIDset.add(con.AccountId);
            emailset.add(con.Email);
        }
        
        // Binding Dynmic Query
        String soqlQuery = 'SELECT Id, Email, Phone,Mobile__c, MobilePhone, AccountId, verified__c FROM Contact '; 
        soqlQuery+= 'Where Email in: emailset    And AccountId in: accIDset  And RecordTypeId NOT IN  :excludedRecordTypeIds ' ;
        
        return Database.getQueryLocator(soqlQuery);
        
    }
    
    global void execute(Database.BatchableContext ctx, List<Contact> ContactList) { 
        
        if (ContactList.isEmpty()) 
        {
            return;
        }
        
        Map<String, List<Contact>> accContactMap = new Map<String, List<Contact>>();
        
        Map<Id, Contact> validContactMap = new Map<Id, Contact>();            
        Set<Id> contactIds = new Set<Id>();
        for (Contact contact : ContactList) 
        {
            contactIds.add(contact.Id);
        }
        List<Contact> validContacts = [SELECT Id, Email, Phone,Mobile__c, MobilePhone, AccountId,
                                       verified__c FROM Contact 
                                       WHERE Id IN :contactIds
                                       Order by Date_Verified__c Desc];  
        
        for (Contact contact : validContacts) 
        {
            validContactMap.put(contact.Id, contact);
        }
        
        for (Contact contact : validContactMap.values()) 
        {       String email = contact.Email.toLowerCase().trim();
         string accountId=contact.AccountId;
         string key= email+accountId;
         if (!accContactMap.containsKey(key)) 
         {
             accContactMap.put(key, new List<Contact>());
         }
         accContactMap.get(key).add(contact);
        }            
        
        List<Contact> remainingRecordsBatch = new List<Contact>();  
        
        for (List<Contact> duplicateRecords : accContactMap.values()) {
            List<Contact> remainingDuplicateRecords = new List<Contact>(); 
            masterRecord = null;
            for (Contact record : duplicateRecords) 
            {
                if (record.verified__c==true) 
                {
                    masterRecord=record;
                    break;
                }
            }
            if (masterRecord != null) 
            {
                for (Contact record : duplicateRecords) {
                    
                    if(record.Id != masterRecord.Id){
                        remainingDuplicateRecords.add(record);
                        
                        if(String.isNotBlank(record.Phone) || String.isNotBlank(record.MobilePhone))
                        {
                            if ( String.isBlank(masterRecord.Phone) || String.isBlank(masterRecord.MobilePhone)) 
                            {
                                contact contPhoneUpdate= record;
                                // Update the master record's fields with data from the losing record
                                masterRecord.Phone = contPhoneUpdate.Phone;
                                if(masterRecord.Mobile__c==true)
                                {
                                    masterRecord.MobilePhone = contPhoneUpdate.MobilePhone;
                                } 
                            } 
                        }
                    }
                }
                
                for (Contact remainingRecord : remainingDuplicateRecords) 
                {
                    if(!remainingRecordsBatch.contains(remainingRecord))
                    {
                        remainingRecordsBatch.add(remainingRecord);
                        batchSize++;
                        if (batchSize == 2) 
                        {
                            mergeRecordsWithMaster(masterRecord, remainingRecordsBatch);
                            batchSize=0; 
                            remainingRecordsBatch.clear();
                        }
                    }
                }
                
                if (!remainingRecordsBatch.isEmpty()) 
                {
                    mergeRecordsWithMaster(masterRecord, remainingRecordsBatch);
                    remainingRecordsBatch.clear();
                    batchSize=0;  
                }
            } 
        }
    }
    
    
    global void finish(Database.BatchableContext bc) 
    {
        
    }
    
    
    // Method to handle the merge operation with error handling
    public void mergeRecordsWithMaster(Contact master, List<Contact> recordsToMerge) 
    {
        
        if(Limits.getDMLStatements() == Limits.getLimitDMLStatements()){
            return;
        }
        
        if (master != null && !recordsToMerge.isEmpty()) 
        {
            Database.MergeResult[] mergeResults = Database.merge(master, recordsToMerge, false);
            
            if (mergeResults[0].isSuccess()) 
            {
                System.debug('Merge successful');
            } 
            else 
            {
                for (Database.Error error : mergeResults[0].getErrors()) 
                {
                    System.debug('Merge Error: ' + error.getMessage());
                }
            }  
        }
    }  
}