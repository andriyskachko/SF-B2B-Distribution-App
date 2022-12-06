global with sharing class ScheduledNotificationReminder implements Schedulable {
  global void execute(SchedulableContext sc) {
    NotificationReminder.sendAccountReminderToSalesManagers();
  }
}
