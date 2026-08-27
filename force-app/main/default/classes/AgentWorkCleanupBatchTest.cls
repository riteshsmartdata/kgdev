/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-31-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest//(SeeAllData=true)
public class AgentWorkCleanupBatchTest {

    @isTest
    public static void agentwork(){
        //Insert Account
        Account acc = new Account();
        acc.Name = 'test';
        acc.Customer_Account_Number__c = '12345544548455';
        acc.Customer_Category__c = 'Hotel'; 
        insert acc;

        //Insert Account_Clarification_Team__c 
        Account_Clarification_Team__c act = new Account_Clarification_Team__c();
        act.Name = 'Elite 801 Proforma';
        act.From_Email__c = 'cshotel@kooziegroup.com';
        act.EBS_Num__c = '12345';
        act.Customer_Category__c = 'Hotel';
        insert act;

        Case css = new Case(); 
        css.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Clarification').getRecordTypeId();
        css.EBS_Account_Number__c ='12345';
        css.Status = 'New';
        css.Origin = 'ASI Rating';
        insert css; 

        User systemUser = new User();
        systemUser.Id = system.UserInfo.getUserId();

        System.runAs(systemUser){
            AgentWork awork = new AgentWork();
                for (ServiceChannel  sc : [select Id from ServiceChannel LIMIT 10]){ 
                    try{
                        awork.CreatedDate = System.Today().addDays(-400); 
                        awork.ServiceChannelId = sc.id;
                        awork.UserId = systemUser.id;  
                        insert awork;  
                        awork.WorkItemId = css.Id;
                        Update awork;
                        break;

                    }catch(Exception ex){
                        System.debug(LoggingLevel.INFO, 'Service channel with id '+sc.Id+' is invalid');
                    }
                    
                }
        }

        Test.StartTest(); 
            database.executeBatch(new AgentWorkCleanup_Batch(),200);        
        Test.stopTest();   
        AgentWorkCleanup_Batch.codeCoverage();
    } 
   
}