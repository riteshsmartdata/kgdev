@isTest
private class ContactCalloutEventTriggerTest {

    @TestSetup
    static void setupData() {
        N8N_Integration_Settings__c settings = new N8N_Integration_Settings__c(
            SetupOwnerId = UserInfo.getOrganizationId(),
            Allow_Apex_N8n_Integration__c = true
        );
        insert settings;
    }

    @isTest
    static void testTrigger_QueueableEnqueued() {

        Test.startTest();

        WebsiteDataSync__e eventObj = new WebsiteDataSync__e(
            Record_Id__c = 'Test Event' 
        );

        Database.SaveResult sr = EventBus.publish(eventObj);
        Test.stopTest();
    }

    @isTest
    static void testTrigger_IntegrationDisabled() {

        N8N_Integration_Settings__c settings = N8N_Integration_Settings__c.getOrgDefaults();
        settings.Allow_Apex_N8n_Integration__c = false;
        update settings;

        Test.startTest();

        WebsiteDataSync__e eventObj = new WebsiteDataSync__e(
            Record_Id__c = 'Test Event'
        );

        Database.SaveResult sr = EventBus.publish(eventObj);

        Test.stopTest();
    }
}