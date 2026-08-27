global class LeadTimeAutomation_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        LeadTimeAutomation_Batch lta = new LeadTimeAutomation_Batch();
        Database.executebatch(lta,5);
    }
}