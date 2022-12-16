import { LightningElement, wire, api } from "lwc";
import { getFieldValue, getRecord } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Account.Name";
import "./customerLogo.css";

const FIELDS = [NAME_FIELD];

export default class CustomerLogo extends LightningElement {
  error;
  @api accountId = "";

  @wire(getRecord, { recordId: "$accountId", fields: FIELDS })
  account;

  get accountName() {
    return getFieldValue(this.account.data, NAME_FIELD);
  }

  get accountInitials() {
    return this.accountName
      ? this.accountName
          .split(" ")
          .slice(0, 2)
          .map((w) => w[0])
          .join("")
      : "";
  }

  handleLogout() {
    console.log("logout");
  }
}
