public with sharing class OpportunityOrderDTO {
  public class OrderProduct {
    @AuraEnabled
    public string name;
    @AuraEnabled
    public Double quantity;
    @AuraEnabled
    public Double orderSummary;
  }

  @AuraEnabled
  public string name;
  @AuraEnabled
  public string status;
  @AuraEnabled
  public Double orderSummary;
  @AuraEnabled
  public List<OrderProduct> children;
}
