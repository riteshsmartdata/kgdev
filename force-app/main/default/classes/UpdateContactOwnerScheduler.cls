global class UpdateContactOwnerScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Integer batchSize = 200;
        UpdateContactOwner batch = new UpdateContactOwner();
        Database.executeBatch(batch, batchSize);
    }
}