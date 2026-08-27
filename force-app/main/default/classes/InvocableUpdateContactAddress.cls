public class InvocableUpdateContactAddress {
    @InvocableMethod(label='Update Contact Addresses' description='Invokes the UpdateContactAddressBatch')
    public static void invokeBatch(List<String> accountIds) {
        system.debug('accountIds@@@@@@@@@@@@@@'+accountIds);
        if (accountIds != null && !accountIds.isEmpty()) {
            // Instantiate the batch class with the provided accountIds
            UpdateContactAddressBatch batchJob = new UpdateContactAddressBatch(accountIds);
            // Start the batch job
            Database.executeBatch(batchJob);
        }
    }
    
}