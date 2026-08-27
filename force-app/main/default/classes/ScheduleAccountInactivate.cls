global class ScheduleAccountInactivate implements Schedulable {
   global void execute(SchedulableContext SC) {
      AccountInactivate_Batch M = new AccountInactivate_Batch(); 
   }
}