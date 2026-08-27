global with sharing class AggregateResultIterator implements Iterator<AggregateResult>{
    AggregateResult [] results {get;set;}
    Integer index {get; set;}   
    private Id CRM_CONTACT = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');   
    global AggregateResultIterator(String query) {
        index = 0;
        results = Database.query(query);            
    } 
    global boolean hasNext(){ 
        return results != null && !results.isEmpty() && index < results.size(); 
    }    
    global AggregateResult next(){        
        return results[index++];            
    }       
}