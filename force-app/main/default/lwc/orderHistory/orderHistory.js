import { api, LightningElement } from "lwc";

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
  orders = [
    {
      name: "Order from 12-10-22",
      status: "Closed",
      orderSummary: 1500,
      _children: [
        {
          name: "BiG Fallos",
          orderSummary: 1000
        },
        {
          name: "Eldak)",
          orderSummary: 500
        }
      ]
    }
  ];

  connectedCallback() {
    this.getOrders();
  }

  getOrders() {
    // get orders via apex for Account ID
  }

  handlePrintOrders() {}
}
