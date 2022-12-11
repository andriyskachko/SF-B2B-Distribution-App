public with sharing class CustomNotificationController {
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

  public static Id getCustomNotificationByDeveloperName(String developerName) {
    Map<String, Id> developerNameToCustomNotificationMap = CustomNotificationController.getDeveloperNameToCustomNotificationMap();

    Id customNotificationId = developerNameToCustomNotificationMap.get(
      developerName
    );

    return customNotificationId;
  }
}
