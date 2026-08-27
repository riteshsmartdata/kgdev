/*
* @description       :  Batch class to identify the specific distributor's sales person that ordered a 
                        free spec sample, but hasn't placed an order yet.
* @author            :  Vivekanand Kedar
* @group             :  DAMCO
* @created on        :  27/08/2025
* @last modified on  :
* @last modified by  : 
*/

global with sharing class Last60ThDaySpecSampleEBSOrders_Batch implements Database.Batchable<SObject>, Database.stateful, Schedulable{
    
    /*
    *	@description : Class variables
    */ 
    global Integer totalRecords = 0;
    global Set<Id> successfullyUpdatedOrdersIds = new Set<Id>();
    private final Date LAST_30TH_DAY_DATE = Date.today().addDays(-30); // 30 days ago date

    /*
    *	@description : Schedule the batch class, 
    *   Cron Experssion : 
    */
    global void execute(SchedulableContext sc){
        Database.executeBatch(new Last60ThDaySpecSampleEBSOrders_Batch(),10);
    }

    /*
    *	@description : Batch class to identify the specific distributor's sales person that ordered a free spec sample, but hasn't placed an order yet.
    *   @paramerters : accepts BatchableContext as parameter
    */
    global Database.QueryLocator start(Database.BatchableContext bc){
        String allOrderCreatedInLast30ThDayQuery = 'SELECT Id, PO_Contact__c, (SELECT Id, Quantity__c, Product_Marketing_ID__c FROM EBS_Order_Lines__r '
                                                + 'WHERE Line_Type__c Like \'%SPEC SAMPLE%\' AND Line_Status__c = \'CLOSED\') FROM EBS_Order__c ';

        allOrderCreatedInLast30ThDayQuery = addFilter(allOrderCreatedInLast30ThDayQuery);
        System.debug('allOrderCreatedInLast30ThDayQuery: ' +allOrderCreatedInLast30ThDayQuery);
        return Database.getQueryLocator(allOrderCreatedInLast30ThDayQuery);
    }

    /*
    *	@description : Update all identical PO Contacts - same products and quantities - person that ordered a free spec sample and placed an order.
    *   @paramerters : accepts BatchableContext as parameter, Order list returned from start
    */
    global void execute(Database.BatchableContext bc,List<EBS_Order__c> orderScope){
        
        //List<EBS_Order__c> recentEBSOrdersList = new List<EBS_Order__c>();
        Set<Id> poContactsIdSet = new Set<Id>();

        totalRecords += orderScope.size();
        // Process records
        System.debug('orderScope: ' +orderScope.size());
        System.debug('totalRecords: ' +totalRecords);

        
        
        for(EBS_Order__c ebsOrderObj : orderScope){
            poContactsIdSet.add(ebsOrderObj.PO_Contact__c);
        }

        System.debug('poContactsIdSet: ' +poContactsIdSet);
        System.debug('poContactsIdSet Size: ' +poContactsIdSet.size());

        List<EBS_Order__c> recentEBSOrdersList = [  SELECT Id, PO_Contact__c,
                                                        (SELECT Id, Quantity__c, Product_Marketing_ID__c 
                                                        FROM EBS_Order_Lines__r 
                                                        WHERE Line_Status__c = 'CLOSED' AND Sales_Agreement__c = NULL)
                                                    FROM 
                                                        EBS_Order__c
                                                    WHERE 
                                                        CreatedDate >= LAST_N_DAYS:60
                                                        AND Order_Header_Status__c = 'Closed'
                                                        AND PO_Contact__c != NULL
                                                        AND PO_Contact__c IN :poContactsIdSet
                                                        AND Id NOT IN (
                                                            SELECT Order__c 
                                                            FROM EBS_Order_Line__c 
                                                            WHERE Line_Type__c Like '%SPEC SAMPLE%' AND Line_Status__c = 'CLOSED') 
                                                ];
                                               
        System.debug('recentEBSOrdersList: ' +recentEBSOrdersList);
        System.debug('recentEBSOrdersList Size: ' +recentEBSOrdersList.size());

        // Map<ContactId, Map<ProductMarketingId, OrderId>>
        Map<Id, Map<String, Id>> recentEBSOrderMap = new Map<Id, Map<String, Id>>();

        for (EBS_Order__c recentEBSOrderObj : recentEBSOrdersList) {
            Map<String, Id> lineMap = new Map<String, Id>();

            for (EBS_Order_Line__c line : recentEBSOrderObj.EBS_Order_Lines__r) {
                if (String.isNotBlank(line.Product_Marketing_ID__c)) {
                    // Store Product_Marketing_ID__c → OrderId
                    lineMap.put(line.Product_Marketing_ID__c, recentEBSOrderObj.Id);
                }
            }

            // Merge with existing map for the PO_Contact__c
            if (!recentEBSOrderMap.containsKey(recentEBSOrderObj.PO_Contact__c)) {
                recentEBSOrderMap.put(recentEBSOrderObj.PO_Contact__c, new Map<String, Id>());
            }

            recentEBSOrderMap.get(recentEBSOrderObj.PO_Contact__c).putAll(lineMap);
        }

        System.debug('recentEBSOrderMap: ' + recentEBSOrderMap);
        System.debug('recentEBSOrderMap Size: ' + recentEBSOrderMap.size());


        Set<String> matchOrdersDetails = new Set<String>();
        //List<Contact> matchPOContactsUpdateList = new List<Contact>();
        Map<Id, EBS_Order__c> matchSampleOrdersUpdateMap = new Map<Id, EBS_Order__c>();

        for (EBS_Order__c sampleEBSOrderObj : orderScope) {
            Set<String> lineSet = new Set<String>();

            Map<String,Id> recentOrderLinesMap = recentEBSOrderMap.get(sampleEBSOrderObj.PO_Contact__c);
            System.debug('recentOrderLinesMap: ' + recentOrderLinesMap);
            if (recentOrderLinesMap != null && !recentOrderLinesMap.isEmpty()) {
                for (EBS_Order_Line__c line : sampleEBSOrderObj.EBS_Order_Lines__r) {
                    //lineSet.add(line.Product_Marketing_ID__c + ':' + line.Quantity__c);
                    if (recentOrderLinesMap != null && recentOrderLinesMap.containsKey(line.Product_Marketing_ID__c)) {
                        
                        Id matchedOrderId = recentOrderLinesMap.get(line.Product_Marketing_ID__c);
                        System.debug('Match found for Product: ' + line.Product_Marketing_ID__c + ' in Recent Order: ' + matchedOrderId);
                        
                        System.debug('Match found! '+ line.Product_Marketing_ID__c + ':' + matchedOrderId);
                        System.debug('Match found Contact and Sample Order Details! '+sampleEBSOrderObj.PO_Contact__c+' OrderId: '+sampleEBSOrderObj.Id+' LineId: '+line.Id);
                        matchOrdersDetails.add('ContactId: '+sampleEBSOrderObj.PO_Contact__c+'Sample OrderId: '+sampleEBSOrderObj.Id+'Sample LineId: '+line.Id);
                        //matchPOContactsUpdateList.add(new Contact(Id=sampleEBSOrderObj.PO_Contact__c, Spec_Sample_Ordered__c = TRUE));
                        matchSampleOrdersUpdateMap.put(sampleEBSOrderObj.Id, new EBS_Order__c(Id=sampleEBSOrderObj.Id, 
                                                        Exclude_From_60_Days_Spec_Sample__c = TRUE, Order_From_Spec_Sample__c = matchedOrderId));
                        break;
                    } else {
                        System.debug('Match Not found Contact and Recent Order Details! '+ line.Product_Marketing_ID__c + ':' + recentOrderLinesMap.get(line.Product_Marketing_ID__c));
                        System.debug('Match Not found Contact and Sample Order Details! '+ sampleEBSOrderObj.PO_Contact__c + ':' + sampleEBSOrderObj.Id);
                    }
                }
            }
        }

        System.debug('matchOrdersDetails: ' + matchOrdersDetails);

        System.debug('matchSampleOrdersUpdateMap: ' + matchSampleOrdersUpdateMap);
        System.debug('matchSampleOrdersUpdateMap Size: ' + matchSampleOrdersUpdateMap.size());
        
       // Perform update: Update all identical PO Contacts - same products and quantities - person that ordered a free spec sample and placed an order.
        if (!matchSampleOrdersUpdateMap.isEmpty() && matchSampleOrdersUpdateMap.size() > 0) {
            
            Database.SaveResult[] updateResults = Database.update(matchSampleOrdersUpdateMap.values(), false);

            for (Database.SaveResult result : updateResults) {
                if (result.isSuccess()) {
                    successfullyUpdatedOrdersIds.add(result.getId());
                } else {
                    // Log errors
                    for (Database.Error err : result.getErrors()) {
                        System.debug('Error updating Contact: ' + err.getMessage());
                    }
                }
            }
        }
        
        System.debug('Total Contact updated: ' + successfullyUpdatedOrdersIds.size());
        System.debug('Successfully Updated Contact Ids: ' + successfullyUpdatedOrdersIds);

    }

    /*
    *	@description : Opeartions which needs to be perfromed when the batch has finished executing
    *   @paramerters : accepts BatchableContext as parameter
    */
    global void finish(Database.BatchableContext bc){
        System.debug('Total records processed: ' + totalRecords);
        System.debug('Total Orders updated: ' + successfullyUpdatedOrdersIds.size());
        System.debug('Successfully Updated Orders Ids: ' + successfullyUpdatedOrdersIds);
        System.debug('Same products and quantities - person that ordered a free spec sample and placed an order batch has finished executing');
    }    
    
    /*
    *	@description : Apply filters in the start method of the Query to give only Orders which are created in Last 90 Days
    *   @paramerters : accecpts query without where condition
    */
    private String addFilter(String query){
        if(String.isNotBlank(query)){
            query += 'WHERE DAY_ONLY(CreatedDate) = :LAST_30TH_DAY_DATE ';
            query += 'AND Order_Header_Status__c = \'CLOSED\' AND PO_Contact__c != NULL ';
            query += 'AND Id IN (SELECT Order__c FROM EBS_Order_Line__c WHERE Line_Type__c Like \'%SPEC SAMPLE%\' AND Line_Status__c = \'CLOSED\' ) ';
            query += 'AND Exclude_From_30_Days_Spec_Sample__c = false AND Exclude_From_60_Days_Spec_Sample__c = false ';
            query += 'LIMIT 50000';
        }
        return query;
    }
}