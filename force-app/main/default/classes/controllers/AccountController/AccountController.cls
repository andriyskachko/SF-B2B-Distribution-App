public with sharing class AccountController {
  @AuraEnabled(cacheable=true)
  public static List<AccountDTO> getAssignedAccounts(String userId) {
    List<AccountDTO> lstAssignedAccounts = new List<AccountDTO>();

    for (Account a : [
      SELECT Id, Name, LastActivityDate
      FROM Account
      WHERE Assigned_Sales_Manager__c = :userId
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ]) {
      AccountDTO acct = new AccountDTO();
      acct.Id = a.Id;
      acct.name = a.Name;
      acct.url = Utils.getObjectURL(a.id);
      acct.lastActivityDate = a.LastActivityDate;
      lstAssignedAccounts.add(acct);
    }

    return lstAssignedAccounts;
  }
}
