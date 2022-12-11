public with sharing class OpportunityHandler {
  private static void sendNotificationToAssignedSalesManager(
    Opportunity opp,
    Id customNotificationTypeId
  ) {
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    Set<String> recipientIds = new Set<String>();
    notification.setTitle('New Opportunity');
    notification.setBody('New Opportunity from ' + opp.Account.Name);
    notification.setNotificationTypeId(customNotificationTypeId);
    notification.setTargetId(opp.Id);
    notification.setSenderId(opp.OwnerId);
    recipientIds.add(opp.Account.Assigned_Sales_Manager__c);
    notification.send(recipientIds);
  }

  public static void sendNotificationsToSalesManagers(
    List<Opportunity> lstTriggerOpportunity
  ) {
    List<Opportunity> lstOpportunity = [
      SELECT Name, Account.Assigned_Sales_Manager__c, Id, OwnerId, Account.Name
      FROM Opportunity
      WHERE Id IN :lstTriggerOpportunity
      WITH SECURITY_ENFORCED
    ];

    Id customNotificationTypeId = CustomNotificationController.getCustomNotificationByDeveloperName(
      CustomNotificationController.NEW_OPPORTUNITY
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
