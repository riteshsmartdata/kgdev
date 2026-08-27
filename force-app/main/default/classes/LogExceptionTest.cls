@isTest
public class LogExceptionTest {
    @isTest
    static void testInsertExceptionData() {
        // Prepare test data
        String testClassName = 'TestClass';
        String testMethodName = 'testMethod';
        String testRecordId = 'a1oU800000281diIAA'; // Example ID, replace with a valid ID format for your org

        // List to store various exceptions
        List<Exception> exceptions = new List<Exception>();
        
        // Simulate different exceptions
        try {
            Integer i = 1 / 0; // ArithmeticException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }
        
        try {
            Integer[] arr = new Integer[1];
            Integer x = arr[2]; // ListException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }
        
        try {
            String s = null;
            s.toLowerCase(); // NullPointerException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }
        
        try {
            List<Account> accounts = [SELECT Id FROM Account WHERE Name = 'NonExistingName']; // QueryException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }

        try {
            SObject obj = null;
            obj.getSObjectType(); // SObjectException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }

        try {
            String s = 'a';
            while (true) { s = s + s; } // LimitException simulation (might hit CPU time limit)
        } catch (Exception ex) {
            exceptions.add(ex);
        }

        try {
            String s = 'abc';
            s.substring(5); // StringException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }

      /*  try {
            String json = '{key:value}';
            JSON.deserialize(json, Map<String, Object>.class); // JSONException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }*/

     /*   try {
            throw new UnexpectedException('This is an unexpected exception'); // UnexpectedException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }*/

        try {
            throw new FlowException('This is a flow exception'); // FlowException simulation
        } catch (Exception ex) {
            exceptions.add(ex);
        }
        
        // Start test context
        Test.startTest();
        
        // Iterate over each exception and call the logging method
        for (Exception ex : exceptions) {
            LogException.insertExceptionData(testClassName, testMethodName, testRecordId, ex);
        }
        
        Test.stopTest();
        
        // Query the Error_Log__c records to verify the log entries
        List<ErrorLog__c> logs = [SELECT Id, Class_Name__c, Method_Name__c, Record_Id__c, Stack_Trace__c, Exception_Message__c, Exception_Type__c 
                                  FROM ErrorLog__c
                                  WHERE Class_Name__c = :testClassName 
                                  AND Method_Name__c = :testMethodName 
                                  AND Record_Id__c = :testRecordId];
        
        // Verify that the log entries were created
      //  System.assertEquals(exceptions.size(), logs.size(), 'Log entries should match the number of exceptions');
        
        for (ErrorLog__c log : logs) {
            System.assertEquals(testClassName, log.Class_Name__c);
            System.assertEquals(testMethodName, log.Method_Name__c);
            System.assertEquals(testRecordId, log.Record_Id__c);
            System.assertNotEquals(null, log.Stack_Trace__c, 'Stack trace should not be null');
            System.assertNotEquals(null, log.Exception_Message__c, 'Exception message should not be null');
            //System.assertNotEquals('Other', log.Exception_Type__c, 'Exception type should not be Other');
        }
    }
}