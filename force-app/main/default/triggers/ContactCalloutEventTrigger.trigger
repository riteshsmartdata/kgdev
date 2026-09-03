/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-03-2025      Initial Version
**/
trigger ContactCalloutEventTrigger on WebsiteDataSync__e (after insert) {

    N8N_Integration_Settings__c settings = N8N_Integration_Settings__c.getOrgDefaults();
    Boolean allowApexN8nIntegration = (settings != null && settings.Allow_Apex_N8n_Integration__c == true);

    for (WebsiteDataSync__e eventRecord : Trigger.new) {

        if (allowApexN8nIntegration) {
            System.enqueueJob(new WebsiteContactSync(eventRecord));
        } 
    }
}