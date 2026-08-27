public class LogException extends Exception {
    // Insert exception-related data into Error_Log__c for logging and tracking purposes
    public static void insertExceptionData(String className, String methodName, String recordId, Exception ex) {
        try {
            ErrorLog__c logger = new ErrorLog__c();
            logger.Stack_Trace__c = ex.getStackTraceString();
            logger.Class_Name__c = className;
            logger.Method_Name__c = methodName;
            logger.Exception_Message__c = ex.getMessage();
            
            // Set the Exception Type picklist value
            logger.Exception_Type__c = getExceptionType(ex);
            
            if (!String.isBlank(recordId)) {
                logger.Record_Id__c = recordId;
            }
            insert logger;
            System.debug('ErrorLog__c record inserted successfully');
        } catch (Exception e) {
            System.debug('Exception occurred while inserting exception data: ' + e.getMessage());
        }
    }
    
    // Determine the exception type as a string
    private static String getExceptionType(Exception ex) {
        if (ex instanceof DmlException) {
            return 'DmlException';
        } else if (ex instanceof System.FinalException) {
            return 'System.FinalException';
        } else if (ex instanceof ListException) {
            return 'ListException';
        } else if (ex instanceof NullPointerException) {
            return 'NullPointerException';
        } else if (ex instanceof QueryException) {
            return 'QueryException';
        } else if (ex instanceof SObjectException) {
            return 'SObjectException';
        } else if (ex instanceof LimitException) {
            return 'LimitException';
        } else if (ex instanceof StringException) {
            return 'StringException';
        } else if (ex instanceof JSONException) {
            return 'JSONException';
        } else if (ex instanceof UnexpectedException) {
            return 'UnexpectedException';
        } else if (ex instanceof FlowException) {
            return 'FlowException';
        } else {
            return 'Other';
        }
    }
}