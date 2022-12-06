public with sharing class OpportunityHandler {
  private static final String NEW_OPPORTUNITY_DEVELOPER_NAME = 'New_Opportunity';

  private static void sendNotificationToAssignedSalesManager(
    Opportunity opp,
    Id customNotificationTypeId
  ) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('New Opportunity');
    notification.setBody('New Opportunity from ' + opp.Account.Name);
    notification.setNotificationTypeId(customNotificationTypeId);
    notification.setTargetId(opp.Id);
    notification.setSenderId(opp.OwnerId);
    notification.send(new Set<String>{ opp.Account.Assigned_Sales_Manager__c });
  }

  public static void sendNotificationsToSalesManagers(
    List<Opportunity> lstOpportunity
  ) {
    Id customNotificationTypeId = Utils.getCustomNotificationByDeveloperName(
      OpportunityHandler.NEW_OPPORTUNITY_DEVELOPER_NAME
    );

    if (customNotificationTypeId == null) {
      return;
    }

    for (Opportunity o : lstOpportunity) {
      OpportunityHandler.sendNotificationToAssignedSalesManager(
        o,
        customNotificationTypeId
      );
    }
  }
}
