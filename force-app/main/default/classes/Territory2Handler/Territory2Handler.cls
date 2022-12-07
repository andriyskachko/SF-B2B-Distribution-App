public with sharing class Territory2Handler {
  public static void createTerritoryCustomObjects(
    List<Territory2> lstTriggerTerritory2
  ) {
    List<Territory__c> lstCustomTerritoryObjToInsert = new List<Territory__c>();

    List<Territory2> lstTerritory2 = [
      SELECT
        Id,
        Name,
        Territory2Type.MasterLabel,
        (SELECT Id FROM UserTerritory2Associations)
      FROM Territory2
      WHERE Id IN :lstTriggerTerritory2
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Territory2 t : lstTerritory2) {
      Territory__c territory = new Territory__c();
      territory.Name = t.Name;
      territory.Label__c = t.Territory2Type.MasterLabel;
      territory.Territory2Id__c = t.Id;
      lstCustomTerritoryObjToInsert.add(territory);
    }

    insert lstCustomTerritoryObjToInsert;
  }
}
