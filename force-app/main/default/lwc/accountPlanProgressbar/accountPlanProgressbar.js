import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import TARGET_FIELD from "@salesforce/schema/AccountPlan.Target__c";
import ACCOUNTID_FIELD from "@salesforce/schema/AccountPlan.AccountId";
import YTDREVENUE_FIELD from "@salesforce/schema/Account.YTD_Revenue__c";

const FIELDS = [TARGET_FIELD, ACCOUNTID_FIELD];

export default class AccountPlanProgressbar extends LightningElement {

  @api recordId;
  percentage = 0

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  accountPlan;

  @wire(getRecord, { recordId: "$accountId", fields: [YTDREVENUE_FIELD] })
  accounts;

  get accountId() {
    return getFieldValue(this.accountPlan.data, ACCOUNTID_FIELD);
  }

  get target() {
    return getFieldValue(this.accountPlan.data, TARGET_FIELD)
  }

  get ytdRevenue() {
    return getFieldValue(this.accounts.data, YTDREVENUE_FIELD)
    }


  get percent() {
    return (this.ytdRevenue / this.target) * 100
  }


}