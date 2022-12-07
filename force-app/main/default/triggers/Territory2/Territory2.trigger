trigger Territory2 on Territory2(after insert) {
  Territory2Handler.createTerritoryCustomObjects(Trigger.new);
}
