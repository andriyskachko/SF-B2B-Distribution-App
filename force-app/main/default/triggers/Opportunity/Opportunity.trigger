trigger Opportunity on Opportunity(after insert) {
  OpportunityHandler.sendNotificationsToSalesManagers(Trigger.new);
  OpportunityHandler.associateStandardPriceBookWithOpportunity(Trigger.new);
}
