import { api, LightningElement } from "lwc";
import getAccountOpportunityOrders from "@salesforce/apex/OpportunityController.getAccountOpportunityOrders";

/** @type {DatatableColumn[]} */
const COLUMNS = [
  { label: "Order", type: "text", fieldName: "name" },
  { label: "Status", type: "text", fieldName: "status" },
  { label: "Summary", type: "currency", fieldName: "orderSummary" }
];

export default class OrderHistory extends LightningElement {
  @api accountId = "";
  columns = COLUMNS;
  /** @type {OrderSummary[]} */
  orders = [];
  error;
  isLoading = true;

  connectedCallback() {
    this.getOrders();
  }

  handlePrintOrders() {
    console.log("Hi DEMO!");
  }

  async getOrders() {
    try {
      const response = await getAccountOpportunityOrders({
        accountId: this.accountId
      });
      this.orders = response.map((o) => {
        return { ...o, _children: o.children };
      });
      this.isLoading = false;
    } catch (error) {
      this.erorr = error;
      this.isLoading = false;
    }
  }
}
