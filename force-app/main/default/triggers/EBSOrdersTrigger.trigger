/**
 * @description       : 
 * @author            : ritesh.kumar@kooziegroup.com
 * @group             : 
 * @last modified on  : 21-04-2026
 * @last modified by  : ritesh.kumar@kooziegroup.com
**/
trigger EBSOrdersTrigger on EBS_Order__c (before insert,before update, after insert, after update) {
	//Popudate communication email : Acc fields on orders.
	new PopulateCommunicationEmail('PopulateCommunicationEmail').debug(false).run();
	
	// Tag tervise contact on order object. Tervise Green 
	new SalesContactsTervisGreen('SalesContactsTervisGreen').debug(false).run();

	// Tag bdf contact on order salescontact field.
	new SalesContactBDF('SalesContactBDF').debug(false).run();

	// Tag contact on order salescontact field.
	new TagSalesContactOnOrder('TagSalesContactOnOrder').debug(false).run();
}