public with sharing class FulfillmentRequestHandler {
  private static final String DEVELOPER_NAME = 'Fulfillment_Requested';
  private static final String REGIONAL_MANAGER_ROLE = 'Regional Manager';
  private static final String SALES_MANAGER_ROLE = 'Sales Manager';

  public static void sendFulfillmentRequestedNotificationToRegionalManagers(
    List<Fulfillment_Request__c> lstFulfillmentRequest
  ) {
    Id customNotificationId = FulfillmentRequestHandler.getCustomNotificationByDeveloperName(
      FulfillmentRequestHandler.DEVELOPER_NAME
    );

    if (customNotificationId == null) {
      return;
    }

    Map<Id, Set<String>> regionToUsersMap = Utils.getRegionToUsersMapByRole(
      FulfillmentRequestHandler.REGIONAL_MANAGER_ROLE
    );

    Map<Id, Id> locationToWarehouseMap = Utils.getLocationToWarehouseMap();

    for (Fulfillment_Request__c f : lstFulfillmentRequest) {
      Id regionId = locationToWarehouseMap.get(f.LocationId__c);
      Set<String> recipientIds = regionToUsersMap.get(regionId);

      if (regionId == null || recipientIds.size() == 0) {
        continue;
      }

      Messaging.CustomNotification notification = new Messaging.CustomNotification();
      notification.setTitle('New Fulfillment Request');
      notification.setBody(
        'New Fulfilment Request on ' + f.LocationId__r.Name + ' was requested'
      );
      notification.setNotificationTypeId(customNotificationId);
      notification.setTargetId(f.Id);
      notification.setSenderId(f.OwnerId);
      notification.send(recipientIds);
    }
  }

  private static Id getCustomNotificationByDeveloperName(String developerName) {
    Map<String, Id> developerNameToCustomNotificationMap = Utils.getDeveloperNameToCustomNotificationMap();

    Id customNotificationId = developerNameToCustomNotificationMap.get(
      FulfillmentRequestHandler.DEVELOPER_NAME
    );

    return customNotificationId;
  }
}
