public with sharing class FulfillmentRequestHandler {
  public static void sendFulfillmentRequestedNotificationToRegionalManagers(
    List<Fulfillment_Request__c> lstTriggerFulfillmentRequest
  ) {
    Id customNotificationId = CustomNotificationController.getCustomNotificationByDeveloperName(
      CustomNotificationController.FULFILLMENT_REQUESTED
    );

    if (customNotificationId == null) {
      return;
    }

    List<Fulfillment_Request__c> lstFulfillmentRequest = [
      SELECT Id, OwnerId, LocationId__r.Name, Assigned_To__c
      FROM Fulfillment_Request__c
      WHERE Id IN :lstTriggerFulfillmentRequest
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Fulfillment_Request__c f : lstFulfillmentRequest) {
      Messaging.CustomNotification notification = new Messaging.CustomNotification();
      notification.setTitle('New Fulfillment Request');
      notification.setBody('New Fulfilment Request on ' + f.LocationId__r.Name);
      notification.setNotificationTypeId(customNotificationId);
      notification.setTargetId(f.Id);
      notification.setSenderId(f.OwnerId);

      Set<String> recipientIds = new Set<String>();
      recipientIds.add(f.Assigned_To__c);

      notification.send(recipientIds);
    }
  }
}
