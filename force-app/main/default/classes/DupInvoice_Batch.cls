public class DupInvoice_Batch implements Database.Batchable<sObject>,Database.Stateful {
    public Integer[] Year;
    
    public DupInvoice_Batch(Integer[] Year){
        this.Year=Year;
    }
    
    string YearlyMode;
    public DupInvoice_Batch(String YearlyMode){
        this.YearlyMode=YearlyMode;
    }
    
    
    //Public Map<String,Invoice__c> invoiceMap = new Map<String,Invoice__c>();
    
    Public set <string> uniqueInvoice=new set <string>();
    
    
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(YearlyMode=='All'){
            set<string>aggResult = DupInvoice_Batch.getAggresult();     
            return Database.getQueryLocator([SELECT Id, Invoice_Number__c, CreatedDate FROM Invoice__c 
                                             WHERE  Invoice_Number__c IN:aggResult Order By Createddate DESC
                                            ]);
        }
        else{
            return Database.getQueryLocator([SELECT Id, Invoice_Number__c, CreatedDate FROM Invoice__c 
                                             WHERE CALENDAR_YEAR(CreatedDate) IN:Year AND Invoice_Number__c!=null 
                                             Order By Createddate DESC
                                            ]);
        }
        
    }
    
    public void execute (Database.Batchablecontext Bc, list<Invoice__c>scope)
    {
        system.debug('scope'+scope);
        system.debug('scope.size'+scope.size());
        List<Invoice__c> invListUpd= new List<Invoice__c>();
        
        for(Invoice__c inv:scope){
            //  if(invoiceMap.containsKey(inv.Invoice_Number__c)){
            if(uniqueInvoice.contains(inv.Invoice_Number__c)){
                invListUpd.add(inv);
            }
            else{
                // invoiceMap.put(inv.Invoice_Number__c,inv); 
                uniqueInvoice.add(inv.Invoice_Number__c);
            }
            
        }
        System.debug('invListUpd'+invListUpd);
        
        if(invListUpd.size()>0){
             Database.delete(invListUpd,false);
        }
    }
    Public void finish (Database.BatchableContext bc){
        
    }
    
    private static set<string> getAggresult(){
        set<String>invoiceNum=new set<String>();
        
        List<AggregateResult>aggResult= [SELECT count(Id), Invoice_Number__c FROM Invoice__c group by Invoice_Number__c  having count(Id)>1 Limit 2000];
        for(AggregateResult agg:aggResult){
            invoiceNum.add((string)agg.get('Invoice_Number__c'));
        }
        return invoiceNum;
        
    }
}