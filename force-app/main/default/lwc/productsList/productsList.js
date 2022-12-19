import { LightningElement, api, wire } from "lwc";
import {
  publish,
  MessageContext,
  subscribe,
  unsubscribe
} from "lightning/messageService";
import getProductItemsInWarehouseForAccount from "@salesforce/apex/WarehouseController.getProductItemsInWarehouseForAccount";
import PRODUCT_ADDED_TO_CART from "@salesforce/messageChannel/ProductAddedToCart__c";
import PRODUCT_REMOVED_FROM_CART from "@salesforce/messageChannel/ProductRemovedFromCart__c";
import CUSTOMER_CANCELED_ORDER from "@salesforce/messageChannel/CustomerCanceledOrder__c";

export default class ProductsList extends LightningElement {
  @api accountId = "";
  /** @type {ProductEntry[]} */
  products = [];
  error;
  isLoading = true;
  subscriptions = [];
  productTiles = [];

  connectedCallback() {
    this.initSubscriptions();
    this.getAvailableProductsForAccount();
  }

  disconnectedCallback() {
    this.terminateSubscriptions();
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
      this.isLoading = false;
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

  initSubscriptions() {
    this.initCustomerCanceledOrderSubscription();
  }

  terminateSubscriptions() {
    this.subscriptions.forEach((sub) => unsubscribe(sub));
  }

  initCustomerCanceledOrderSubscription() {
    const sub = subscribe(
      this.messageContext,
      CUSTOMER_CANCELED_ORDER,
      this.handleCustomerCanceledOrder
    );

    this.subscriptions.push(sub);
  }

  handleCustomerCanceledOrder() {
    console.log(this.productTiles);
  }

  get areProducts() {
    return this.products.length > 0;
  }

  @wire(MessageContext)
  messageContext;
}
