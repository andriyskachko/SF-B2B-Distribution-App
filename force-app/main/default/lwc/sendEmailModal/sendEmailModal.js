import { LightningElement, track, api } from "lwc";
import sendEmail from "@salesforce/apex/EmailController.sendEmail";

export default class SendEmailModal extends LightningElement {
  @track isModalOpen = false;
  @api salesManagerId = "";
  topic = "";
  body = "";
  isValid = false;
  error;

  handleTopicChange({ target: { value } }) {
    this.topic = value;
  }

  handleBodyChange({ target: { value } }) {
    this.body = value;
  }

  @api
  openModal() {
    this.isModalOpen = true;
  }

  @api
  closeModal() {
    this.isModalOpen = false;
  }

  handleSubmit(event) {
    event.preventDefault();
    const fields = event.detail.fields;
    this.props.forEach((prop) => {
      fields[prop.fieldName] = prop.value;
    });

    this.template.querySelector("lightning-record-form").submit(fields);
  }

  validateInputs() {
    const areInputsValid = [
      ...this.template.querySelectorAll("lightning-input"),
      ...this.template.querySelectorAll("lightning-textarea")
    ].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);

    return areInputsValid;
  }

  async handleSendEmail() {
    if (this.validateInputs()) {
      try {
        const response = await sendEmail({
          recipientIds: [this.salesManagerId],
          topic: this.topic,
          body: this.body
        });
        if (response) this.closeModal();
        else this.error = "Unknown error occured";
      } catch (error) {
        this.error = error;
      }
    }
  }
}
