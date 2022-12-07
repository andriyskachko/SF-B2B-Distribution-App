import { LightningElement, wire } from "lwc";
import getFulfillmentRequestsForUserAssociatedWarehouse from "@salesforce/apex/FulfillmentRequestController.getFulfillmentRequestsForUserAssociatedWarehouse";
import getUserAssociatedTerritoryRegionalManager from "@salesforce/apex/UserController.getUserAssociatedTerritoryRegionalManager";
import getUserAssociatedWarehouse from "@salesforce/apex/UserController.getUserAssociatedWarehouse";
import getWarehouseLocationId from "@salesforce/apex/WarehouseController.getWarehouseLocationId";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import NewRecordModal from "c/newRecordModal";

import USER_ID from "@salesforce/user/Id";
import FULFILLMENT_REQUEST_OBJECT from "@salesforce/schema/Fulfillment_Request__c";
import NAME_FIELD from "@salesforce/schema/Fulfillment_Request__c.Name";
import DESCRIPTION_FIELD from "@salesforce/schema/Fulfillment_Request__c.Description__c";
import ASSIGNED_TO_FIELD from "@salesforce/schema/Fulfillment_Request__c.Assigned_To__c";
import DUE_DATE_FIELD from "@salesforce/schema/Fulfillment_Request__c.Due_Date__c";
import PRODUCT_ITEM_FIELD from "@salesforce/schema/Fulfillment_Request__c.Product_Item__c";
import LOCATION_FIELD from "@salesforce/schema/Fulfillment_Request__c.LocationId__c";

import QUANTITY_REQUESTED_FIELD from "@salesforce/schema/Fulfillment_Request__c.Quantity_Requested__c";

const FULLFILMENT_REQUEST_MOODAL_FIELDS = [
  NAME_FIELD,
  DESCRIPTION_FIELD,
  PRODUCT_ITEM_FIELD,
  QUANTITY_REQUESTED_FIELD,
  DUE_DATE_FIELD
];

const RECORD_PAGE_FIELDS = [
  ASSIGNED_TO_FIELD,
  PRODUCT_ITEM_FIELD,
  QUANTITY_REQUESTED_FIELD,
  DUE_DATE_FIELD
];

export default class WarehouseFulfillmentRequests extends LightningElement {
  fulfillmentRequestModalFields = FULLFILMENT_REQUEST_MOODAL_FIELDS;
  recordPageFields = RECORD_PAGE_FIELDS;
  objectApiName = FULFILLMENT_REQUEST_OBJECT;
  subscriptions = [];
  requests = [];
  error;
  userId = USER_ID;
  regionalManagerId = "";
  warehouseId = "";
  locationId = "";

  @wire(getUserAssociatedTerritoryRegionalManager, { userId: "$userId" })
  wiredRegionalManager({ error, data }) {
    if (data) {
      this.regionalManagerId = data;
      this.error = undefined;
    } else if (error) {
      this.regionalManagerId = "";
      this.error = error;
    }
  }

  @wire(getUserAssociatedWarehouse, { userId: "$userId" })
  wiredWarehouse({ error, data }) {
    if (data) {
      this.warehouseId = data;
      this.error = undefined;
      console.log(this.warehouseId);
    } else if (error) {
      this.warehouseId = "";
      this.erorr = error;
      console.log(this.error);
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

  @wire(getFulfillmentRequestsForUserAssociatedWarehouse, {
    userId: "$userId"
  })
  wiredRequests({ error, data }) {
    if (data) {
      this.requests = data;
      this.error = undefined;
    } else if (error) {
      this.requests = [];
      this.erorr = error;
    }
  }

  handleViewAll() {
    // TODO: Redirect to List View
    console.log("handled view all");
  }

  async handleAddFullfilmentRequest() {
    const result = await NewRecordModal.open({
      size: "small",
      objectName: "Fulfilment Request",
      objectApiName: this.objectApiName,
      fields: this.fulfillmentRequestModalFields,
      props: this.propsForModalComponent
    });

    if (result) {
      const evt = new ShowToastEvent({
        title: "Successfully created a record",
        message: "Record ID: " + result,
        variant: "success"
      });
      this.dispatchEvent(evt);
    }
  }

  /** @type {ModalProp[]} */
  get propsForModalComponent() {
    return [
      {
        fieldName: ASSIGNED_TO_FIELD.fieldApiName,
        value: this.regionalManagerId
      },
      { fieldName: LOCATION_FIELD.fieldApiName, value: this.locationId }
    ];
  }

  get latestFulfilmentRequest() {
    return this.requests[0];
  }

  get requestsCount() {
    return this.requests.length;
  }
}
