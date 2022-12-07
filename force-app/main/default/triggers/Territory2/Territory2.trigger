trigger Territory2 on Territory2(after insert) {
  List<Id> lstTriggerTerritory2Ids = Territory2Handler.getTerritory2IdList(
    Trigger.new
  );
  Territory2Handler.insertCustomTerritoryObjects(lstTriggerTerritory2Ids);
}
