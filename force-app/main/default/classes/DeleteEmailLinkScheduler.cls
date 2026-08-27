global class DeleteEmailLinkScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        // Call the batch class from the scheduler
        deleteEmailLink batch  = new deleteEmailLink();
        Database.executeBatch(batch );
    }
    
}