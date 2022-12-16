import LightningModal from "lightning/modal";
import { api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class SendEmailModal extends LightningModal {
  /** @type {string[]} */
  @api recipients = [];
  topic = "";
  emailBody = "";

  async send() {
    // sending email logic through apex class EmailController
  }

  showEmailFailedSendingToast(errorMessage) {
    const event = new ShowToastEvent({
      title: "Email has been sent",
      message: errorMessage,
      variant: "error"
    });

    this.dispatchEvent(event);
  }

  handleClose() {
    this.close();
  }

  async handleSendEmail() {
    try {
      const response = await this.send();
      this.close(response);
    } catch (error) {
      this.showEmailFailedSendingToast(error.message);
    }
  }
}
