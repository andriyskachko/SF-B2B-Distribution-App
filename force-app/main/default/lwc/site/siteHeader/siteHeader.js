import { LightningElement, api } from "lwc";
import SendEmailModal from "c/sendEmailModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountAssignedSalesManagerEmail from "@salesforce/apex/AccountController.getAccountAssignedSalesManagerEmail";

export default class SiteHeader extends LightningElement {
  @api accountId = "";
  assignedSalesManagerEmail = "";

  connectedCallback() {
    this.getAssignedSalesManagerEmail();
  }

  async handleSendEmail() {
    const success = await SendEmailModal.open({
      size: "small",
      recipients: [this.assignedSalesManagerEmail]
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

  async getAssignedSalesManagerEmail() {
    try {
      const email = await getAccountAssignedSalesManagerEmail(this.accountId);
      this.assignedSalesManagerEmail = email;
      console.log("Found Email: " + this.assignedSalesManagerEmail);
    } catch (error) {
      console.log(error);
    }
  }
}
