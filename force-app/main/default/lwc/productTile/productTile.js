import { LightningElement, api } from "lwc";
import DEFAULT_PRODUCT_IMAGE from "@salesforce/resourceUrl/B2B_Default_Product_Image";

export default class ProductTile extends LightningElement {
  @api product;
  quantity = 1;
  isAddedToCart = false;

  @api
  get addedToCart() {
    return this.isAddedToCart;
  }
  set addedToCart(value) {
    this.isAddedToCart = value;
  }

  @api
  get defaultQuantity() {
    return this.quantity;
  }
  set defaultQuantity(value) {
    this.quantity = value;
  }

  handleAddToCart() {
    this.isAddedToCart = true;
    this.dispatchEvent(
      new CustomEvent("addedtocart", {
        detail: {
          productId: this.product.Id,
          selectedQuantity: this.quantity
        }
      })
    );
  }

  handleRemoveFromCart() {
    this.isAddedToCart = false;
    this.dispatchEvent(
      new CustomEvent("removedfromcart", {
        detail: {
          productId: this.product.Id
        }
      })
    );
  }

  handleChange(event) {
    this.quantity = event.target.value;
  }

  get backgroundStyle() {
    return `background-image:url(${DEFAULT_PRODUCT_IMAGE})`;
  }

  get totalPrice() {
    return this.quantity * this.product.Display_Price__c;
  }
}