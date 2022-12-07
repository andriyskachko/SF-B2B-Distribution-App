import { LightningElement, wire } from "lwc";
import getAssignedAccounts from "@salesforce/apex/AccountController.getAssignedAccounts";
import {
  MessageContext,
  publish,
  APPLICATION_SCOPE
} from "lightning/messageService";
import ACCOUNT_IS_SELECTED_CHANNEL from "@salesforce/messageChannel/AccountIsSelectedChannel__c";
import ACCOUNT from "@salesforce/schema/Account";
import ID from "@salesforce/user/Id";

/** @type {DatatableColumn[]} */
const COLUMNS = [
  {
    label: "Account",
    fieldName: "accountURL",
    type: "url",
    typeAttributes: { label: { fieldName: "accountName" } },
    target: "_blank",
    sortable: true
  },
  {
    label: "Last Activity Date",
    fieldName: "lastActivityDate",
    type: "text",
    sortable: true
  }
];

export default class SalesManagersAssignedAccounts extends LightningElement {
  objectApiName = ACCOUNT;
  userId = ID;
  columns = COLUMNS;
  searchKeyword = "";
  defaultSortDirection = "asc";
  sortDirection = this.defaultSortDirection;
  sortedBy = "";
  error;
  /** @type {Account[]} */
  _assignedAccounts = [];
  /** @type {Account[]} */
  filteredAccounts = [];
  isLoading = true;

  renderedCallback() {
    this.isLoading = false;
  }

  @wire(getAssignedAccounts, { userId: "$userId" })
  wiredAssignedAccounts({ error, data }) {
    if (data) {
      this.assignedAccounts = data;
      this.error = undefined;
      this.publishPayload();
    } else if (error) {
      this.error = error;
      this.assignedAccounts = [];
    }
  }

  @wire(MessageContext)
  messageContext;

  /** @param {Account[]} value */
  set assignedAccounts(value) {
    this._assignedAccounts = value;
    this.filteredAccounts = this._assignedAccounts;
  }

  get data() {
    return this.filteredAccounts;
  }

  get isData() {
    return this.data.length > 0;
  }

  handleSearch(event) {
    this.isLoading = true;
    this.searchKeyword = event.detail.value.strip().toLowerCase();
    this.filteredAccounts = this._assignedAccounts.filter((account) => {
      const { name } = account;
      const regex = new RegExp(this.searchString);
      return regex.test(name);
    });
    this.isLoading = false;
    this.publishPayload();
  }

  handleSort(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortDirection);
  }

  publishPayload() {
    const payload = { lstAccountIds: this.filteredAccounts.map((a) => a.id) };
    publish(this.messageContext, ACCOUNT_IS_SELECTED_CHANNEL, payload, {
      scope: APPLICATION_SCOPE
    });
  }

  sortData(fieldName, direction) {
    const parsedData = JSON.parse(JSON.stringify(this.data));
    const key = (a) => a[fieldName];
    const isReverse = direction === "asc" ? 1 : -1;
    parsedData.sort((a, b) => {
      a = key(a) ? key(a) : "";
      b = key(b) ? key(b) : "";
      return isReverse * ((a > b) - (b > a));
    });
    this._filteredAccounts = parsedData;
  }
}
