public with sharing class ContractHandler {
  private static final String DEVELOPER_NAME = 'Contract_Is_Created';
  private static final String REGIONAL_MANAGER_ROLE = 'Regional Manager';

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
    Id customNotificationTypeId = Utils.getCustomNotificationByDeveloperName(
      ContractHandler.DEVELOPER_NAME
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
        SourceOpportunity.Account.Region__c,
        SourceOpportunity.Amount,
        Status
      FROM Contract
      WHERE Id IN :lstTriggerContract
      WITH SECURITY_ENFORCED
    ];

    Map<Id, Set<String>> regionToUsersMap = Utils.getRegionToUsersMapByRole(
      ContractHandler.REGIONAL_MANAGER_ROLE
    );

    for (Contract c : lstContract) {
      Id regionId = c.SourceOpportunity.Account.Region__c;
      Set<String> regionalManagerIds = regionToUsersMap.get(regionId);
      ContractHandler.sendContractIsCreatedNotification(
        c,
        customNotificationTypeId,
        regionalManagerIds
      );
    }
  }
}
