public with sharing class WarehouseController {
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
}