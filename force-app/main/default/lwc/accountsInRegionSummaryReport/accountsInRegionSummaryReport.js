import { LightningElement, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import jspdf from "@salesforce/resourceUrl/jsPDF";
import getSalesManagersInUsersTerritory from "@salesforce/apex/UserController.getSalesManagersInUsersTerritory";
import getOppsSummaryBySalesManagersAndPeriod from "@salesforce/apex/OpportunityController.getOppsSummaryBySalesManagersAndPeriod";
import ID from "@salesforce/user/Id";

export function getCurrenDateTime() {
  const dateOptions = {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric"
  };
  const today = new Date();
  const currentDate = today.toLocaleDateString("en-US", dateOptions);
  return currentDate;
}

const ALL = { value: "THIS_YEAR", label: "All" };
const LAST_WEEK = { value: "LAST_WEEK", label: "Last week" };
const LAST_MONTH = { value: "LAST_MONTH", label: "Last month" };
const LAST_YEAR = { value: "LAST_YEAR", label: "Last year" };

/** @type {Option[]} */
const OPTIONS = [ALL, LAST_WEEK, LAST_MONTH, LAST_YEAR];

/** @type {DatatableColumn[]} */
const COLUMNS = [
  {
    label: "Account",
    fieldName: "accountUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "accountName" } },
    target: "_blank"
  },
  {
    label: "Total Quantity Ordered",
    fieldName: "totalQuantity",
    type: "number"
  },
  {
    label: "Total Amount",
    fieldName: "totalAmount",
    type: "currency"
  }
];

export default class CustomersInRegionSummaryReport extends LightningElement {
  isStaticResourceLoaded = false;
  columns = COLUMNS;
  options = OPTIONS;
  userId = ID;
  defaultClosedDateValue = ALL.value;
  closedDateValue = this.defaultClosedDateValue;
  /** @type {OpportunitiesSummaryDTO[]} */
  data = [];
  /** @type {UserDTO[]} */
  _salesManagers = [];
  salesManagersIds = [];
  selectedSalesManager = "All";
  headers = this.createHeaders(this.columns.map((c) => c.fieldName));

  renderedCallback() {
    if (this.isStaticResourceLoaded) return;
    Promise.all([loadScript(this, jspdf)]).then(() => {
      this.isStaticResourceLoaded = true;
    });
  }

  generatePDF() {
    const { jsPDF } = window.jspdf;
    const document = new jsPDF();
    const currentDate = getCurrenDateTime();
    const documentText = [
      `Accounts Summary Report ${currentDate}`,
      `Sales Manager: ${this.selectedSalesManagerName}`,
      `Time Frame: ${this.selectedTimeFrameName}`
    ];
    document.text(documentText, 20, 20);
    document.table(20, 40, this.data, this.headers, { autosize: true });
    document.save(
      `Accounts_Summary_Report_${this.selectedSalesManager}_${this.selectedTimeFrameName}.pdf`
    );
  }

  /**
   * @param {string[]} headers
   * @returns {TableHeader[]}
   */
  createHeaders(headers) {
    return headers.map((header) => {
      return {
        id: header,
        name: header,
        prompt: header,
        width: 65,
        align: "center",
        padding: 0
      };
    });
  }

  @wire(getSalesManagersInUsersTerritory, { userId: "$userId" })
  wiredSalesManagers({ error, data }) {
    if (data) {
      this.salesManagers = data;
      this.error = undefined;
    } else if (error) {
      this.salesManagers = [];
      this.error = error;
    }
  }

  @wire(getOppsSummaryBySalesManagersAndPeriod, {
    salesManagersIds: "$salesManagersIds",
    periodFrame: "$closedDateValue"
  })
  wiredData({ error, data }) {
    if (data) {
      this.data = data;
      this.error = undefined;
    } else if (error) {
      this.data = [];
      this.error = error;
    }
  }

  handleSelectedSalesManagerChange(event) {
    this.selectedSalesManager = event.detail.value;
    if (this.selectedSalesManager === "All") {
      this.salesManagersIds = this._salesManagers.map((s) => s.id);
    } else {
      this.salesManagersIds = this._salesManagers
        .filter((s) => s.id === this.selectedSalesManager)
        .map((s) => s.id);
    }
  }

  handleClosedDateValueChange(event) {
    this.closedDateValue = event.detail.value;
  }

  handleGeneratePDFReport() {
    this.generatePDF();
  }

  /** @param {UserDTO[]} value*/
  set salesManagers(value) {
    this._salesManagers = value;
    this.salesManagersIds = value.map((s) => s.id);
  }

  get salesManagers() {
    return this._salesManagers;
  }

  get selectedSalesManagerName() {
    const salesManager = this.salesManagers.find(
      (s) => s.id === this.selectedSalesManager
    );
    return salesManager ? salesManager.name : "All";
  }

  get selectedTimeFrameName() {
    switch (this.closedDateValue) {
      case "THIS_YEAR":
        return "All";
      case "LAST_WEEK":
        return "Last Week";
      case "LAST_MONTH":
        return "Last Month";
      case "LAST_YEAR":
        return "Last Year";
      default:
        return "All";
    }
  }

  /** @type {Option[]} */
  get salesManagersOptions() {
    return [
      { label: "All", value: "All" },
      ...this.salesManagers.map((s) => {
        return {
          label: s.name,
          value: s.id
        };
      })
    ];
  }

  get summaryInfo() {
    return `Sales Manager ${this.selectedSalesManagerName} • Time Frame ${this.selectedTimeFrameName}`;
  }
}
