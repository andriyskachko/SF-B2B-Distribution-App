import { LightningElement, api, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import PRODUCT_ADDED_TO_CART from "@salesforce/messageChannel/ProductAddedToCart__c";
import PRODUCT_REMOVED_FROM_CART from "@salesforce/messageChannel/ProductRemovedFromCart__c";

export default class ProductsList extends LightningElement {
  @api accountId = "";
  @api products = [
    {
      id: "0dad7ff1-4b11-4de6-bfbb-ddd394d03570",
      productName: "Cheese - Comtomme",
      price: 4,
      quatity: 3
    },
    {
      id: "b1bcf53b-5b86-4272-b083-ea0b0ce87629",
      productName: "Wine - Red, Cabernet Sauvignon",
      price: 6,
      quatity: 2
    },
    {
      id: "aba8dbc4-fbc9-4503-9c6a-14608ca9002e",
      productName: "Salmon - Fillets",
      price: 5,
      quatity: 2
    },
    {
      id: "4ed5eb16-8b84-4c34-aed5-15eccedf907a",
      productName: "Fish - Scallops, Cold Smoked",
      price: 2,
      quatity: 2
    },
    {
      id: "cb4079dc-26d1-49cd-9b3a-1a2cc301077a",
      productName: "Beer - Heinekin",
      price: 2,
      quatity: 1
    },
    {
      id: "cab963f2-2df0-4a5d-98be-76f352787c1c",
      productName: "Salt - Kosher",
      price: 3,
      quatity: 3
    },
    {
      id: "d98a8426-abd9-4082-bafd-5fc25c2a3875",
      productName: "Cheese - Victor Et Berthold",
      price: 9,
      quatity: 1
    },
    {
      id: "d9e6d96c-2dd9-4d05-865b-d65d35d4bf3f",
      productName: "Water - Spring 1.5lit",
      price: 10,
      quatity: 2
    },
    {
      id: "d7c5294a-0932-43f3-bb94-17994bdf47ad",
      productName: "Beef - Ground Lean Fresh",
      price: 4,
      quatity: 3
    },
    {
      id: "765a64b8-1f48-4374-a7ac-87ebc89b8599",
      productName: "Salmon - Atlantic, Skin On",
      price: 9,
      quatity: 2
    },
    {
      id: "a8f1cd43-54e7-448a-b7d3-a1b82fc7c396",
      productName: "Pork - Bacon, Sliced",
      price: 9,
      quatity: 3
    },
    {
      id: "a84231aa-5aef-46ee-b548-e11ddb56b10d",
      productName: "Wine - Barolo Fontanafredda",
      price: 5,
      quatity: 2
    },
    {
      id: "6c510117-4091-422c-b44a-c7b39893f5bc",
      productName: "Olives - Green, Pitted",
      price: 2,
      quatity: 3
    },
    {
      id: "0133a2cb-b550-425f-8def-2a5f0524fd3b",
      productName: "Pears - Bartlett",
      price: 9,
      quatity: 3
    },
    {
      id: "758d9d7a-e9aa-4d8d-94f2-c714ef21710f",
      productName: "Southern Comfort",
      price: 4,
      quatity: 1
    }
  ];

  connectedCallback() {
    this.getAvailableProductsForAccount();
  }

  getAvailableProductsForAccount() {
    // Set logic here (callout to apex)
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

  @wire(MessageContext)
  messageContext;
}
