/**
 * @description       : 
 * @author            : Kumar Saurav
 * @group             : 
 * @last modified on  : 05-08-2024
 * @last modified by  : Kumar Saurav
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   08-07-2023   Kumar Saurav   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import searchAccountAndLeads from '@salesforce/apex/AccountAndLeadSearch.searchAccountAndLeads';


export default class AccountAndLeadSearch extends LightningElement {
  @api recordId;
  accountrecord;
  connectedCallback() {
    searchAccountAndLeads({
      leadId: this.recordId,
    }).then(result => {
      this.accountrecord = JSON.parse(JSON.stringify(result));
      var index = 0;
      this.accountrecord.forEach(record => {
        record.linkName = '/' + record?.Id;
        index++;
        record.parentName = record?.Parent?.Name;
        record.addr = record?.BillingStreet + ' ' + record?.BillingCity + ' ' + record?.BillingState + ' ' + record?.BillingCountry + ' ' + record?.BillingPostalCode;
        record.sno = index;
        record.status = record?.Status__c;
      });
    }).catch(error => {
      console.log("====== Error =======", error);
    });
  }
}