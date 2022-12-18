import { LightningElement, wire } from "lwc";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import PRODUCT_ADDED_TO_CART from "@salesforce/messageChannel/ProductAddedToCart__c";
import PRODUCT_REMOVED_FROM_CART from "@salesforce/messageChannel/ProductRemovedFromCart__c";

export default class OrderCart extends LightningElement {
  products = [];
  subscriptions = [];

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    this.initSubscriptions();
  }

  disconnectedCallback() {
    this.terminateSubscriptions();
  }

  initSubscriptions() {
    this.initProductAddedSubscription();
    this.initProductRemovedSubscription();
  }

  initProductAddedSubscription() {
    const sub = subscribe(
      this.messageContext,
      PRODUCT_ADDED_TO_CART,
      this.handleAddProduct
    );
    this.subscriptions.push(sub);
  }

  initProductRemovedSubscription() {
    const sub = subscribe(
      this.messageContext,
      PRODUCT_REMOVED_FROM_CART,
      this.handleRemoveProduct
    );
    this.subscriptions.push(sub);
  }

  terminateSubscriptions() {
    this.subscriptions.forEach((sub) => unsubscribe(sub));
  }

  handleAddProduct = ({ product }) => {
    this.products = [product, ...this.products];
  };

  handleRemoveProduct = ({ productId }) => {
    this.products = this.products.filter((product) => product.id !== productId);
  };

  handleOpenCart() {
    this.template.querySelector("c-order-cart-modal").openModal();
  }

  get cartSize() {
    return this.products.length >= 10 ? "*" : this.products.length;
  }

  get isCartEmpty() {
    return this.products.length === 0;
  }
}
