public class ScheduleMergeContactsVerified implements Schedulable{
    
	public void execute(SchedulableContext sc) {
        Database.executeBatch(new MergeDuplicateContactsVerified(), 150);
    }
}