global class OppTerrAssignDefaultLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter {
  global OppTerrAssignDefaultLogicFilter() {
  }

  global Map<Id, Id> getOpportunityTerritory2Assignments(
    List<Id> opportunityIds
  ) {
    Map<Id, Id> oppIdTerritoryIdResult = new Map<Id, Id>();

    Id activeModelId = getActiveModelId();

    if (activeModelId == null) {
      return null;
    }

    List<Opportunity> opportunities = [
      SELECT Id, AccountId, Territory2Id
      FROM Opportunity
      WHERE Id IN :opportunityIds
      WITH SECURITY_ENFORCED
    ];

    Set<Id> accountIds = new Set<Id>();

    for (Opportunity opp : opportunities) {
      if (opp.AccountId != null) {
        accountIds.add(opp.AccountId);
      }
    }

    Map<Id, Id> accountTerritory2Id = getAccountTerritory2Id(
      activeModelId,
      accountIds
    );

    for (Opportunity opp : opportunities) {
      Id accountId = opp.AccountId;
      Id territory2Id = accountTerritory2Id.get(accountId);
      oppIdTerritoryIdResult.put(opp.Id, territory2Id);
    }

    return oppIdTerritoryIdResult;
  }

  private Map<Id, Id> getAccountTerritory2Id(
    Id activeModelId,
    Set<Id> accountIds
  ) {
    Map<Id, Id> accountTerritory2Id = new Map<Id, Id>();

    for (ObjectTerritory2Association ota : [
      SELECT ObjectId, Territory2Id, Territory2.Territory2Type.Priority
      FROM ObjectTerritory2Association
      WHERE
        ObjectId IN :accountIds
        AND Territory2.Territory2ModelId = :activeModelId
      WITH SECURITY_ENFORCED
    ]) {
      accountTerritory2Id.put(ota.ObjectId, ota.Territory2Id);
    }

    return accountTerritory2Id;
  }

  private Id getActiveModelId() {
    List<Territory2Model> models = [
      SELECT Id
      FROM Territory2Model
      WHERE State = 'Active'
      WITH SECURITY_ENFORCED
    ];
    Id activeModelId = null;
    if (models.size() == 1) {
      activeModelId = models.get(0).Id;
    }

    return activeModelId;
  }
}
