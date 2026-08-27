public class BatchExecutionHelper {
    public static Boolean isBatchRunning = false;
    
    // Store Last Processed Date
    private static DateTime lastProcessedDate; 
    public static Set<Id> processedContactIds = new Set<Id>();  
    
    //  Method to Update Last Processed Date
    public static void updateLastProcessedDate(DateTime processedDate) {
        lastProcessedDate = processedDate;
    }
    //  Method to Retrieve Last Processed Date
    public static DateTime getLastProcessedDate() {
        return lastProcessedDate != null ? lastProcessedDate : DateTime.newInstance(1900, 1, 1, 0, 0, 0);  
    }
}