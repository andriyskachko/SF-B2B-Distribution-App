public with sharing class Utils {
  public static String getObjectURL(String id) {
    return URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
  }

  public static Map<String, Id> getDeveloperNameToCustomNotificationMap() {
    Map<String, Id> mapCustomNotificationTypes = new Map<String, Id>();
    List<CustomNotificationType> lstCustomNotificationType = [
      SELECT Id, DeveloperName
      FROM CustomNotificationType
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (CustomNotificationType n : lstCustomNotificationType) {
      mapCustomNotificationTypes.put(n.DeveloperName, n.Id);
    }

    return mapCustomNotificationTypes;
  }

  public static Map<Id, Set<String>> getRegionToUsersMapByRole(String role) {
    Map<Id, Set<String>> mapRegionUsers = new Map<Id, Set<String>>();

    List<UserTerritory2Association> lstUserAssociation = [
      SELECT UserID, Territory2.Name
      FROM UserTerritory2Association
      WHERE RoleInTerritory2 = :role
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    List<Region__c> lstRegion = [
      SELECT Id, Name
      FROM Region__c
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Region__c r : lstRegion) {
      String regionName = r.Name;
      Set<String> setUserId = new Set<String>();
      for (UserTerritory2Association u : lstUserAssociation) {
        if (u.Territory2.Name == regionName) {
          setUserId.add(u.UserID);
        }
      }
      mapRegionUsers.put(r.Id, setUserId);
    }

    return mapRegionUsers;
  }

  public static Map<Id, Id> getLocationToWarehouseMap() {
    Map<Id, Id> mapLocationWarehouse = new Map<Id, Id>();

    List<Schema.Location> lstLocation = [
      SELECT Id, (SELECT Id FROM Warehouses__r)
      FROM Location
      WITH SECURITY_ENFORCED
    ];

    for (Schema.Location l : lstLocation) {
      mapLocationWarehouse.put(l.Id, l.Warehouses__r[0].Id);
    }

    return mapLocationWarehouse;
  }

  public static Id getCustomNotificationByDeveloperName(String developerName) {
    Map<String, Id> developerNameToCustomNotificationMap = Utils.getDeveloperNameToCustomNotificationMap();

    Id customNotificationId = developerNameToCustomNotificationMap.get(
      developerName
    );

    return customNotificationId;
  }
}
