import { LightningElement, wire } from "lwc";
import { publish, MessageContext } from "lightning/messageService";
import CUSTOMER_LOGGED_OUT from "@salesforce/messageChannel/CustomerLoggedOut__c";
import "./customerLogo.css";

export default class CustomerLogo extends LightningElement {
  @wire(MessageContext)
  messageContext;

  handleLogout() {
    publish(this.messageContext, CUSTOMER_LOGGED_OUT);
  }
}
