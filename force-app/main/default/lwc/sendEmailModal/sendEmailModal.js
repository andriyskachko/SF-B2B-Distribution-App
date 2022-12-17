import LightningModal from "lightning/modal";
import { api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import sendEmail from "@salesforce/apex/EmailController.sendEmail";

export default class SendEmailModal extends LightningModal {
  @api recipientIds = [];
  topic = "";
  emailBody = "";

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
      const response = await sendEmail({
        recipientIds: this.recipientIds,
        topic: this.topic,
        body: this.body
      });
      this.close(response);
    } catch (error) {
      this.showEmailFailedSendingToast(error.message);
    }
  }
}
