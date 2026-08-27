/**
 * @description       : 
 * @author            : Mohammad Arafat Ali
 * @group             : 
 * @last modified on  : 04-28-2023
 * @last modified by  : Mohammad Arafat Ali
**/
@isTest
public class ApexLogUtillTest {

    @isTest
    public static void createApexLog_TestUnit(){
        Test.startTest();        
        ApexLogUtill.createApexLog('Website', '{"Test":"Test"}', '{"StatusCode":"202"}', '000000000000ABX', 'Contact', 'API Errore', 202);  
        Apex_Errors__c errorLog = ApexLogUtill.assignApexLog('Website', '{"Test":"Test"}', '{"StatusCode":"202"}', '000000000000ABX', 'Contact', 'API Errore', 202);      
        Test.stopTest();
        
    }
    
     @isTest
    public static void createApexLogs_TestUnit(){
        List<LogInput> LogInputList = new List<LogInput>();
        
        LogInput errorLog_A = new LogInput();
        errorLog_A.objectName = 'Contact';
        errorLog_A.recordId='003XXXXXXXXXASD';
        errorLog_A.requestBody = 'Test A';
        errorLog_A.source='Test Class A';
        errorLog_A.statusCode = 202;
        LogInputList.add(errorLog_A);
        
        LogInput errorLog_B = new LogInput();
        errorLog_B.objectName = 'Contact';
        errorLog_B.recordId='003XXXXXXXXXASF';
        errorLog_B.requestBody = 'Test B';
        errorLog_B.source='Test Class B';
        errorLog_B.statusCode = 202;
        LogInputList.add(errorLog_A);
        
        
        
        Test.startTest();        
        ApexLogUtill.createApexLogs(LogInputList);
        Test.stopTest();
        
    }
}