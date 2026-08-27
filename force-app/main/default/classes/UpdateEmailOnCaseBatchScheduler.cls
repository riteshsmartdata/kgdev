global class UpdateEmailOnCaseBatchScheduler implements Schedulable{
global void execute(SchedulableContext SC) {
      UpdateEmailOnCaseBatch b = new UpdateEmailOnCaseBatch(); //ur batch class
      database.executebatch(b,10);
   }
}