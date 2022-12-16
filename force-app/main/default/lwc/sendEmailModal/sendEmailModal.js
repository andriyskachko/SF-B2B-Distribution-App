import LightningModal from "lightning/modal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { api } from "lwc";

export default class SendEmailModal extends LightningModal {
  /** @type {string[]} */
  @api recipients = [];
  topic = "";
  emailBody = "";

  send() {
    // Add sending logic via EmailController Apex class
    // Add Error handling logic
    this.close();
  }

  showEmailFailedSendingToast(errorMessage) {
    const event = new ShowToastEvent({
      title: "Email has been sent",
      message: errorMessage,
      variant: "error"
    });

    this.dispatchEvent(event);
  }

  handleSendEmail() {
    this.send(this.recipients, this.topic, this.emailBody);
    this.close(true);
  }
}
