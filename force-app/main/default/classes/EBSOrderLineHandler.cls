/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   12-15-2023   Ritesh Kumar   SF-1204
**/
public with sharing class EBSOrderLineHandler{

    final Static String CASE_OBJECT = 'Case'; 
    final Static String STANDARD_HK = 'Standard HK';
    final Static String DIRECT_BUSINESS_HK = 'Direct Business HK';
    final Static String IN_STORAGE = 'In Storage';
    final Static String IN_PRODUCTION = 'In Production';
    final Static String AWAITING_SHIPPING = 'Awaiting Shipping';
    final Static String DELAYED_ORDER = 'Delayed Order';
    final Static String CLOSED = 'Closed';
    final Static String MERGED = 'Merged';
    final Static String MERGED_DUPLICATE = 'Merged - Duplicate';

    public static Boolean delayedOrderCase(List<EBS_Order_Line__c> newOrderLines, Map <Id ,EBS_Order_Line__c> oldOrderLines){
        System.debug('newOrderLines--=>  '+ newOrderLines);
        Boolean isRun = TRUE;
        String caseRecordTypeId = KoozieUtility.getRecordTypeId(CASE_OBJECT, DELAYED_ORDER);
        AssignmentRule caseRule = getRule(CASE_OBJECT, TRUE);
        Map<String, Set<String>> orderLineFilterMap = newOrderLines.size()>0 ?  fillFilterMap(newOrderLines,oldOrderLines) : new Map<String, Set<String>>();
        Map<String, Case> orderCaseMap = new Map<String,Case>(); 
        List<Case> upsertCase = new List<Case>();
        Map<Id, Case> updateCases = new Map<Id,Case>();
        Map<Id,EBS_Order_Line__c> orderLines = new Map<Id, EBS_Order_Line__c>();
        orderCaseMap = getCaseRecords(orderLineFilterMap);
        
        if(!orderLineFilterMap.isEmpty()){
            Set<String> tempdata = new Set<String>();
        
            for(Set<String> data :orderLineFilterMap.values() ){
                tempdata.addAll(data);
            }

            orderLines = new Map<Id, EBS_Order_Line__c>( [
                SELECT 
                    Id, Order__c,Order__r.Customer_Account_Number__c, Line_Number__c, Order_Number__c, Order__r.EBS_Order_Number__c, 
                    Order__r.Customer_PO__c, Order__r.Account_Name__c, Order__r.PO_Contact__c, Order__r.PO_Contact_Email__c 
                FROM 
                    EBS_Order_Line__c where Id IN : tempdata ORDER BY CreatedDate DESC
            ]);

        } 
        
        for(EBS_Order_Line__c orderLine : orderLines.values()){
            if( String.isNotEmpty(orderLine.Order_Number__c) && orderCaseMap.containsKey(orderLine.Order_Number__c)){
                if( 
                    orderCaseMap.get(orderLine.Order_Number__c).Status == CLOSED || 
                    orderCaseMap.get(orderLine.Order_Number__c).Status == MERGED ||  
                    orderCaseMap.get(orderLine.Order_Number__c).Status == MERGED_DUPLICATE
                ){
                    //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLine ======: '+orderLine);
                    Case record = updateCaseRecord(orderCaseMap.get(orderLine.Order_Number__c),caseRule,orderLine,TRUE);
                    updateCases.put(record.Id, record);
                }  else 
            
                /*if(
                    orderCaseMap.get(orderLine.Order_Number__c).Status != CLOSED || 
                    orderCaseMap.get(orderLine.Order_Number__c).Status != MERGED ||  
                    orderCaseMap.get(orderLine.Order_Number__c).Status != MERGED_DUPLICATE
                )*/{
                    //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLine ======: '+orderLine);
                    Case record = updateCaseRecord(orderCaseMap.get(orderLine.Order_Number__c),caseRule,orderLine, FALSE);
                    updateCases.put(record.Id, record);
                }
            }else{
                //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLine ======: '+orderLine);
                upsertCase.add(insertCaseRecord(orderCaseMap.get(orderLine.Order_Number__c),caseRule,orderLine,caseRecordTypeId));
            }
        } 
        
        
        if(!updateCases.isEmpty()){
            upsertCase.addAll(updateCases.values());
        }

        Database.UpsertResult[] upsertCaseResult = new  List<Database.UpsertResult>();
        if(!upsertCase.isEmpty()){
            upsertCaseResult = Database.upsert(upsertCase, FALSE);            
        }

        Map<String,String> caseWithOrder = new Map<String,String>();
        Set<Id> insertedCaseId = new Set<Id>(); 
        for( Database.UpsertResult result : upsertCaseResult){
            if(result.isSuccess()){
                insertedCaseId.add(result.getId());
            }
        }
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : upsertCase ======: '+upsertCase);
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : insertedCaseId ======: '+insertedCaseId);
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : upsertCaseResult ======: '+upsertCaseResult);
        List<EBS_Order_Line__c> updateOrderLines = new List<EBS_Order_Line__c>();
        if(! insertedCaseId.isEmpty()){
            //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : upsertCaseResult ======: '+upsertCaseResult);
            //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLines ======: '+upsertCaseResult);
            for(Case record :upsertCase ){
                //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : record ======: '+record);
                //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : EBS_Order_Line__c ======: '+record.EBS_Order_Line__c);
                if(insertedCaseId.contains(record.Id)){
                    EBS_Order_Line__c data = new EBS_Order_Line__c();
                    data.Id = orderLines.get(record.EBS_Order_Line__c).Id;
                    data.Delayed_Order_Case__c = record.Id;
                    updateOrderLines.add(data);
                }
                
            }
            //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : updateOrderLines ======: '+updateOrderLines);
            if(updateOrderLines.size() > 0){
                Database.update(updateOrderLines,FALSE);
            }
            
        }
        isRun = FALSE;
        
        return isRun;
    }

    /**
     * @description       : This method is used prepare case record to perform Insert date dml.
     * 
     */
    private static Case insertCaseRecord(Case record, AssignmentRule caseRule, EBS_Order_Line__c orderLine, String caseRecordTypeId){
        Case caseRecord = new Case(); 
        caseRecord.Status = 'New';
        caseRecord.AccountId = orderLine.Order__r.Account_Name__c;
        caseRecord.Description = 'Delayed Order PO# ' + orderLine.Order__r.Customer_PO__c +', SO# ' + orderLine.Order__r.EBS_Order_Number__c  +', line # ' + orderLine.Line_Number__c + '.';
        caseRecord.EBS_Order_ID__c = orderLine.Order__r.EBS_Order_Number__c;
        caseRecord.EBS_Order_Line__c = orderLine.Id;
        caseRecord.EBS_Order__c = orderLine.Order__c;					
        caseRecord.Origin = 'EBS - Delayed Order';
        caseRecord.Priority = 'High';
        caseRecord.RecordTypeId = caseRecordTypeId;
        caseRecord.Delayed_Case_Reopen__c = 0;			// added this line on Jan 6
        caseRecord.Last_Delayed_Line_Date__c = datetime.now();
        caseRecord.Subject = 'Delayed Order PO# ' + orderLine.Order__r.Customer_PO__c +', SO# ' + orderLine.Order__r.EBS_Order_Number__c  +', line # ' + orderLine.Line_Number__c + '.';
         caseRecord.Type = 'Delayed Order';
        caseRecord.EBS_Account_Number__c = orderLine.Order__r.Customer_Account_Number__c ;
        if((orderLine.Order__r.Customer_Account_Number__c !='4162' || orderLine.Order__r.Customer_Account_Number__c !='44076' ) && orderLine.Order__r.PO_Contact__c !=null ){
            caseRecord.ContactId = orderLine.Order__r.PO_Contact__c;
        }
        Database.DMLOptions dmlRule = new Database.DMLOptions();
        dmlRule.assignmentRuleHeader.assignmentRuleId= caseRule.Id;
        caseRecord.setOptions(dmlRule);
        return caseRecord; 
    } 

    /**
     * @description       : This method is used prepare case record to perform update dml.
     * 
     */
    private Static Case updateCaseRecord(Case record, AssignmentRule caseRule,EBS_Order_Line__c orderLine, Boolean statusMached){
        Case caseRecord = new Case();
        caseRecord.Id  = record.Id;
        caseRecord.Status = 'New';
        caseRecord.Last_Delayed_Line_Date__c = Datetime.now();
        caseRecord.EBS_Order_Line__c = orderLine.Id;
        if(statusMached){
            caseRecord.Delayed_Case_Reopen__c = record.Delayed_Case_Reopen__c >= 0 ? record.Delayed_Case_Reopen__c + 1 : 0;
        }else{
            caseRecord.Delayed_Case_Reopen__c = record.Delayed_Case_Reopen__c == NULL ? 0 : record.Delayed_Case_Reopen__c;
        }
        if(String.isNotBlank(caseRecord.ContactId) && statusMached){
            caseRecord.ContactId = orderLine.Order__r.PO_Contact__c;
        }
        
        if(statusMached){
            Database.DMLOptions dmlRule = new Database.DMLOptions();
            dmlRule.assignmentRuleHeader.assignmentRuleId= caseRule.Id;
            caseRecord.setOptions(dmlRule);
        }
        
        return caseRecord;  
    }

    /**
     * @description       : This method is used to  map order with orlder lins.
     * @Parameter         : Accept the two parameter 1st accept the tigger.name and 2nd accept oldTriggerMap.
     * 
     */
    private static Map<String, Set<String>> fillFilterMap( List<EBS_Order_Line__c> newOrderLines,Map <Id ,EBS_Order_Line__c> oldOrderLines){
        Map<String, Set<String>> orderLineFilterMap = new Map<String, Set<String>>();
        if(newOrderLines.size()> 0){
           for(EBS_Order_Line__c orderLine : newOrderLines){
                if(checkOrderType(orderLine.Order_Type__c) && checktovLineStatus(orderLine.TOV_Line_Status__c) && 
                    orderLine.Scheduled_Ship_Date__c != NULL && orderLine.TOV_Line_Status__c != NULL && orderLine.Promise_Date__c != NULL && 
                    orderLine.Scheduled_Ship_Date__c > orderLine.Promise_Date__c && (orderLine.Scheduled_Ship_Date__c.getTime() - orderLine.Promise_Date__c.getTime()) > 86400000  &&  
                    (
                        compareDateTime(orderLine.Scheduled_Ship_Date__c, oldOrderLines.get(orderLine.Id).Scheduled_Ship_Date__c) || 
                        compareDateTime(orderLine.Promise_Date__c, oldOrderLines.get(orderLine.Id).Promise_Date__c)
                    )
                ){
                    //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLine ======: '+orderLine.Order_Number__c);
                    if(String.isNotBlank(orderLine.Order_Number__c)){
                        orderLineFilterMap = fillOrderFilterMap(orderLineFilterMap, orderLine.Order_Number__c, orderLine.Id);
                    }

                    //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : delayedOrderCase : orderLineFilterMap ======: '+orderLineFilterMap);
                }
            }
        }
        return orderLineFilterMap;
    }


    /**
     * @description       : This method is used to obtain the case record that is related to the order.
     * @Parameter         : Accept the orderlinefiltermap as parameter to get realted case.
     * 
     */
    private static Map<String, Case> getCaseRecords( Map<String, Set<String>> orderLineFilterMap){
        Map<String, Case> orderCaseMap = new Map<String,Case>();
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getCaseRecords : OrderNumber ======: '+orderLineFilterMap.keySet());
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getCaseRecords : DELAYED_ORDER ======: '+DELAYED_ORDER);
        if(! orderLineFilterMap.isEmpty()){
            for(Case caseRecord : [
                SELECT 
                    Id, EBS_Order_Number__c, RecordTypeId, Last_Delayed_Line_Date__c, Delayed_Case_Reopen__c, Status 
                FROM 
                    Case 
                WHERE 
                    EBS_Order_Number__c IN : orderLineFilterMap.keySet() AND RecordType.Name =: DELAYED_ORDER
                ORDER BY 
                    createddate DESC  
                LIMIT 50000
            ]){
                orderCaseMap.put(caseRecord.EBS_Order_Number__c, caseRecord);
                //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getCaseRecords : orderCaseMap ======: '+orderCaseMap);
            }
        }

        return ! orderCaseMap.isEmpty() ? orderCaseMap : new Map<String,Case>(); 
    }

    /**
     * @description       : This method is used to put keys and values in the map, map holds the order and the corresponding order line. relationship 1:N
     * @Parameter         : This method has tree parameters.
     *                      1) currentMap : refres the current map to which we want to add values. 
     *                      2) key : Key of map and accpet the order number.
     *                      3) Value : value of map and accept order line Id.
     */
    private static  Map<String, Set<String>> fillOrderFilterMap( Map<String, Set<String>> currentMap, String key, String value ){

        if(currentMap.containsKey(key)){
            currentMap.get(key).add(value);
        }else{
            currentMap.put(key, new Set<String>{value});
        }
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : fillOrderFilterMap : currentMap ======: '+currentMap);
        return currentMap;
    }

    /**
     * @description       : This method is used to compare two dates, return true if the dates are different.
     * @Parameter         : This method has two parameters and type is datetime. 
     */
    private static Boolean compareDateTime(DateTime currentDateTime, DateTime oldDateTime){
        return currentDateTime != oldDateTime ? TRUE: FALSE;
    }

    /**
     * @description       : This method is used to check the order type and return true if the type is not equal to Standard HK and Direct Busuness HK.
     * @Parameter         : The first parameter type is string and accept the order type. 
     */
    private static Boolean checkOrderType(String orderType){
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : checkOrderType : orderType ======: '+orderType);
        return (orderType != STANDARD_HK && orderType != DIRECT_BUSINESS_HK) ? TRUE : FALSE;
    }

    /**
     * @description       : This method is used to check the status of the TOV line and return true if the status is equal to In Production, Awaiting Shipping, or In Storage.
     * @Parameter         : The first parameter type is string and accept the TOV line Status. 
     */
    private static Boolean checktovLineStatus(String tovLineStatus){
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : checktovLineStatus : tovLineStatus ======: '+tovLineStatus);
        return (tovLineStatus == AWAITING_SHIPPING || tovLineStatus == IN_STORAGE ||  tovLineStatus == IN_PRODUCTION) ? TRUE : FALSE;
    }

    /**
     * @description       : This method is used to get whether assignment rules exist.
     * @Parameter         : The first parameter type is string and the second parameter type is boolean.
     *                      String : Accept object API name.
     *                      Booleand : Accept boolean value, pass true if you want to get active rule otherwise pass false.
     */
    private static AssignmentRule getRule(String objectName, Boolean ruleStatus){
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getRule : objectName ======: '+objectName);
        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getRule : ruleStatus ======: '+ruleStatus);
        AssignmentRule [] caseRule = [
            SELECT 
                Id,Name 
            FROM 
                AssignmentRule 
            WHERE 
                SObjectType =:objectName AND Active =: ruleStatus
            LIMIT 1 
        ];

        //System.debug(LoggingLevel.INFO,'===== EBSOrderLineHandler : getRule : caseRule ======: '+caseRule);
        return caseRule.size() > 0 ? caseRule[0] : new AssignmentRule();
    }
    
}