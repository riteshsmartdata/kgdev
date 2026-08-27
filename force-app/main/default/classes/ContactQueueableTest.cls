/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-13-2023   Ritesh Kumar   Initial Version
**/
@IsTest 
public without sharing class ContactQueueableTest {

    @IsTest
    static void queueableTest() {
        
        Test.startTest();
        Id jobId = System.enqueueJob(new ContactQueueable());
        System.assertEquals(TRUE,String.isNotBlank(jobId));
        Test.stopTest();
    }

}