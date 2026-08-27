global class updateContactsSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Schedule the batch job with a new instance of updateContacts class
        updateContactAddress batchJob = new updateContactAddress();
        Database.executeBatch(batchJob);
    }
}