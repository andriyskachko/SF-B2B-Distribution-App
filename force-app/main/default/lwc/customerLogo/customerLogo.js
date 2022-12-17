import { LightningElement, wire, api } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import { publish, MessageContext } from "lightning/messageService";
import CUSTOMER_LOGGED_OUT from "@salesforce/messageChannel/CustomerLoggedOut__c";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import "./customerLogo.css";

export default class CustomerLogo extends LightningElement {
  @api accountId = "";

  @wire(getRecord, { recordId: "$accountId", fields: [NAME_FIELD] })
  account;

  @wire(MessageContext)
  messageContext;

  get accountName() {
    return getFieldValue(this.account.data, NAME_FIELD);
  }

  get accountInitials() {
    return this.accountName
      ? this.accountName
          .split(" ")
          .slice(0, 2)
          .map((word) => word[0])
          .join("")
      : "";
  }

  handleLogout() {
    console.log("Customer logged out");
    publish(this.messageContext, CUSTOMER_LOGGED_OUT, {});
  }
}
