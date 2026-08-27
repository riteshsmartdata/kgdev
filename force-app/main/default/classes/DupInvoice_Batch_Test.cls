@isTest
public class DupInvoice_Batch_Test {
    
  @isTest
    public static void method1(){
        Integer[] testYear = new Integer[] {2025};
        string YearlyMode='All';

       List<Invoice__c> dupInvoices = new List<Invoice__c>();
        for (Integer i = 0; i < 3; i++) {
            dupInvoices.add(new Invoice__c(Invoice_Number__c = '1234'));
        }
        insert dupInvoices;
        
          Test.startTest();
        DupInvoice_Batch batch = new DupInvoice_Batch(YearlyMode);
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
         // Fetch updated invoices
        List<Invoice__c> results = [
            SELECT Id, Invoice_Number__c
            FROM Invoice__c
            WHERE Invoice_Number__c = '1234'
        ];

      

        // Assertions
      System.assertEquals(1, results.size(), 'Duplicate Deleted');
      
    }

    }