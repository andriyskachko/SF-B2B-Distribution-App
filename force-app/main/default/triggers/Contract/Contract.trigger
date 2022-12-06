trigger Contract on Contract(after insert) {
  ContractHandler.sendNotificationsToSalesManagers(Trigger.new);
}
