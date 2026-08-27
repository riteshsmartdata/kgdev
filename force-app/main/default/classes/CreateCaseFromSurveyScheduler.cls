global class CreateCaseFromSurveyScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new CreateCaseFromSurveyQueueable());
    }
}