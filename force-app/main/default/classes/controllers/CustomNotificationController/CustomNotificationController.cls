public with sharing class CustomNotificationController {
  public static final String CONTRACT_IS_CREATED = 'Contract_Is_Created';
  public static final String FULFILLMENT_REQUESTED = 'Fulfillment_Requested';
  public static final String NEW_OPPORTUNITY = 'New_Opportunity';
  public static final String WAREHOUSE_RUNNING_OUT = 'Warehouse_Running_Out';
  public static final String CONTACT_ACCOUNT_REMINDER_NOTIFICATION = 'Contact_Account_Reminder_Notification';

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
