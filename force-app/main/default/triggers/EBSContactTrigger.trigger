/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-04-2026
 * @last modified by  : Ritesh Kumar (ritesh.kumar@kooziegroup.com)
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   03-08-2024   Ritesh Kumar   Initial Version
**/

trigger EBSContactTrigger on Contact (before insert, after insert, before update, after update) {
    new SendContactToEBS('SendContactToEBS').debug(true).run();
	new WebsiteContactSyncHandler('WebsiteContactSyncHandler').debug(true).run();
}