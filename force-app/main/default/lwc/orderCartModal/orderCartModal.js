import { LightningElement, api, track } from "lwc";

export default class OrderCartModal extends LightningElement {
  @track isModalOpen = false;
  @api products = [];

  get cartSize() {
    return this.products.length;
  }

  get orderTotal() {
    return this.products.reduce((total, product) => {
      return total + product.price * product.quantity;
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
}
