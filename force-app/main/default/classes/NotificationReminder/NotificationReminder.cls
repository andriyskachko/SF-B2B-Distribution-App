public with sharing class NotificationReminder {
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
      CustomNotificationController.CONTACT_ACCOUNT_REMINDER_NOTIFICATION
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
      CustomNotificationController.CONTACT_ACCOUNT_REMINDER_NOTIFICATION
    );

    Map<Id, Id> accountTerritory2Id = AccountController.getAccountTerritory2Associations();
    Map<Id, Set<String>> territory2ToUsersMap = Territory2Controller.getTerritory2UsersMapByRole(
      UserController.REGIONAL_MANAGER_ROLE
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

    for (Account a : lstAccount) {
      Id regionId = accountTerritory2Id.get(a.Id);
      Set<String> regionalManagerIds = territory2ToUsersMap.get(regionId);
      NotificationReminder.sendAccountReminderToRegionalManager(
        a,
        customNotificationId,
        regionalManagerIds
      );
    }
  }
}