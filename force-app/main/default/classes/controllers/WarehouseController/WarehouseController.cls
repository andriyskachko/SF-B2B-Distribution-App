public with sharing class WarehouseController {
  private class WarehouseHasNoProductException extends Exception {
  }

  private class NoWarehouseAssignedToAccountException extends Exception {
  }

  @AuraEnabled(cacheable=true)
  public static Id getWarehouseLocationId(String warehouseId) {
    List<Warehouse__c> warehouses = [
      SELECT LocationId__c
      FROM Warehouse__c
      WHERE Id = :warehouseId
      WITH SECURITY_ENFORCED
    ];

    if (warehouses.size() > 0) {
      Id locationId = warehouses[0].LocationId__c;
      return locationId;
    }

    return null;
  }

  private static Id getWarehouseOnTerritory(Id territory2Id) {
    List<WarehouseTerritory2Association__c> lstWarehouseTerritory2Association = [
      SELECT Warehouse__c
      FROM WarehouseTerritory2Association__c
      WHERE Territory__r.Territory2Id__c = :territory2Id
      WITH SECURITY_ENFORCED
    ];

    if (lstWarehouseTerritory2Association.size() == 0) {
      return null;
    }

    Id warehouseId = lstWarehouseTerritory2Association[0].Warehouse__c;

    return warehouseId;
  }

  private static Id getWarehouseLocationIdByTerritory(Id territory2Id) {
    List<WarehouseTerritory2Association__c> lstWarehouseTerritory2Association = [
      SELECT Warehouse__r.LocationId__c, Territory__r.Territory2Id__c
      FROM WarehouseTerritory2Association__c
      WHERE Territory__r.Territory2Id__c = :territory2Id
      WITH SECURITY_ENFORCED
    ];

    if (lstWarehouseTerritory2Association.size() == 0) {
      return null;
    }

    WarehouseTerritory2Association__c association = lstWarehouseTerritory2Association[0];

    return association.Warehouse__r.LocationId__c;
  }

  @AuraEnabled(cacheable=true)
  public static List<ProductEntryDTO> getProductItemsInWarehouseForAccount(
    String accountId
  ) {
    try {
      Map<Id, Id> accountTerritory2Associations = AccountController.getAccountTerritory2Associations();
      Id accountTerritory2Id = accountTerritory2Associations.get(accountId);
      Id locationId = getWarehouseLocationIdByTerritory(accountTerritory2Id);

      if (locationId == null) {
        throw new NoWarehouseAssignedToAccountException(
          'No Warehouse is assigned to the account!'
        );
      }

      List<ProductItemDTO> productsOnLocation = LocationController.getLocationProductItmes(
        locationId
      );

      if (productsOnLocation == null) {
        throw new WarehouseHasNoProductException('Warehouse has no products!');
      }

      Map<Id, Double> product2Price = Product2Controller.getProduct2PriceInStandardPricebook();

      List<ProductEntryDTO> lstProductEntries = new List<ProductEntryDTO>();

      for (ProductItemDTO pdto : productsOnLocation) {
        ProductEntryDTO productEntryDTO = new ProductEntryDTO();
        productEntryDTO.id = pdto.productId;
        productEntryDTO.listPrice = product2Price.get(pdto.productId);
        productEntryDTO.name = pdto.productName;
        lstProductEntries.add(productEntryDTO);
      }

      return lstProductEntries;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
