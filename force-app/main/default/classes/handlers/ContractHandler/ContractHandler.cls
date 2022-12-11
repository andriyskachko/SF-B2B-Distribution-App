public with sharing class ContractHandler {
  private static boolean isApprovalRequired(Decimal amount) {
    return amount >= 5000;
  }

  private static void sendContractIsCreatedNotification(
    Contract contract,
    Id customNotificationTypeId,
    Set<String> regionalManagerIds
  ) {
    Set<String> recipientIds = new Set<String>();
    Messaging.CustomNotification notification = new Messaging.CustomNotification();
    notification.setTitle('A Contract has been created');
    notification.setBody(
      'Contract for Opportunity ' +
        contract.SourceOpportunity.Name +
        ' has been created, please review'
    );
    notification.setNotificationTypeId(customNotificationTypeId);
    notification.setTargetId(contract.Id);
    notification.setSenderId(contract.OwnerId);

    recipientIds.add(
      contract.SourceOpportunity.Account.Assigned_Sales_Manager__c
    );

    if (ContractHandler.isApprovalRequired(contract.SourceOpportunity.Amount)) {
      recipientIds.addAll(regionalManagerIds);
    }

    notification.send(recipientIds);
  }

  public static void sendNotificationsToSalesManagers(
    List<Contract> lstTriggerContract
  ) {
    Id customNotificationTypeId = CustomNotificationController.getCustomNotificationByDeveloperName(
      CustomNotificationController.CONTRACT_IS_CREATED
    );

    if (customNotificationTypeId == null) {
      return;
    }

    List<Contract> lstContract = [
      SELECT
        Id,
        OwnerId,
        SourceOpportunity.Name,
        SourceOpportunity.Account.Assigned_Sales_Manager__c,
        SourceOpportunity.Account.Territory2Id,
        SourceOpportunity.Amount,
        Status
      FROM Contract
      WHERE Id IN :lstTriggerContract
      WITH SECURITY_ENFORCED
    ];

    Map<Id, Set<String>> territory2ToUsersMap = Territory2Controller.getTerritory2UsersMapByRole(
      UserController.REGIONAL_MANAGER_ROLE
    );

    for (Contract c : lstContract) {
      Id regionId = c.SourceOpportunity.Account.Territory2Id;
      Set<String> regionalManagerIds = territory2ToUsersMap.get(regionId);

      ContractHandler.sendContractIsCreatedNotification(
        c,
        customNotificationTypeId,
        regionalManagerIds
      );
    }
  }
}
