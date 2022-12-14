trigger FulfillmentRequest on Fulfillment_Request__c(after insert) {
  FulfillmentRequestHandler.sendFulfillmentRequestedNotificationToRegionalManagers(
    Trigger.new
  );

}