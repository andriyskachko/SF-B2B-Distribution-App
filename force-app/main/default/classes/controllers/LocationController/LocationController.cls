public with sharing class LocationController {
  @AuraEnabled(cacheable=true)
  public static List<ProductItemDTO> getLocationProductItmes(
    String locationId
  ) {
    Schema.Location location = [
      SELECT
        (
          SELECT
            Id,
            Product2.Id,
            Product2.Name,
            ProductItemNumber,
            QuantityOnHand,
            SerialNumber
          FROM ProductItems
        )
      FROM Location
      WHERE Id = :locationId
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    if (location.ProductItems.isEmpty()) {
      return null;
    }

    List<ProductItemDTO> lstProductItemDTO = new List<ProductItemDTO>();

    for (ProductItem p : location.ProductItems) {
      ProductItemDTO productItem = new ProductItemDTO();

      productItem.productId = p.Product2.Id;
      productItem.productItemId = p.Id;
      productItem.productItemNumber = p.ProductItemNumber;
      productItem.productItemQuantity = p.QuantityOnHand;
      productItem.productItemSerialNumber = p.SerialNumber;
      productItem.productName = p.Product2.Name;
      productItem.productUrl = Utils.getObjectURL(p.Product2.Id);
      productItem.productItemUrl = Utils.getObjectURL(p.Id);

      lstProductItemDTO.add(productItem);
    }

    return lstProductItemDTO;
  }

  public static Map<Id, Set<String>> getLocationRegionalManagers() {
    Map<Id, Id> territory2LocationMap = new Map<Id, Id>();

    for (WarehouseTerritory2Association__c wta : [
      SELECT Warehouse__r.LocationId__c, Territory__r.Territory2Id__c
      FROM WarehouseTerritory2Association__c
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ]) {
      territory2LocationMap.put(
        wta.Territory__r.Territory2Id__c,
        wta.Warehouse__r.LocationId__c
      );
    }

    Map<Id, Set<String>> territory2RegionalManagerMap = new Map<Id, Set<String>>();

    for (UserTerritory2Association uta : [
      SELECT UserId, Territory2Id
      FROM UserTerritory2Association
      WHERE roleInTerritory2 = :UserController.REGIONAL_MANAGER_ROLE
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ]) {
      Set<String> existingRegionalManagers = territory2RegionalManagerMap.get(
        uta.Territory2Id
      );
      if (existingRegionalManagers == null) {
        Set<String> regionalManagers = new Set<String>{ uta.UserId };
        territory2RegionalManagerMap.put(uta.Territory2Id, regionalManagers);
      } else {
        existingRegionalManagers.add(uta.UserId);
      }
    }

    Map<Id, Set<String>> locationRegionalManagerMap = new Map<Id, Set<String>>();

    for (Id key : territory2LocationMap.keySet()) {
      Id locationId = territory2LocationMap.get(key);
      Set<String> userIds = territory2RegionalManagerMap.get(key);
      locationRegionalManagerMap.put(locationId, userIds);
    }

    return locationRegionalManagerMap;
  }
}
