public with sharing class OpportunitiesSummaryDTO {
  @AuraEnabled
  public String accountId;
  @AuraEnabled
  public String accountName;
  @AuraEnabled
  public String accountUrl;
  @AuraEnabled
  public Integer totalQuantity;
  @AuraEnabled
  public Integer totalAmount;
}