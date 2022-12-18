import { LightningElement, api, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import getProductItemsInWarehouseForAccount from "@salesforce/apex/WarehouseController.getProductItemsInWarehouseForAccount";
import PRODUCT_ADDED_TO_CART from "@salesforce/messageChannel/ProductAddedToCart__c";
import PRODUCT_REMOVED_FROM_CART from "@salesforce/messageChannel/ProductRemovedFromCart__c";

export default class ProductsList extends LightningElement {
  @api accountId = "";
  /** @type {ProductEntry[]} */
  products = [];
  error;
  isLoading = true;

  connectedCallback() {
    this.getAvailableProductsForAccount();
  }

  async getAvailableProductsForAccount() {
    try {
      const response = await getProductItemsInWarehouseForAccount({
        accountId: this.accountId
      });
      this.products = response;
      this.isLoading = false;
    } catch (error) {
      this.error = error;
    }
  }

  handleProductAdded({ detail: { product } }) {
    publish(this.messageContext, PRODUCT_ADDED_TO_CART, {
      product: product
    });
  }

  handleProductRemoved({ detail: { productId } }) {
    publish(this.messageContext, PRODUCT_REMOVED_FROM_CART, {
      productId: productId
    });
  }

  get areProducts() {
    return this.products.length > 0;
  }

  @wire(MessageContext)
  messageContext;
}
