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
      SELECT Warehouse__c.LocationId__c, Territory_r.Territory2Id__c
      FROM WarehouseTerritory2Association__c
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ]) {
      territory2LocationMap.put(
        wta.Territory_r.Territory2Id__c,
        wta.Warehouse__c.LocationId__c
      );
    }

    Map<Id, Set<Id>> territory2RegionalManagerMap = new Map<Id, Set<Id>>();

    for (UserTerritory2Association uta : [
      SELECT UserId, Territory2Id
      FROM UserTerritory2Association
      WHERE roleInTerritory2 = :UserController.REGIONAL_MANAGER_ROLE
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ]) {
      Set<Id> regionalManagers = territory2RegionalManagerMap.get(
        uta.Territory2Id
      );
      if (regionalManagers == null) {
        Set<Id> regionalManagers = new Set<Id>{ uta.UserId };
        territory2RegionalManagerMap.put(uta.Territory2Id, regionalManagers);
      } else {
        regionalManagers.add(uta.UserId);
      }
    }

    Map<Id, Set<String>> locationRegionalManagerMap = new Map<Id, Set<String>>();

    for (Id key : territory2LocationMap.keySet()) {
      Id locationId = territory2LocationMap.get(Id);
      Set<Id> userIds = territory2RegionalManagerMap.get(Id);
      locationRegionalManagerMap.put(locationId, userIds);
    }

    return locationRegionManagerMap;
  }
}
