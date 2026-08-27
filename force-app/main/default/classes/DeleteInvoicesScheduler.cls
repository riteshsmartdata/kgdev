public class DeleteInvoicesScheduler implements Schedulable {
    
    public void execute(SchedulableContext SC) {
        DeleteInvoicesBatch batch = new DeleteInvoicesBatch();
        Database.executeBatch(batch, 200); 
    }
}