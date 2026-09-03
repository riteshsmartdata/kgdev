global class MergeDuplicateContactsWeekend implements Database.Batchable<String>,Database.Stateful, Schedulable {

    /* =========================================================
       START – FIND DUPLICATE (Email + Account) GROUPS
       ========================================================= */
    global Iterable<String> start(Database.BatchableContext bc) {

        Set<String> keys = new Set<String>();
        
        for (AggregateResult ar : [
            SELECT Email e, AccountId a
            FROM Contact
            WHERE Email != NULL
            AND AccountId != NULL
            AND RecordType.DeveloperName = 'CRM_Contact'
            GROUP BY Email, AccountId
            HAVING COUNT(Id) > 1
        ]) {
            keys.add((String) ar.get('e') + '||' + (String) ar.get('a'));
        }
        
        
        System.debug('Duplicate groups found: ' + keys.size());
        return keys;
    }

    /* =========================================================
       EXECUTE – MERGE PER (EMAIL + ACCOUNT)
       ========================================================= */
    global void execute(Database.BatchableContext bc, List<String> scope) {
        for (String key : scope) {
            
            List<String> parts = key.split('\\|\\|');
            
            if (parts.size() < 2 || String.isBlank(parts[1]) || parts[1] == 'null') {
                System.debug('Skipping invalid key: ' + key);
                continue;
            }
            
            String email = parts[0];
            Id accountId;
            
            try {
                accountId = (Id) parts[1];
            } catch (Exception e) {
                System.debug('Invalid AccountId in key: ' + key);
                continue;
            }


            System.debug('Processing: ' + email + ' | ' + accountId);

            List<Contact> contacts = [
                SELECT Id,
                       Email,
                       AccountId,
                       Web_Id__c,
                       Verified__c,
                       Contact_Status__c,
                       LastModifiedDate
                FROM Contact
                WHERE Email = :email
                  AND AccountId = :accountId
                  AND RecordType.DeveloperName = 'CRM_Contact'
                ORDER BY LastModifiedDate DESC
            ];

            System.debug('   Contacts found: ' + contacts.size());

            if (contacts.size() < 2) continue;

            /* =================================================
               MASTER SELECTION
               ================================================= */
            Contact master = contacts[0];

            for (Contact c : contacts) {

                if (c.Web_Id__c != null && master.Web_Id__c == null) {
                    master = c;
                    continue;
                }

                if (c.Verified__c == true && master.Verified__c != true) {
                    master = c;
                    continue;
                }

                if (c.Contact_Status__c == 'Active'
                    && master.Contact_Status__c != 'Active') {
                    master = c;
                    continue;
                }

                if (c.LastModifiedDate > master.LastModifiedDate) {
                    master = c;
                }
            }

            System.debug('   Master chosen: ' + master.Id);

            List<Contact> losers = new List<Contact>();
            for (Contact c : contacts) {
                if (c.Id != master.Id) {
                    losers.add(c);
                }
            }

            System.debug('   Losers: ' + losers.size());
            if (losers.isEmpty()) continue;

            /* =================================================
               CREATE STUBS (CRITICAL)
               ================================================= */
            Contact masterStub = new Contact(Id = master.Id);

            List<Contact> loserStubs = new List<Contact>();
            for (Contact c : losers) {
                loserStubs.add(new Contact(Id = c.Id));
            }

            /* =================================================
               MERGE
               ================================================= */
            // =================================================
// MERGE (CHUNKED – MAX 2 LOSERS AT A TIME)
// =================================================
try {
    ContactMergeContext.isMergeInProgress = true;

    Integer i = 0;
    while (i < loserStubs.size()) {

        List<Contact> chunk = new List<Contact>();

        // Take max 2 losers per merge
        for (Integer j = i; j < Math.min(i + 2, loserStubs.size()); j++) {
            chunk.add(loserStubs[j]);
        }
        
        System.debug(
            'Merging Master=' + masterStub.Id +
            ' with Losers=' + chunk
        );
        
        Database.merge(
            masterStub,
            chunk,
            true // allow partial success
        );
        
        i += 2;
    }
    
    System.debug('ALL MERGES COMPLETED for master ' + masterStub.Id);
}
            catch (DmlException e) {
                System.debug('MERGE FAILED: ' + e.getMessage());
            }
            finally {
                ContactMergeContext.isMergeInProgress = false;
            }

        }
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new MergeDuplicateContactsWeekend(), 50);
    }

    /* =========================================================
       FINISH
       ========================================================= */
    global void finish(Database.BatchableContext bc) {
        System.debug('Duplicate Contact merge batch completed');
    }
}