public with sharing class ProductItemHandler {
  public static void sendNotificationToRegionalManagerIfProductLowInStock(
    List<ProductItem> lstTriggerProductItem
  ) {
    List<Warehouse_Limit__mdt> lstWarhouseLimit = [
      SELECT Run_Out_Limit__ce
      FROM Warehouse_Limit__mdt
      WITH SECURITY_ENFORCED
    ];

    if (lstWarehouseLimit.size() == 0) {
      return;
    }

    Decimal runOutLimit = lstWarehouseLimit.Run_Out_Limit__c;

    if (runOutLimit == null) {
      return;
    }

    List<ProductItem> lstProductItem = [
      SELECT Id, LocationId
      FROM ProductItem
      WHERE QuantityOnHand <= :runOutLimit AND Id IN :lstTriggerProductItem
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    if (lstProductItem.size() == 0) {
      return;
    }

    Map<Id, Set<String>> locationRegionalManagersMap = LocationController.getLocationRegionalManagers();

    for (ProductItem p : lstProductItem) {
      Set<String> regionalManagersIds = locationRegionalManagersMap.get(
        p.LocationId
      );
      if (regionalManagersIds.size() == 0) {
        continue;
      }

      sendWarehouseRunsOutOnProductNotification(p, regionalManagersIds);
    }
  }

  private static void sendWarehouseRunsOutOnProductNotification(
    ProductItem productItem,
    Set<String> recipientIds
  ) {
    Id customNotificationId = CustomNotificationController.getCustomNotificationByDeveloperName(
      CustomNotificationController.WAREHOUSE_RUNNING_OUT
    );

    if (customNotificationId == null) {
      return;
    }

    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('A Product is running out in Warehouse');
    notification.setBody(
      productItem.Product2.Name +
        ' is running out on ' +
        productItem.Location.Name
    );
    notification.setNotificationTypeId(customNotificationId);
    notification.setTargetId(productItem.LocationId);
    notification.setSenderId(productItem.Location.OwnerId);
    notification.send(recipientIds);
  }
}
