/**
 * @description       : 
 * @author            : Saxena Anubhav
 * @group             : 
 * @last modified on  : 29-11-2023
 * @last modified by  : Saxena Anubhav
**/
@IsTest
public with sharing class UpdateClarLinkOnlineProofURL_Test {

    private static FINAL Id clarificationQuestionRecordTypeId = getRecordTypeId('ClarificationQuestion');
    private static FINAL Id proofQuestionRecordTypeId = getRecordTypeId('ProofQuestion');

    @TestSetup
    private static void createCaseTestData(){
        EBS_Order__c ebsOrdertestRecord = new EBS_Order__c(order_type__c='Sample Fullfillment',City__c='Happy Town',Tracking_Link_NoPricing__c='https://www.KoozieEBSTest.com');
        INSERT ebsOrdertestRecord;
        Case caseTestRecord = new Case(EBS_Order__c=ebsOrdertestRecord.Id,Status='Awaiting Clarification Response',Origin='Ebs Clarification');
        INSERT caseTestRecord;
    }

    @IsTest
    private static void updateClarProofUrlOnCaseTest(){
        List<Case> caseTestRecordList = [SELECT Id,Status,Origin,Clar_Link__c,Proof_Clar_Link_URL__c FROM Case LIMIT 1];

        Clarification_Question__c clarificationQuestionTestRecord = new Clarification_Question__c(Case__c=caseTestRecordList.get(0).Id,RecordTypeId=clarificationQuestionRecordTypeId,Status__c='Open');
        INSERT clarificationQuestionTestRecord;

        Clarification_Question__c proofQuestionTestRecord1 = new Clarification_Question__c(Case__c=caseTestRecordList.get(0).Id,RecordTypeId=proofQuestionRecordTypeId,Status__c='Open',Online_Proof_URL__c='https://KoozieTest1.com');
        INSERT proofQuestionTestRecord1;
        Clarification_Question__c proofQuestionTestRecord2 = new Clarification_Question__c(Case__c=caseTestRecordList.get(0).Id,RecordTypeId=proofQuestionRecordTypeId,Status__c='Open',Online_Proof_URL__c='https://KoozieTest2.com');
        INSERT proofQuestionTestRecord2;

        List<Case> updatedCaseRecord = [SELECT Id,Status,Origin,Clar_Link__c,Proof_Clar_Link_URL__c,Count_Open_Clarification_Questions__c,Count_Open_EProof_Questions__c FROM Case LIMIT 1];
        Assert.isNotNull(updatedCaseRecord.get(0).Clar_Link__c); 
        Assert.isNotNull(updatedCaseRecord.get(0).Proof_Clar_Link_URL__c,'Proof Clar Link URL is Null');
    }
    
    private static Id getRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Clarification_Question__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
}