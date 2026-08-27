global class CaseHolidayScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CaseHolidayHoursBatch batch = new CaseHolidayHoursBatch();
        Database.executeBatch(batch);    
    }
}