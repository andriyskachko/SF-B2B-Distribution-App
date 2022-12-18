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

  public static void associateStandardPriceBookWithOpportunity(
    List<Opportunity> lstTriggerOpps
  ) {
    List<PriceBook2> lstStandardPriceBooks = [
      SELECT Id
      FROM PriceBook2
      WHERE IsStandard = TRUE
      WITH SECURITY_ENFORCED
    ];

    if (lstStandardPriceBooks.size() == 0) {
      return;
    }

    Id standardPricebookId = lstStandardPriceBooks[0].Id;
    List<Opportunity> lstOpps = [
      SELECT Pricebook2Id
      FROM Opportunity
      WHERE Id IN :lstTriggerOpps
      WITH SECURITY_ENFORCED
    ];
    List<Opportunity> lstUpdatedOpps = new List<Opportunity>();

    for (Opportunity o : lstOpps) {
      o.Pricebook2Id = standardPricebookId;
      lstUpdatedOpps.add(o);
    }

    update lstUpdatedOpps;
  }
}
