/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 11-13-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   11-10-2023   Ritesh Kumar   Initial Version
**/
public without sharing class ContactQueueable implements Queueable {
    final static public String CONTACT_SYN_BATCH = 'ContactSynBatch';
    final static public String BATCH_APEX = 'BatchApex';
    
    public void execute(QueueableContext context) {
        if(! KoozieUtility.isAsyncApexRunning(CONTACT_SYN_BATCH, BATCH_APEX)){
            Id jobIdVariable = Database.executeBatch(new ContactSynBatch() , 1);
            //System.debug(LoggingLevel.INFO,'==== ContactQueueable : Batch ID : '+jobIdVariable);
        }     
    }
}