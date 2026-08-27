/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 02-06-2024
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   02-02-2024   Ritesh Kumar   Initial Version
**/

@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.FieldDeclarationsShouldBeAtStart, PMD.EmptyStatementBlock, PMD.CognitiveComplexity')
public without sharing class EBSOrderLineSendEmail extends TriggerHandler {

    private List<EBS_Order_Line__c> newRecords;
	private List<EBS_Order_Line__c> oldRecords;
	private Map<Id, EBS_Order_Line__c> newRecordsMap;
	private Map<Id, EBS_Order_Line__c> oldRecordsMap; 
    private static final set<String> ACCOUNT_NUMBERS = new Set<String>{'4162', '44076', '709886'};
    private static final String IN_PRODUCTION = 'In Production'; 
    private static final String IN_STORAGE = 'In Storage';
    private static final String STANDARD_HK = 'Standard HK'; 
    private static final String COMPLETE = 'Complete';
    private static final String EMAIL = 'Email';
    private static final Trigger_Settings__mdt triggerSetting = Trigger_Settings__mdt.getInstance('EBS_Order_Line');

    Enum DML_MODE {
        INSERT_DATA,
        UPDATE_DATA
    }

    public EBSOrderLineSendEmail(String className){
        this.newRecords = (List<EBS_Order_Line__c>) Trigger.new;
		this.oldRecords = (List<EBS_Order_Line__c>) Trigger.old;
		this.newRecordsMap = (Map<Id, EBS_Order_Line__c>) Trigger.newMap;
		this.oldRecordsMap = (Map<Id, EBS_Order_Line__c>) Trigger.oldMap; 
    } 

    public override void afterInsert() {
        System.debug(LoggingLevel.INFO,'===== START afterInsert ====='+triggerSetting.Is_Active__c);
         if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        tovLine(newRecords, EBSOrderLineSendEmail.DML_MODE.INSERT_DATA);        
        System.debug(LoggingLevel.INFO,'===== END afterInsert =====');
    } 

	public override void afterUpdate(){
        System.debug(LoggingLevel.INFO,'===== START afterUpdate ====='+triggerSetting.Is_Active__c);
        if(triggerSetting.Is_Active__c == FALSE){
            return;
        }
        tovLine(newRecords, EBSOrderLineSendEmail.DML_MODE.UPDATE_DATA);      
        System.debug(LoggingLevel.INFO,'===== END afterUpdate =====');
    }

    private void tovLine(List<EBS_Order_Line__c> records, EBSOrderLineSendEmail.DML_MODE mode){
        System.debug(LoggingLevel.INFO,'===== START tovLine ====='); 
        Set<Id> orderIds = new Set<Id>();
        Map<Id,EBS_Order__c> updateOrders = new Map<Id,EBS_Order__c>();

        switch on mode  {

            when INSERT_DATA {
                System.debug(LoggingLevel.INFO,'===== INSERT =====');
                for(EBS_Order_Line__c line : records){
                    if(checkOrder(line)){
                        System.debug(LoggingLevel.INFO,'===== Order Pass ====='); 
                       // orderIds.add(line.Order__c);
                        if(line.TOV_Line_Status__c == IN_PRODUCTION){
                            EBS_Order__c record = updateProductionOrder(line.Order__c);

                            if(updateOrders.containsKey(line.Order__c)){
                                updateOrders.get(line.Order__c).Latest_in_Production_Date_Time__c = System.now();
                            }else{
                                updateOrders.put(line.Order__c,record);
                            }
        
                        }
        
                        if(line.Shipment_Email_Sent__c == TRUE &&line.TOV_Line_Status__c == COMPLETE){

                            EBS_Order__c record = updateCompleteOrder(line.Order__c);
                            if(updateOrders.containsKey(line.Order__c)){
                                updateOrders.get(line.Order__c).Latest_Complete_Date_Time__c = System.now();
                            }else{
                                updateOrders.put(line.Order__c,record);
                            }
                        }
                    }
                } 
            }

            when UPDATE_DATA {
                System.debug(LoggingLevel.INFO,'===== UPDATE =====');
                for(EBS_Order_Line__c line : records){ 
                    if(checkOrder(line)){
                        System.debug(LoggingLevel.INFO,'===== Order Pass ====='); 
                       // orderIds.add(line.Order__c);
                        if(line.TOV_Line_Status__c == IN_PRODUCTION && 
                            line.TOV_Line_Status__c != oldRecordsMap.get(line.Id).TOV_Line_Status__c && 
                            oldRecordsMap.get(line.Id).TOV_Line_Status__c != IN_STORAGE
                        ){
                            EBS_Order__c record = updateProductionOrder(line.Order__c);
                            if(updateOrders.containsKey(line.Order__c)){
                                updateOrders.get(line.Order__c).Latest_in_Production_Date_Time__c = System.now();
                            }else{
                                updateOrders.put(line.Order__c,record);
                            }
        
                        }
        
                        if(line.Shipment_Email_Sent__c == TRUE && 
                            line.TOV_Line_Status__c == COMPLETE && 
                            line.TOV_Line_Status__c != oldRecordsMap.get(line.Id).TOV_Line_Status__c
                        ){
                            EBS_Order__c record = updateCompleteOrder(line.Order__c);
                            if(updateOrders.containsKey(line.Order__c)){
                                updateOrders.get(line.Order__c).Latest_Complete_Date_Time__c = System.now();
                            }else{
                                updateOrders.put(line.Order__c,record);
                            }
                        }
                    }
                }
            }

        }

        System.debug(LoggingLevel.INFO,'===== updateOrders ====='+updateOrders);

        Database.SaveResult[] updateResult = Database.Update(updateOrders.values(), false);
        updateOrders.clear();

        System.debug(LoggingLevel.INFO,'===== END tovLine =====');
    }

    private Boolean checkOrder(EBS_Order_Line__c line){
        Boolean flag = FALSE; 
        System.debug(LoggingLevel.INFO,'=====  Customer Account Number Not IN: '+ACCOUNT_NUMBERS+' ====='+(ACCOUNT_NUMBERS.contains(line.Account_Customer_Account_Number__c)));
        System.debug(LoggingLevel.INFO,'=====  Account_Name Not NULL ====='+String.isNotBlank(line.Account_Name__c));
        System.debug(LoggingLevel.INFO,'=====  Order_Type Not Equal '+STANDARD_HK+'====='+ line.Order_Type__c);
        System.debug(LoggingLevel.INFO,'=====  OptIn '+EMAIL+'  ====='+ line.OptIn__c);

        if( line.Order_Type__c != STANDARD_HK && line.OptIn__c == EMAIL && String.isNotBlank(line.Account_Name__c) ){
            flag = ACCOUNT_NUMBERS.contains(line.Account_Customer_Account_Number__c) ?FALSE : TRUE;
        } 
        return flag;
    }

    private EBS_Order__c updateProductionOrder(String recordId){

        EBS_Order__c order = new EBS_Order__c();
        order.Id = recordId;
        order.Latest_in_Production_Date_Time__c = System.now(); 
        return order;
    }

    private EBS_Order__c updateCompleteOrder(String recordId){

        EBS_Order__c order = new EBS_Order__c();
        order.Id = recordId;
        order.Latest_Complete_Date_Time__c = System.now(); 
        return order;
    }

}