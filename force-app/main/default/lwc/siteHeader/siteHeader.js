import { LightningElement, api, wire } from "lwc";
import SendEmailModal from "c/sendEmailModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ASSIGNED_SALES_MANAGER_FIELD from "@salesforce/schema/Account.Assigned_Sales_Manager__c";

export default class SiteHeader extends LightningElement {
  @api accountId = "";

  connectedCallback() {
    this.getAssignedSalesManagerEmail();
  }

  @wire(getRecord, {
    recordId: "$accountId",
    fields: [ASSIGNED_SALES_MANAGER_FIELD]
  })
  account;

  async handleSendEmail() {
    const success = await SendEmailModal.open({
      size: "small",
      recipientIds: [this.accountAssignedSalesManager]
    });

    if (success) {
      this.showEmailSentToast();
    }
  }

  showEmailSentToast() {
    const event = new ShowToastEvent({
      title: "Email has been sent",
      variant: "success"
    });

    this.dispatchEvent(event);
  }

  get accountAssignedSalesManager() {
    return getFieldValue(this.account.data, ASSIGNED_SALES_MANAGER_FIELD);
  }
}
