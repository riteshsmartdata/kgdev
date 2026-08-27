///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public without sharing class clarificationEmailHandler{

    public static void closeClariHandler(List<String> emailRecordString){
    system.debug('closeClariHandler called @@@@@@@@@@@@');
        List<String> lstCaseStr = new List<String>();
        List<EmailMessage> lstEmailClone = new List<EmailMessage>();
        List<Case> lstEmailCaseIns = new List<Case>();
        List<Case> lstEmailCaseUpd = new List<Case>();
        Map<ID, EmailMessage> mpClarEmail = new Map<ID, EmailMessage>();
        Map<ID, Case> mpClarCase = new Map<ID, Case>();
        
        Recordtype rt = [Select Id from RecordType Where SObjectType = 'Case' And Name = 'Case'];
        AssignmentRule AR = [SELECT Id FROM AssignmentRule WHERE SObjectType = 'Case' AND Active = True LIMIT 1];
        
        List<EmailMessage> emailMes = [Select ID, ParentId, ToAddress, Subject, 
                                ccaddress, fromaddress, fromName, htmlbody, messageDate, 
                                status, textbody, Incoming
                                From EmailMessage   
                                Where ID =: emailRecordString];    
                                
        system.debug(emailRecordString); 
        
        //Loop through and get case Ids from emailMessage list
        For(EmailMessage em : emailMes){
        
            if(em.ParentId != null){
                lstCaseStr.add(em.ParentID);
                EmailMessage emClone = em.Clone(false,true, true, false);
            }
        }
    
        //get list of cases with parentID and add to map        
        For(Case cSearch :[Select Id, Status, AccountID, ContactID, EBS_Order_ID__c,
                        Recordtype.Name, ParentID
                        From Case 
                        Where ParentId =: lstCaseStr]){
            
            mpClarCase.put(cSearch.ParentId, cSearch);                      
        }
        
        //Loop through email message list to create case and add an email
        For(EmailMessage emLoop : emailMes){
            System.debug('Entered in ClarificationEmailHANDLER For Loop');
            if(mpClarCase.get(emLoop.ParentID) == null || mpClarCase.get(emLoop.ParentID).RecordType.Name != 'Case' ) {
                 System.debug('Entered in ClarificationEmailHANDLER If Loop');
                //Create Case and clone email 
                EmailMessage emClone = emLoop.Clone(false,true, true, false);
                mpClarEmail.put(emLoop.ParentId, emClone);
                system.debug(emClone);
                
                Case cClari = new Case();
                cClari.ParentID = emLoop.ParentID;
                cClari.RecordTypeID = rt.ID;
                cClari.Case_Reason_Type__c = 'Email';
                if(emLoop.Status != 'Draft' && emLoop.Status != 'Sent'){
                    cClari.Status = 'Customer Response';
                }
                
                cClari.Origin = 'Phone';
                cClari.Customer_To_Email__c = emLoop.ToAddress;
                //cClari.Subject = 'Customer Response on Parent Clarication Case';
                cClari.Subject = emLoop.Subject;
                cClari.Type = 'Question';
                
                 Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    
                    cClari.setOptions(dmlOpts);
                
                lstEmailCaseIns.add(cClari);
                
                
            } 
            //if the recordtype is regular case update the status as customer response
            else if( mpClarCase.get(emLoop.ParentID).RecordType.Name == 'Case' && emLoop.Status != 'Draft' && emLoop.Status != 'Sent') 
            {
                
                //Update case and clone email
                EmailMessage emClone = emLoop.Clone(false,true, true, false);
                mpClarEmail.put(emLoop.ParentId, emClone);
                system.debug(emClone);
                
                
                
                Case cClari = mpClarCase.get(emLoop.ParentID);               
                if(emLoop.Status != 'Draft' && emLoop.Status != 'Sent'){
                    cClari.Status = 'Customer Response';
                }
                
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                    dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.Id;
                    
                    cClari.setOptions(dmlOpts);
                
                lstEmailCaseUpd.add(cClari);
            }      

        }
        
        List<Case> cUpdIns = new List<Case>();
        
        //Insert or update case, create email and associate to case
        if(lstEmailCaseIns.size() > 0){
            insert lstEmailCaseIns;
            cUpdIns.addAll(lstEmailCaseIns);
            system.debug('#####Insert####');
        }
        
        if(lstEmailCaseUpd.size() > 0){
            update lstEmailCaseUpd;
            cUpdIns.addAll(lstEmailCaseUpd);
            system.debug('#####Update####');
        }
        
        //Loop through case to associate case to email 
        For(Case cEmail : cUpdIns){
            system.debug('#####CheckingParent####');
            
            EmailMessage emCase = mpClarEmail.get(cEmail.ParentID);
            system.debug(emCase);
            emCase.ParentID = cEmail.ID;
            system.debug(emCase);
            lstEmailClone.add(emCase);
        }
        
        //Insert Emails
        if(lstEmailClone.size() > 0){
            system.debug('#####InsertEmail####');
            insert lstEmailClone;
        }       
    }
}