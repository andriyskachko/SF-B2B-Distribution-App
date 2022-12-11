public with sharing class NotificationReminder {
  private static final String DEVELOPER_NAME = 'Contact_Account_Reminder_Notification';

  private static void sendAccountReminderToSalesManager(
    Account acct,
    Id customNotificationId
  ) {
    Set<String> recipientIds = new Set<String>();
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('Account Reminder');
    notification.setBody(
      'Account ' + acct.Name + ' has not been contacted in 3 weeks!'
    );
    notification.setNotificationTypeId(customNotificationId);
    notification.setTargetId(acct.Id);
    notification.setSenderId(acct.Assigned_Sales_Manager__c);
    recipientIds.add(acct.Assigned_Sales_Manager__c);
    notification.send(recipientIds);
  }

  private static void sendAccountReminderToRegionalManager(
    Account acct,
    Id customNotificationId,
    Set<String> regionalManagerIds
  ) {
    Set<String> recipientIds = new Set<String>();
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('Account Reminder');
    notification.setBody(
      'Account ' + acct.Name + ' has not been contacted in 3 weeks!'
    );
    notification.setNotificationTypeId(customNotificationId);
    notification.setTargetId(acct.Id);
    notification.setSenderId(acct.Assigned_Sales_Manager__c);
    recipientIds.add(acct.Assigned_Sales_Manager__c);
    notification.send(recipientIds);
  }

  public static void sendAccountReminderToSalesManagers() {
    Id customNotificationId = CustomNotificationController.getCustomNotificationByDeveloperName(
      NotificationReminder.DEVELOPER_NAME
    );

    List<Account> lstAccount = [
      SELECT Id, Name, Assigned_Sales_Manager__c, LastActivityDate
      FROM Account
      WHERE
        Assigned_Sales_Manager__c != NULL
        AND LastActivityDate = N_WEEKS_AGO:3
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Account a : lstAccount) {
      NotificationReminder.sendAccountReminderToSalesManager(
        a,
        customNotificationId
      );
    }
  }

  public static void sendAccountReminderToRegionalManagers() {
    Id customNotificationId = CustomNotificationController.getCustomNotificationByDeveloperName(
      DEVELOPER_NAME
    );

    List<Account> lstAccount = [
      SELECT Id, Name, Assigned_Sales_Manager__c, LastActivityDate
      FROM Account
      WHERE
        Assigned_Sales_Manager__c != NULL
        AND LastActivityDate = N_MONTHS_AGO:1
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    Map<Id, Set<String>> regionToUsersMap = Utils.getRegionToUsersMapByRole(
      UserController.REGIONAL_MANAGER_ROLE
    );

    for (Account a : lstAccount) {
      Id regionId = a.Region__c;
      Set<String> regionalManagerIds = regionToUsersMap.get(regionId);
      NotificationReminder.sendAccountReminderToRegionalManager(
        a,
        customNotificationId,
        regionalManagerIds
      );
    }
  }
}
