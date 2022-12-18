import { LightningElement, api, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import PRODUCT_ADDED_TO_CART from "@salesforce/messageChannel/ProductAddedToCart__c";
import PRODUCT_REMOVED_FROM_CART from "@salesforce/messageChannel/ProductRemovedFromCart__c";

export default class ProductsList extends LightningElement {
  @api products = [
    {
      Id: 1,
      ImageUrl__c: "/sfc/servlet.shepherd/version/download/0682w000003XwElAAK",
      productName: "Test 1",
      Display_Price__c: 100,
      Quantity: 1,
      Name: "Test"
    },
    {
      Id: 2,
      ImageUrl__c: "/sfc/servlet.shepherd/version/download/0682w000003XwEmAAK",
      productName: "Test 1",
      Display_Price__c: 100,
      Quantity: 1,
      Name: "Test 2"
    },
    {
      Id: 3,
      ImageUrl__c: "/sfc/servlet.shepherd/version/download/0682w000003XwEnAAK",
      productName: "Test 1",
      Display_Price__c: 100,
      Quantity: 1,
      Name: "Test 3"
    },
    {
      Id: 4,
      ImageUrl__c: "/sfc/servlet.shepherd/version/download/0682w000003XwEnAAK",
      productName: "Test 1",
      Display_Price__c: 100,
      Quantity: 1,
      Name: "Test 4"
    },
    {
      Id: 5,
      ImageUrl__c: "/sfc/servlet.shepherd/version/download/0682w000003XwEnAAK",
      productName: "Test 1",
      Display_Price__c: 100,
      Quantity: 1,
      Name: "Test 5"
    }
  ];

  handleProductAdded({ detail: { productId, selectedQuantity } }) {
    publish(this.messageContext, PRODUCT_ADDED_TO_CART, {
      productId: productId,
      quantity: selectedQuantity
    });
  }
  handleProductRemoved({ detail: { productId } }) {
    publish(this.messageContext, PRODUCT_REMOVED_FROM_CART, {
      productId: productId
    });
  }

  @wire(MessageContext)
  messageContext;
}
