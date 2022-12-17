import { LightningElement } from "lwc";

export default class OrderCart extends LightningElement {
  productItems = [];

  get cartSize() {
    return 3;
  }
}
