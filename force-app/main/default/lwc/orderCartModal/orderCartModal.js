import { LightningElement, api, track } from "lwc";
import createNewOpportunityForAccount from "@salesforce/apex/OpportunityController.createNewOpportunityForAccount";

export default class OrderCartModal extends LightningElement {
  @track isModalOpen = false;
  /** @type {ProductEntryInCart[]} */
  @api products = [];
  @api accountId = "";
  error;

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

  async handleConfirmOrder() {
    try {
      const response = await createNewOpportunityForAccount({
        accountId: this.accountId,
        lstOppOrder: this.products
      });

      if (response) this.closeModal();
    } catch (error) {
      this.error = error.body.message;
    }
  }
}
