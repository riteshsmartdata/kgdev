public class EBSOrderLineTriggerHandler {
    
    public static void DelayedOrderCaseCreation(List<EBS_Order_Line__c > newEBSOrderLineList, Map<Id, EBS_Order_Line__c> oldEBSOrderLineMap)
    {
        system.debug('EBS Order Line Trigger Called @@@@@@@');
        // PB to Trigger Conversion & BRD Requirement
        List<EBS_Order_Line__c> filteredEOL = new List<EBS_Order_Line__c>();			// To store delayed EBS Order Line records from trigger.new
        Set<String> orderNumberSet = new Set<String>();									// To store Order Numbers from delayed EBS Order Line with the help of trigger.new
        List<EBS_Order__c> filteredEBSOrder = new  List<EBS_Order__c>();				// To store the associated EBS Order for EBS Order Line which is queried using Order Numbers from delayed EBS Order Line
        Set<String> ebsOrderNumberSet = new Set<String>();								// To store Order Numbers from EBS Order
        List<EBS_Order_Line__c> EBSOrderLineList = new List<EBS_Order_Line__c>();		// To store filtered EBS Order Line records using filteredEOL
        List<Case> checkEBSOrderLineCaseList = new List<Case>();     					// To store the Cases queried based on RecordType - Delayed Order & ebsOrderNumberSet
        Map<String, Case> orderNumberCaseMap = new Map<String, Case>();					// To store the filtered case with Order number as key and case record as value        
        Map<Id,EBS_Order_Line__c> filteredEOLMap = new Map<Id,EBS_Order_Line__c>();		// To store the delayed EBS Order Line with EBS Order Line Id as key and EBS Order Line record as value
        List<Case> insertCaseList = new List<Case>();									// To insert Case for the delayed EBS Order Line which doesn't have associated cases and also for the Orders doesn't have PO Contact
        List<Case> insertCasePOContactList = new List<Case>();							// To insert Case for the delayed EBS Order Line which doesn't have associated cases and also for the Orders doesn't have PO Contact
        List<Case> updateCaseList = new List<Case>();									// To update Case for closed or open cases
        List<EBS_Order_Line__c> updateEBSOrderLineList = new List<EBS_Order_Line__c>();	// To update Delayed Case Order field in EBS Order Line with associated Case        
        
        AssignmentRule AR = [SELECT Id FROM AssignmentRule WHERE SObjectType = 'Case' AND Active = True LIMIT 1];
        for (EBS_Order_Line__c eol : newEBSOrderLineList)
        {
            EBS_Order_Line__c oldEOL =  oldEBSOrderLineMap.get(eol.Id);
            
            // PB Conversion & BRD Requirement // TOV_Line_Status__c would be production open on ebs 
            // if (eol.Order__r.Order_Type__c !='Standard HK' && eol.Order__r.Order_Type__c !='Direct Business HK')
            if (eol.Order_Type__c !='Standard HK' && eol.Order_Type__c !='Direct Business HK')
            {
                if(eol.Scheduled_Ship_Date__c != NULL && eol.Promise_Date__c != NULL && 
                   (eol.Scheduled_Ship_Date__c > eol.Promise_Date__c) && eol.TOV_Line_Status__c != NULL && 
                   (eol.TOV_Line_Status__c == 'In Production' ||  eol.TOV_Line_Status__c == 'In Storage' || eol.TOV_Line_Status__c == 'Awaiting Shipping') && 
                   (eol.Scheduled_Ship_Date__c != oldEOL.Scheduled_Ship_Date__c || eol.Promise_Date__c != oldEOL.Promise_Date__c))
                {
                    system.debug('PB & BRD if Condition on trigger.new @@@@@@@@@@@@@@@@');
                    system.debug(eol.Order_Type__c);
                    filteredEOL.add(eol);
                    orderNumberSet.add(eol.Order_Number__c);
                }
            }
        }
        
        filteredEBSOrder = [SELECT Id, Account_Name__c, PO_Contact__c, PO_Contact_Email__c, EBS_Order_Number__c, Customer_PO__c FROM EBS_Order__c 
                            WHERE EBS_Order_Number__c IN: orderNumberSet];
        
        for (EBS_Order__c o : filteredEBSOrder)
        {
            ebsOrderNumberSet.add(o.EBS_Order_Number__c);
        }
        
        // Delayed Order RecordTypeId
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Delayed Order').getRecordTypeId();
        
        // if this soql return the data it means we have case then just update the case otherwise create a new case and associate it with ebs order line 
        checkEBSOrderLineCaseList = [SELECT Id, EBS_Order_Number__c, RecordTypeId, Last_Delayed_Line_Date__c, Delayed_Case_Reopen__c, 
                                     Status FROM Case 
                                     WHERE EBS_Order_Number__c IN :ebsOrderNumberSet AND RecordTypeId=:caseRecordTypeId 
                                     ORDER BY createddate DESC LIMIT 50000];
        
        for (Case cs : checkEBSOrderLineCaseList)
        {
            orderNumberCaseMap.put(cs.EBS_Order_Number__c, cs);
        }
        
        
        EBSOrderLineList = [SELECT Id, Order__c,Order__r.Customer_Account_Number__c, Line_Number__c, Order_Number__c, Order__r.EBS_Order_Number__c, Order__r.Customer_PO__c, 
                            Order__r.Account_Name__c, Order__r.PO_Contact__c, Order__r.PO_Contact_Email__c FROM EBS_Order_Line__c where Id IN : filteredEOL];
        
        // it means we have case then update the case or reopen the case
        if (!checkEBSOrderLineCaseList.isEmpty()){
            
            for (EBS_Order_Line__c eol : EBSOrderLineList)
            {
                 if (orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c) != NULL && 
                    (orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status == 'Closed'|| 
                     orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status == 'Merged' || 
                     orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status == 'Merged - Duplicate'))
                {
                    system.debug('Updating cases which are closed and reopen the closed case @@@@@@@@@@');
                    EBS_Order_Line__c el = new EBS_Order_Line__c(); 
                    Case c = new Case();
                    c.Id = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Id;                     
                    c.Status = 'New';
                    c.Last_Delayed_Line_Date__c = datetime.now();
                    c.Delayed_Case_Reopen__c = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Delayed_Case_Reopen__c;  // updated line 78 to 90 on Jan 6
                    system.debug('Delayed Order Line from Order map --->'+orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Delayed_Case_Reopen__c);
                    system.debug('Delayed Order Line from case --->'+c.Delayed_Case_Reopen__c);
                    if (c.Delayed_Case_Reopen__c >= 0)		
                    {
                        system.debug('inside if');
                        c.Delayed_Case_Reopen__c = c.Delayed_Case_Reopen__c + 1;                        
                    }
                    else if(c.Delayed_Case_Reopen__c==null){
                        c.Delayed_Case_Reopen__c = 1;
                    }
                    else
                    {
                        system.debug('inside else');
                        c.Delayed_Case_Reopen__c = 0;
                    }
                    if(c.ContactId == NULL){
                        c.ContactId = eol.Order__r.PO_Contact__c;
                    }
                    el.Id = eol.Id;
                    el.Delayed_Order_Case__c = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Id;
                    // we have to do case assignment 
                    // TO DO : create one assignment rule if recordtype is equal delayed order and reopened is greater then 0 then assign it to voc queue
                    // check if counter is incresing each time case is reopened and is visible on the layout add it on the layout (delayed order case layout )
                    //  if we have a closed case we have logic on email link that logic is not working 
                    Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    c.setOptions(dmlOpts);
                    updateCaseList.add(c);
                    updateEBSOrderLineList.add(el);
                }
                else if (orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c) != NULL && 
                         (orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status != 'Closed'|| 
                          orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status != 'Merged' || 
                          orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Status != 'Merged - Duplicate'))
                {
                    system.debug('Updating cases which are not closed @@@@@@@@@@');
                    EBS_Order_Line__c el = new EBS_Order_Line__c(); 
                    Case c = new Case();
                    c.Id = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Id;    
                    c.Status = 'New';										//added this line on Jan 19 for updating the status to working                    
                    c.Last_Delayed_Line_Date__c = datetime.now();
                    c.Delayed_Case_Reopen__c = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Delayed_Case_Reopen__c;	// updated line 116 to 121 on Jan 6
                    if (c.Delayed_Case_Reopen__c == NULL)		
                    {
                        c.Delayed_Case_Reopen__c = 0;                        
                    }
                    if(c.ContactId == NULL){
                        //  c.ContactId = eol.Order__r.PO_Contact__c;
                    }
                    el.Id = eol.Id;
                    el.Delayed_Order_Case__c = orderNumberCaseMap.get(eol.Order__r.EBS_Order_Number__c).Id;
                    updateCaseList.add(c);
                    updateEBSOrderLineList.add(el);
                }
                
            }
        }
        // Creating new case when no cases are associated with delayed EBS Order Line
        else
        {
            for (EBS_Order_Line__c eol : EBSOrderLineList)
            {
                if (orderNumberCaseMap.get(eol.Order_Number__c) == NULL)
                {   
                    system.debug('New Case Creation for Delayed Order @@@@@@@@@@');
                    
                    Case cs = new Case();   
                    cs.Status = 'New';
                    cs.AccountId = eol.Order__r.Account_Name__c;
                    cs.Description = 'Delayed Order PO# ' + eol.Order__r.Customer_PO__c +', SO# ' + eol.Order__r.EBS_Order_Number__c  +', line # ' + eol.Line_Number__c + '.';
                    cs.EBS_Order_ID__c = eol.Order__r.EBS_Order_Number__c;
                    cs.EBS_Order_Line__c = eol.Id;
                    cs.EBS_Order__c = eol.Order__c;					
                    cs.Origin = 'EBS - Delayed Order';
                    cs.Priority = 'High';
                    cs.RecordTypeId = caseRecordTypeId;
                    cs.Delayed_Case_Reopen__c = 0;			// added this line on Jan 6
                    cs.Last_Delayed_Line_Date__c = datetime.now();
                    cs.Subject = 'Delayed Order PO# ' + eol.Order__r.Customer_PO__c +', SO# ' + eol.Order__r.EBS_Order_Number__c  +', line # ' + eol.Line_Number__c + '.';
                    //cs.Subject = 'Delayed Order PO# ' + eol.Order__r.Customer_PO__c +', SO# ' + eol.Order__r.EBS_Order_Number__c  +', line # ' + eol.Line_Number__c + '.';
                    cs.Type = 'Delayed Order';
                    cs.EBS_Account_Number__c = eol.Order__r.Customer_Account_Number__c ;
                    if((eol.Order__r.Customer_Account_Number__c !='4162' || eol.Order__r.Customer_Account_Number__c !='44076' ) && eol.Order__r.PO_Contact__c !=null ){
                        cs.ContactId = eol.Order__r.PO_Contact__c;
                    }
                    
                     Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    cs.setOptions(dmlOpts);
                    insertCaseList.add(cs);
                   // insertCasePOContactList.add(cs);
                }
            }
        }
        insert insertCaseList;
      //  insert insertCasePOContactList;
        update updateCaseList;
        
        for (EBS_Order_Line__c eol : EBSOrderLineList)
        {
            filteredEOLMap.put(eol.Id, eol);
        }
        
        // Associating newly created case with delayed EBS Order Line
        for (Case c : insertCaseList)
        {
            EBS_Order_Line__c eol = filteredEOLMap.get(c.EBS_Order_Line__c);
            eol.Delayed_Order_Case__c = c.Id;
            updateEBSOrderLineList.add(eol);
        }
        update updateEBSOrderLineList;
        
    } 
    
}