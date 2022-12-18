global class ScheduledNotificationReminder implements Schedulable {
  global void execute(SchedulableContext sc) {
    NotificationReminder.sendAccountReminderToSalesManagers();
    NotificationReminder.sendAccountReminderToRegionalManagers();
  }
}
