List<Territory2Model> models = [
  SELECT Id
  FROM Territory2Model
  WHERE State = 'Active'
  WITH SECURITY_ENFORCED
];

Id activeModelId = models.get(0).Id;

List<Opportunity> updatedOpps = new List<Opportunity>();

List<Opportunity> opportunities = [
  SELECT Id, AccountId, Territory2Id
  FROM Opportunity
];

Set<Id> accountIds = new Set<Id>();

for (Opportunity opp : opportunities) {
  if (opp.AccountId != null) {
    accountIds.add(opp.AccountId);
  }
}
Map<Id, Id> accountTerritory2Id = new Map<Id, Id>();

for (ObjectTerritory2Association ota : [
  SELECT ObjectId, Territory2Id
  FROM ObjectTerritory2Association
  WHERE
    ObjectId IN :accountIds
    AND Territory2.Territory2ModelId = :activeModelId
]) {
  accountTerritory2Id.put(ota.ObjectId, ota.Territory2Id);
}

for (Opportunity opp : opportunities) {
  Id accountId = opp.AccountId;
  Id territory2Id = accountTerritory2Id.get(accountId);
  opp.Territory2Id = territory2Id;
  updatedOpps.add(opp);
}

update updatedOpps;
