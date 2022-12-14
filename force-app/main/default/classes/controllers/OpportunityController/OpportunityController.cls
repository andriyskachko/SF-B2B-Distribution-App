public with sharing class OpportunityController {
  @AuraEnabled(cacheable=true)
  public static List<OpportunitiesSummaryDTO> getOppsSummaryBySalesManagersAndPeriod(
    List<String> salesManagersIds,
    String periodFrame
  ) {
    List<OpportunitiesSummaryDTO> lstResults = new List<OpportunitiesSummaryDTO>();
    String query =
      'SELECT AccountId, Account.Name, SUM(TotalOpportunityQuantity) totalQuantity, SUM(Amount) totalAmount FROM Opportunity WHERE CloseDate = ' +
      periodFrame +
      ' AND Account.Assigned_Sales_Manager__c IN :salesManagersIds' +
      ' WITH SECURITY_ENFORCED' +
      ' GROUP BY AccountId, Account.Name';

    List<sObject> lstAggregateResult = Database.query(query);

    for (sObject obj : lstAggregateResult) {
      AggregateResult ar = (AggregateResult) obj;
      OpportunitiesSummaryDTO result = new OpportunitiesSummaryDTO();
      String accountId = Utils.getStringValue(ar.get('AccountId'));
      result.accountId = accountId;
      result.accountName = Utils.getStringValue(ar.get('Name'));
      result.accountUrl = Utils.getObjectURL(accountId);
      result.totalQuantity = Utils.getIntegerValue(ar.get('totalQuantity'));
      result.totalAmount = Utils.getIntegerValue(ar.get('totalAmount'));
      lstResults.add(result);
    }

    return lstResults;
  }
}