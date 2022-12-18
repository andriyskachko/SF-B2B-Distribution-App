public with sharing class OpportunityController {
  private class OpportunityOrder {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public Double quantity { get; set; }
    @AuraEnabled
    public Double listPrice { get; set; }
  }

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

  @AuraEnabled(cacheable=true)
  public static List<OpportunityOrderDTO> getAccountOpportunityOrders(
    String accountId
  ) {
    try {
      List<OpportunityOrderDTO> lstOpportunityOrder = new List<OpportunityOrderDTO>();

      List<Opportunity> lstOpp = [
        SELECT
          Amount,
          CloseDate,
          StageName,
          (SELECT Product2.Name, ListPrice, Quantity FROM OpportunityLineItems)
        FROM Opportunity
        WHERE AccountId = :accountId
        WITH SECURITY_ENFORCED
      ];

      for (Opportunity o : lstOpp) {
        OpportunityOrderDTO oppOrder = new OpportunityOrderDTO();
        oppOrder.name = 'Order from ' + o.CloseDate;
        if (o.StageName == 'Closed Won') {
          oppOrder.status = 'Closed';
        } else if (o.StageName == 'Closed Lost') {
          oppOrder.status = 'Cancelled';
        } else {
          oppOrder.status = 'In Progress';
        }
        oppOrder.orderSummary = o.Amount;
        oppOrder.children = new List<OpportunityOrderDTO.OrderProduct>();
        for (OpportunityLineItem olt : o.OpportunityLineItems) {
          OpportunityOrderDTO.OrderProduct orderProduct = new OpportunityOrderDTO.OrderProduct();
          orderProduct.name = olt.Product2.Name;
          orderProduct.quantity = olt.Quantity;
          orderProduct.orderSummary = olt.Quantity * olt.ListPrice;
          oppOrder.children.add(orderProduct);
        }

        lstOpportunityOrder.add(oppOrder);
      }

      return lstOpportunityOrder;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Opportunity createNewOpportunityForAccount(
    String accountId,
    List<OpportunityOrder> lstOppOrder
  ) {
    System.debug(lstOppOrder);
    try {
      Opportunity opp = new Opportunity();
      opp.AccountId = accountId;
      opp.StageName = 'Prospecting';
      opp.Name = 'Opportunity from ' + Date.today();
      opp.CloseDate = Date.today() + 10;

      insert opp;

      List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();

      for (OpportunityOrder o : lstOppOrder) {
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.Quantity = o.quantity;
        oppLineItem.Product2Id = o.id;
        oppLineItem.TotalPrice = o.quantity * o.listPrice;
        lstOppLineItem.add(oppLineItem);
      }

      insert lstOppLineItem;

      return opp;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
