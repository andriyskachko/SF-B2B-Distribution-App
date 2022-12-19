public without sharing class UserController {
  public static final String REGIONAL_MANAGER_ROLE = 'Regional Manager';
  public static final String SALES_MANAGER_ROLE = 'Sales Manager';

  @AuraEnabled(cacheable=true)
  public static Id getUserAssociatedWarehouse(String userId) {
    Id territory2Id = UserController.getUserAssociatedTerritory(userId);

    List<WarehouseTerritory2Association__c> lstWarehouseTerritory2Association = [
      SELECT Warehouse__c
      FROM WarehouseTerritory2Association__c
      WHERE Territory__r.Territory2Id__c = :territory2Id
    ];

    if (lstWarehouseTerritory2Association.size() > 0) {
      Id warehouseId = lstWarehouseTerritory2Association[0].Warehouse__c;
      return warehouseId;
    }

    return null;
  }

  @AuraEnabled(cacheable=true)
  public static Id getUserAssociatedTerritoryRegionalManager(String userId) {
    Id territory2Id = UserController.getUserAssociatedTerritory(userId);

    List<UserTerritory2Association> lstUserTerritory2Association = [
      SELECT UserId
      FROM UserTerritory2Association
      WHERE
        RoleInTerritory2 = :UserController.REGIONAL_MANAGER_ROLE
        AND Territory2Id = :territory2Id
    ];

    if (lstUserTerritory2Association.size() > 0) {
      return lstUserTerritory2Association[0].UserId;
    }

    return null;
  }

  public static Id getUserAssociatedTerritory(String userId) {
    List<UserTerritory2Association> lstUserTerritory2Association = [
      SELECT Territory2Id
      FROM UserTerritory2Association
      WHERE UserId = :userId
    ];

    if (lstUserTerritory2Association.size() > 0) {
      return lstUserTerritory2Association[0].Territory2Id;
    }

    return null;
  }

  @AuraEnabled(cacheable=true)
  public static List<UserDTO> getSalesManagersInUsersTerritory(String userId) {
    Id territory2Id = UserController.getUserAssociatedTerritory(userId);

    List<UserDTO> salesManagersInTerritory = Territory2Controller.getUsersInTerritoryByRole(
      territory2Id,
      UserController.SALES_MANAGER_ROLE
    );

    return salesManagersInTerritory;
  }
}
