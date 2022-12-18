public with sharing class Territory2Handler {
  private static List<Territory__c> createTerritoryCustomObjects(
    List<Id> lstTriggerTerritory2Id
  ) {
    List<Territory__c> lstCustomTerritoryObjToInsert = new List<Territory__c>();

    List<Territory2> lstTerritory2 = [
      SELECT
        Id,
        Name,
        Territory2Type.MasterLabel,
        (SELECT Id FROM UserTerritory2Associations)
      FROM Territory2
      WHERE Id IN :lstTriggerTerritory2Id
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    for (Territory2 t : lstTerritory2) {
      lstCustomTerritoryObjToInsert.add(
        new Territory__c(
          Name = t.name,
          Label__c = t.Territory2Type.MasterLabel,
          Territory2Id__c = t.Id
        )
      );
    }

    return lstCustomTerritoryObjToInsert;
  }

  public static List<Id> getTerritory2IdList(
    List<Territory2> lstTriggerTerritory
  ) {
    List<Id> lstTerritory2Id = new List<Id>();
    for (Territory2 t : lstTriggerTerritory) {
      lstTerritory2Id.add(t.Id);
    }
    return lstTerritory2Id;
  }

  @future
  public static void insertCustomTerritoryObjects(List<Id> lstTerritory2Id) {
    List<Territory__c> lstCustomTerritoryObjToInsert = Territory2Handler.createTerritoryCustomObjects(
      lstTerritory2Id
    );

    insert lstCustomTerritoryObjToInsert;
  }
}
