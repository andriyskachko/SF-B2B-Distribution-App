public with sharing class NotificationReminder {
  // FIGURE OUT HOW TO ADD DYNAMIC 1 MONTH AGO AND 3 WEEKS AGO
  // VALUES
  private static final String DEVELOPER_NAME = 'Contact_Account_Reminder_Notification';

  private static void sendAccountReminderToSalesManager(
    Account acct,
    Id customNotificationId
  ) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('Account Reminder');
    notification.setBody(
      'Account ' + acct.Name + ' has not been contacted in 3 weeks!'
    );
    notification.setNotificationTypeId(customNotificationId);
    notification.setTargetId(acct.Id);
    notification.setSenderId(acct.Sales_Manager__c);
    notification.send(new Set<String>{ acct.Sales_Manager__c });
  }

  public static void sendAccountReminderToSalesManagers() {
    Id customNotificationId = Utils.getCustomNotificationByDeveloperName(
      NotificationReminder.DEVELOPER_NAME
    );

    List<Account> lstAccount = [
      SELECT Id, Name, Sales_Manager__c, LastActivityDate
      FROM Account
      WHERE Sales_Manager__c != NULL // ADD VALIDATION BY LAST ACTIVITY DATE
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Account a : lstAccount) {
      NotificationReminder.sendAccountReminderToSalesManagers(
        a,
        customNotificationId
      );
    }
  }
}
