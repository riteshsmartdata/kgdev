public class deleteApexErrorSchedule implements Schedulable {
 public void execute(SchedulableContext sc)
    {
        deleteApexErrorBatch b = new deleteApexErrorBatch ();
        database.executebatch(b,200);
    }
}