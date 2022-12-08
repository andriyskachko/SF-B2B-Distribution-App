import { LightningElement, wire } from "lwc";
import getSalesManagersInUsersTerritory from "@salesforce/apex/UserController.getSalesManagersInUsersTerritory";
import getOppsSummaryBySalesManagersAndPeriod from "@salesforce/apex/OpportunityController.getOppsSummaryBySalesManagersAndPeriod";
import ID from "@salesforce/user/Id";

const ALL = { value: "ALL", label: "All" };
const LAST_WEEK = { value: "LAST_WEEK", label: "Last week" };
const LAST_MONTH = { value: "LAST_MONTH", label: "Last month" };
const LAST_YEAR = { value: "LAST_YEAR", label: "Last year" };

/** @type {Option[]} */
const OPTIONS = [ALL, LAST_WEEK, LAST_MONTH, LAST_YEAR];

/** @type {DatatableColumn[]} */
const COLUMNS = [
  {
    label: "Customer",
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
  columns = COLUMNS;
  options = OPTIONS;
  userId = ID;
  defaultClosedDateValue = ALL.value;
  closedDateValue = this.dateClosedDateDefaultValue;
  data = [];
  /** @type {UserDTO[]} */
  salesManagers = [];
  selectedSalesManager = "";

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
    console.log("report created");
  }

  get salesManagersIds() {
    return this.salesManagers.map((s) => s.id);
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
