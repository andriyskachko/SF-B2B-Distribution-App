import { LightningElement, wire } from "lwc";
import getUserAssociatedWarehouse from "@salesforce/apex/UserController.getUserAssociatedWarehouse";
import getWarehouseLocationId from "@salesforce/apex/WarehouseController.getWarehouseLocationId";
import getLocationProductItmes from "@salesforce/apex/LocationController.getLocationProductItmes";
import NewRecordModal from "c/newRecordModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ID from "@salesforce/user/Id";
import PRODUCT_ITEM_OBJECT from "@salesforce/schema/ProductItem";
import PRODUCT_NAME_FIELD from "@salesforce/schema/ProductItem.Product2Id";
import QUANTITY_ON_HAND_FIELD from "@salesforce/schema/ProductItem.QuantityOnHand";
import QUANTITY_UNIT_OF_MEASURE_FIELD from "@salesforce/schema/ProductItem.QuantityUnitOfMeasure.";
import SERIAL_NUMBER_FIELD from "@salesforce/schema/ProductItem.SerialNumber";

const FIELDS = [
  PRODUCT_NAME_FIELD,
  SERIAL_NUMBER_FIELD,
  QUANTITY_ON_HAND_FIELD,
  QUANTITY_UNIT_OF_MEASURE_FIELD
];

/** @type {DatatableColumn[]} */
const COLUMNS = [
  {
    label: "Product Item Number",
    fieldName: "productItemUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "productItemNumber" } },
    target: "_blank",
    sortable: true
  },
  {
    label: "Product Name",
    fieldName: "productUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "productName" } },
    target: "_blank",
    sortable: true
  },
  {
    label: "Quantity on site",
    type: "text",
    fieldName: "productItemQuantity",
    sortable: true
  }
];

export default class ProductItemsOnWarehouse extends LightningElement {
  columns = COLUMNS;
  fields = FIELDS;
  objectApiName = PRODUCT_ITEM_OBJECT;
  /** @type {ProductItemDTO[]} */
  _data = [];
  /** @type {ProductItemDTO[]} */
  filteredData = [];
  userId = ID;
  warehouseId = "";
  locationId = "";
  searchString = "";
  defaultSortDirection = "asc";
  sortDirection = "asc";
  sortedBy = "";

  @wire(getUserAssociatedWarehouse, { userId: "$userId" })
  wiredWarehouse({ error, data }) {
    if (data) {
      this.warehouseId = data;
      this.error = undefined;
    } else if (error) {
      this.warehouseId = "";
      this.erorr = error;
    }
  }

  @wire(getWarehouseLocationId, { warehouseId: "$warehouseId" })
  wiredWarehouseLocation({ error, data }) {
    if (data) {
      this.locationId = data;
      this.error = undefined;
    } else if (error) {
      this.locationId = "";
      this.erorr = error;
    }
  }

  @wire(getLocationProductItmes, { locationId: "$locationId" })
  wiredLocationProductItems({ error, data }) {
    if (data) {
      this.data = data;
      this.error = undefined;
    } else if (error) {
      this.data = [];
      this.erorr = error;
    }
  }

  /** @param {ProductItemDTO[]} value */
  set data(value) {
    this._data = value;
    this.filteredData = this._data;
  }

  get data() {
    return this.filteredData;
  }

  get areProductItems() {
    return this._data.length > 0;
  }

  handleSort(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortDirection);
  }

  handleSearch(event) {
    this.searchString = event.detail.value.toLowerCase();
    this.filteredData = this._data.filter((record) => {
      const { productName } = record;
      const regex = new RegExp(this.searchString);
      return regex.test(productName);
    });
  }

  handleViewAll() {
    console.log("view all pressed");
  }

  async handleAddProductItem() {
    const result = await NewRecordModal.open({
      size: "small",
      objectName: "Product Item",
      objectApiName: this.objectApiName,
      fields: this.fields,
      props: this.props
    });

    if (result) {
      const event = new ShowToastEvent({
        title: "Successfully created a record",
        message: "Record ID: " + result,
        variant: "success"
      });
      this.dispatchEvent(event);
    }
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
    this.filteredData = parsedData;
  }
}
