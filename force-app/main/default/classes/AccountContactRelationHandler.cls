public with sharing class AccountContactRelationHandler extends TriggerHandler {
    
    private List<AccountContactRelation> newRecords;
    private Map<Id,AccountContactRelation> oldRecords;
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('AccountContactRelation');
    
    public AccountContactRelationHandler(String className){
        this.newRecords = (List<AccountContactRelation>) Trigger.new;
        this.oldRecords = (Map<Id,AccountContactRelation>) Trigger.oldMap; 
    }
    
    public override void afterInsert() {
        
        List<String> recordIds = new List<String>();
        Set<Id> accountInfo = new Set<Id>();
        Set<Id> accountWithNull = new Set<Id>();
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        
        for(AccountContactRelation record : newRecords){
            if(String.isNotBlank(record.AccountId)){
                accountInfo.add(record.AccountId);
            }
        }
        System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterInsert: AccountInfo Ids: ' + accountInfo);

        if(accountInfo.size() > 0){
            accountWithNull = getAccountInfo(accountInfo);
        }

        System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterInsert: accountWithNull Ids: ' + accountWithNull);

        for(AccountContactRelation record : newRecords){
            System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler record.AccountId: ' + record.AccountId + ' Null check :'+(!accountWithNull.contains(record.AccountId)));
            if(String.isNotBlank(record.AccountId) && (!accountWithNull.contains(record.AccountId))){
                recordIds.add(record.Id);
            }
        }
        
        if(recordIds.isEmpty()){
            return;
        }
        
        System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterInsert: recordIds: ' + recordIds);
        sendContactRelation(recordIds); 
    }
    
    public override void afterUpdate(){
        
        List<String> recordIds = new List<String>();
        Set<Id> accountInfo = new Set<Id>();
        Set<Id> accountWithNull = new Set<Id>();

        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        
        for(AccountContactRelation record : newRecords){
            if(String.isNotBlank(record.AccountId)){
                accountInfo.add(record.AccountId);
            }
        }
        System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterUpdate: AccountInfo Ids: ' + accountInfo);

        if(accountInfo.size() > 0){
            accountWithNull = getAccountInfo(accountInfo);
        }

        System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterUpdate: accountWithNull Ids: ' + accountWithNull);
        
        for(AccountContactRelation record : newRecords){
            System.debug(LoggingLevel.INFO, 'AccountContactRelationHandler afterUpdate record.AccountId: ' + record.AccountId + ' Null check :'+(!accountWithNull.contains(record.AccountId)));
            if(record.webId__c == oldRecords.get(record.Id).webId__c && String.isNotBlank(record.AccountId) && (!accountWithNull.contains(record.AccountId))){
                recordIds.add(record.Id);
            } 
        }
        
        if(recordIds.isEmpty()){
            return;
        }
        
        sendContactRelation(recordIds);
    }
    
    @future(callout=true)
    public static void sendContactRelation(List<String> recordIds){
        List<AccountContactRelation> relationRecors = new List<AccountContactRelation>();
        if(recordIds.isEmpty()){
            return;
        }
        
        AccountContactRelation [] relations =  [
            SELECT 
                Id, Account.Name, Account.Customer_Account_Number__c, AccountId, ContactId, Contact.FirstName, Contact.LastName, 
                Contact.Email, IsActive, StartDate,EndDate, Roles,WebId__c,IsDirect, Relationship_Strength__c,CreatedDate
            FROM 
                AccountContactRelation
            WHERE
                Id IN: recordIds
            LIMIT 50000
        ];
        
        if(relations.isEmpty()){
            return;
        }
        
        for(AccountContactRelation record :relations ){
            String JSON = AccountContactRelationJSON.relationJSON(record).getAsString();
            AccountContactRelation acr = WebsiteContacRelationSync.contactRelationSync(JSON, record.Id);
            if(acr != null){
                relationRecors.add(acr);
            }
        }
        
        if(relationRecors.isEmpty()){
            return;
        }
        Database.update(relationRecors, FALSE);
    }

    private Set<Id> getAccountInfo(Set<Id> accountIds){
        Set<Id> accountInfo = new Set<Id>();
        if(accountIds == null || accountIds.isEmpty()){
            return accountInfo;
        }
        for(Account acc : [ SELECT Id FROM Account WHERE Id IN :accountIds AND Customer_Account_Number__c = NULL LIMIT 50000]){
            accountInfo.add(acc.Id);
        }
        return accountInfo;
    }
    
    
}