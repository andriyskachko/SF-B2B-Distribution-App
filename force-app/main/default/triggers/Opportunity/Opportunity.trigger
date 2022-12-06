trigger Opportunity on Opportunity(after insert) {
  OpportunityHandler.sendNotificationsToSalesManagers(Trigger.new);
}
