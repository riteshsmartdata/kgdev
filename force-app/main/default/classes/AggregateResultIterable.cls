global class AggregateResultIterable implements Iterable<AggregateResult> {
    private String query;
    private Id CRM_CONTACT = KoozieUtility.getRecordTypeId('Contact', 'CRM Contact');
    global AggregateResultIterable(String soql){
        query = soql;
    }
    global Iterator<AggregateResult> Iterator(){
        return new AggregateResultIterator(query);
    }
}