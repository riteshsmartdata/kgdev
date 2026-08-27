/**
 * @description       : 
 * @author            : Ritesh Kumar
 * @group             : 
 * @last modified on  : 06-30-2023
 * @last modified by  : Ritesh Kumar
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   06-02-2023   Ritesh Kumar   Initial Version
**/
import { LightningElement,track,api } from 'lwc';
import getConversationContextEntry from '@salesforce/apex/ChatVisitorDetails.getConversationContextEntry';

export default class ChatVisitorDeatils extends LightningElement {
    @api recordId;
    @track isDataFound = false;
    @track LastName;
    @track FirstName;
    @track Email;
    @track Subject; 
    @track AccountNumber;

    connectedCallback() {
        getConversationContextEntry({
            parentId : this.recordId 
        }).then(result=>{
            console.log('=====result=====> ',result);
            if(result){
                this.isDataFound = true;
                result.forEach((visitor, index) => {
                    if(visitor.CustomDetailContextKey == 'First Name'){
                        this.FirstName = visitor.CustomDetailContextValue;
                    }
                    if(visitor.CustomDetailContextKey == 'Last Name'){
                        this.LastName = visitor.CustomDetailContextValue;
                    }
    
                    if(visitor.CustomDetailContextKey == 'Email'){
                        this.Email = visitor.CustomDetailContextValue;
                    }
    
                    if(visitor.CustomDetailContextKey == 'How may we help you?'){
                        this.Subject = visitor.CustomDetailContextValue;
                    }

                    if(visitor.CustomDetailContextKey == 'Account Number'){
                        this.AccountNumber = visitor.CustomDetailContextValue;
                    }
                });
            }
           
        }).catch(error=> {
            this.isDataFound = false;
            console.log('=====error=====> ',error);
        });
    }
}