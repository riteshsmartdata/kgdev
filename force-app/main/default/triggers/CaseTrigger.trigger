/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
trigger CaseTrigger on Case (before insert) {

   new TagContactWithCase('TagContactWithCase').debug(true).run();


}