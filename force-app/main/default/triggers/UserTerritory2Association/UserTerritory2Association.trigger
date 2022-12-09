trigger UserTerritory2Association on UserTerritory2Association(after insert) {
  UserTerritory2AssociationHandler.notifySalesOps(Trigger.new);
}
