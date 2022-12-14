public with sharing class AccountDTO {
  @AuraEnabled
  public string id;
  @AuraEnabled
  public string name;
  @AuraEnabled
  public string url;
  @AuraEnabled
  public Datetime lastActivityDate;
}