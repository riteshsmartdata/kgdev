public with sharing class ObjectRecordTypeController {
    @AuraEnabled(cacheable=true)
    public static List<ObjectOptions> getObjectOptions() {
        List<ObjectOptions> objectList = new List<ObjectOptions>();
        
        objectList.add(new ObjectOptions('Account', 'Account'));
        objectList.add(new ObjectOptions('Contact', 'Contact'));
        objectList.add(new ObjectOptions('Opportunity', 'Opportunity'));
        
        return objectList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RecordTypeOptions> getRecordTypesByObject(String objectName) {
        List<RecordTypeOptions> recordTypeList = new List<RecordTypeOptions>();
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        
        List<Schema.RecordTypeInfo> recordTypes = describeResult.getRecordTypeInfos();
        for (Schema.RecordTypeInfo recordType : recordTypes) {
            recordTypeList.add(new RecordTypeOptions(recordType.getName(), recordType.getRecordTypeId()));
        }
        return recordTypeList;
    }
    
    public class ObjectOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public ObjectOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    public class RecordTypeOptions {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public RecordTypeOptions(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
    public static List<sObject> duplicateEmail(String objectName, String recordTypeId, Integer yearOffset){
        System.debug('objName: ' + objectName) ;
        System.debug('recordtypename: ' + recordTypeId) ;
        List<sObject> duplicateRecords = new List<sObject>();
        
        //Date yearAgo = Date.today().addYears(yearOffset);
        
        Date startDate = Date.newInstance(yearOffset, 1, 1); // Start of the year
        Date endDate = Date.newInstance(yearOffset, 12, 31);
        // System.debug('year' + yearAgo);
        String query = 'SELECT Id, ';
        String whereCondition = 'WHERE RecordTypeId = :recordTypeId AND CreatedDate >= :startDate AND CreatedDate <= :endDate ';
        
        if (objectName == 'Contact') {
            query += ' Email, Contact_Status__c, FirstName, LastName, Contact_Domain__c,RecordTypeId,Web_Id__c,Verified__c,LastModifiedDate,CreatedDate,AccountId,Account.Name ';
            whereCondition += ' AND Email != NULL';
        } else if (objectName == 'Account') {
            query += ' Primary_Team_Member_Email__c ';
            whereCondition += ' AND Primary_Team_Member_Email__c != NULL';
        }
        
        query += ' FROM ' + objectName + ' ' + whereCondition;
        
       query += ' LIMIT 50000 '; 
        
        //String query = 'SELECT Id, Email FROM ' + objectName + ' WHERE RecordTypeId = :recordTypeId AND Email != NULL AND CreatedDate >= :yearAgo';
        
        List<sObject> queryData = Database.query(query);
        System.debug('Query Size: ' + queryData.size());
        System.debug('contacts-->' + queryData) ;
        
        Map<String ,Integer> emailCountMap = new Map<String, Integer>();
        Map<String, List<sObject>> emailToContactsMap = new Map<String, List<sObject>>();
        
        for(sObject data : queryData){
            if(emailCountMap.containskey((String)data.get('Email'))){
                emailCountMap.put((String)data.get('Email'), emailCountMap.get((String)data.get('Email')) + 1);
            }else{
                emailCountMap.put((String)data.get('Email'), 1);
            }
            
            if(emailToContactsMap.containskey((String)data.get('Email'))){
                emailToContactsMap.get((String)data.get('Email')).add(data);
            }else{
                emailToContactsMap.put((String)data.get('Email'), new List<sObject>{data});
            }
        }
        
        System.debug('Email Counts: ' + emailCountMap);
        
        Map<String, Integer> duplicateEmailsToFind = new Map<String, Integer>();
        for (String email : emailCountMap.keySet()) {
            if (emailCountMap.get(email) > 1) {
                //duplicateEmailsToFind.put(email, emailCountMap.get(email));
                duplicateRecords.addAll(emailToContactsMap.get(email));
            }
        }
        System.debug('duplicateRecords' + duplicateRecords);
        
        return duplicateRecords;
        
    }
    
    @AuraEnabled
    public static List<sObject> getFilteredRecords(String objectName, String recordTypeId, Integer yearOffset,  List<Id> excludeIds ){
        System.debug('objName: ' + objectName) ;
        System.debug('recordtypename: ' + recordTypeId) ;
        List<sObject> duplicateRecords = new List<sObject>();
        
        //Date yearAgo = Date.today().addYears(yearOffset);
        
        Date startDate = Date.newInstance(yearOffset, 1, 1); // Start of the year
        Date endDate = Date.newInstance(yearOffset, 12, 31);
        // System.debug('year' + yearAgo);
        String query = 'SELECT Id, ';
        String whereCondition = 'WHERE RecordTypeId = :recordTypeId AND CreatedDate >= :startDate AND CreatedDate <= :endDate And Id NOT IN : excludeIds ';
        
        if (objectName == 'Contact') {
            query += ' Email, Contact_Status__c, FirstName, LastName, Contact_Domain__c,RecordTypeId,Web_Id__c,Verified__c,LastModifiedDate,CreatedDate,AccountId,Account.Name ';
            whereCondition += ' AND Email != NULL';
        } else if (objectName == 'Account') {
            query += ' Primary_Team_Member_Email__c  ';
            whereCondition += ' AND Primary_Team_Member_Email__c != NULL';
        }
        
        query += ' FROM ' + objectName + ' ' + whereCondition ;
        
        query += ' LIMIT 50000 ';
        
        //String query = 'SELECT Id, Email FROM ' + objectName + ' WHERE RecordTypeId = :recordTypeId AND Email != NULL AND CreatedDate >= :yearAgo';
        
        List<sObject> queryData = Database.query(query);
        
        System.debug('contacts: ' + queryData) ;
        
        Map<String ,Integer> emailCountMap = new Map<String, Integer>();
        Map<String, List<sObject>> emailToContactsMap = new Map<String, List<sObject>>();
        
        for(sObject data : queryData){
            if(emailCountMap.containskey((String)data.get('Email'))){
                emailCountMap.put((String)data.get('Email'), emailCountMap.get((String)data.get('Email')) + 1);
            }else{
                emailCountMap.put((String)data.get('Email'), 1);
            }
            
            if(emailToContactsMap.containskey((String)data.get('Email'))){
                emailToContactsMap.get((String)data.get('Email')).add(data);
            }else{
                emailToContactsMap.put((String)data.get('Email'), new List<sObject>{data});
            }
        }
        
        Map<String, Integer> duplicateEmailsToFind = new Map<String, Integer>();
        for (String email : emailCountMap.keySet()) {
            if (emailCountMap.get(email) > 1) {
                //duplicateEmailsToFind.put(email, emailCountMap.get(email));
                duplicateRecords.addAll(emailToContactsMap.get(email));             
            }
        }
        System.debug('duplicateRecords' + duplicateRecords);
        
        return duplicateRecords;
        
    }
}