import { LightningElement, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import jspdf from "@salesforce/resourceUrl/jsPDF";
import getSalesManagersInUsersTerritory from "@salesforce/apex/UserController.getSalesManagersInUsersTerritory";
import getOppsSummaryBySalesManagersAndPeriod from "@salesforce/apex/OpportunityController.getOppsSummaryBySalesManagersAndPeriod";
import ID from "@salesforce/user/Id";

function getCurrenDateTime() {
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

const ALL = { value: "ALL", label: "All" };
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
  closedDateValue = this.dateClosedDateDefaultValue;
  /** @type {OpportunitiesSummaryDTO[]} */
  data = [];
  /** @type {UserDTO[]} */
  salesManagers = [];
  selectedSalesManager = "";
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
      console.log(data);
    } else if (error) {
      this.data = [];
      this.error = error;
      console.log(error);
    }
  }

  handleClosedDateValueChange(event) {
    this.closedDateValue = event.detail.value;
  }

  handleGeneratePDFReport() {
    this.generatePDF();
  }

  get salesManagersIds() {
    return this.salesManagers.map((s) => s.id);
  }

  get selectedSalesManagerName() {
    const salesManager = this.salesManagers.find(
      (s) => s.id === this.selectedSalesManager
    );
    return salesManager ? salesManager.name : "All";
  }

  get selectedTimeFrameName() {
    switch (this.closedDateValue) {
      case "ALL":
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
    return this.salesManagers.map((s) => {
      return {
        label: s.name,
        value: s.id
      };
    });
  }

  //   @wire(getOpportunitiesSummary, {
  //     closeDateFilter: "$closeDateFilter",
  //     salesManagerId: "$salesManagerId"
  //   })
  //   wiredSummaryData({ error, data }) {
  //     if (data) {
  //       this.summaryData = data;
  //       this.wiredSummaryError = undefined;
  //     } else if (error) {
  //       this.summaryData = [];
  //       this.wiredSummaryError = error;
  //     }
  //   }

  //   @wire(getSalesManagersForOpportunityAccounts, {
  //     closeDateFilter: "$closeDateFilter",
  //     salesManagerId: "$salesManagerId"
  //   })
  //   wiredSalesManagers({ error, data }) {
  //     if (data) {
  //       this.salesManagers = data;
  //       this.error = undefined;
  //     } else if (error) {
  //       this.salesManagers = [];
  //       this.error = error;
  //     }
  //   }

  //   handleSalesManagerChange(event) {
  //     const salesManagerId = event.detail.value;
  //     this.salesManagerId = salesManagerId;
  //   }

  //   handleTimeFrameChange(event) {
  //     const timeFrame = event.detail.value;
  //     this.closeDateFilter = timeFrame;
  //   }

  //   handleCreateReport() {
  //     // const datatable = this.template.querySelector('lightning-datatable');
  //     this.generatePdf();
  //   }

  //   generatePdf() {
  //     const doc = new jsPDF({
  //       encryption: {
  //         userPassword: "user",
  //         ownerPassword: "owner",
  //         userPermissions: ["print", "modify", "copy", "annot-forms"]
  //         // try changing the user permissions granted
  //       }
  //     });

  //     doc.text("This is test pdf", 20, 20);
  //     doc.table(30, 30, this.summaryDataJSON, this.headers, { autosize: true });
  //     doc.save("demo.pdf");

  //     console.log(doc);
  //   }
}
