import { LightningElement, api, track, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import createNewOpportunityForAccount from "@salesforce/apex/OpportunityController.createNewOpportunityForAccount";
import CUSTOMER_CANCELED_ORDER from "@salesforce/messageChannel/CustomerCanceledOrder__c";

export default class OrderCartModal extends LightningElement {
  @track isModalOpen = false;
  /** @type {ProductEntryInCart[]} */
  @api products = [];
  @api accountId = "";
  error;
  isLoading = true;

  @wire(MessageContext)
  messageContext;

  renderedCallback() {
    this.isLoading = false;
  }

  get cartSize() {
    return this.products.length;
  }

  get orderTotal() {
    return this.products.reduce((total, product) => {
      return total + product.listPrice * product.quantity;
    }, 0);
  }

  @api
  openModal() {
    this.isModalOpen = true;
  }

  @api
  closeModal() {
    this.isModalOpen = false;
  }

  handleCancelOrder() {
    publish(this.messageContext, CUSTOMER_CANCELED_ORDER);
    this.closeModal();
  }

  async handleConfirmOrder() {
    try {
      this.isLoading = true;
      const response = await createNewOpportunityForAccount({
        accountId: this.accountId.accountId,
        products: this.products
      });
      if (response) this.closeModal();
    } catch (error) {
      this.error = error.body.message;
      this.isLoading = false;
    }
  }
}
