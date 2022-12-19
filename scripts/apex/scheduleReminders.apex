ScheduledNotificationReminder reminder = new ScheduledNotificationReminder();
String sch = '0 0 10 * * ? *';
String jobID = System.schedule('Notification Reminder Job', sch, reminder);
System.debug(jobId);
