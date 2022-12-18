import { LightningElement, api, wire } from "lwc";
import B2B_SITE_LOGO from "@salesforce/resourceUrl/B2B_Site_Logo";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ASSIGNED_SALES_MANAGER_FIELD from "@salesforce/schema/Account.Assigned_Sales_Manager__c";

export default class SiteHeader extends LightningElement {
  @api accountId = "";
  siteLogo = B2B_SITE_LOGO;

  @wire(getRecord, {
    recordId: "$accountId",
    fields: [ASSIGNED_SALES_MANAGER_FIELD]
  })
  account;

  get accountAssignedSalesManager() {
    return getFieldValue(this.account.data, ASSIGNED_SALES_MANAGER_FIELD);
  }

  handleSendEmail() {
    this.template.querySelector("c-send-email-modal").openModal();
  }
}
