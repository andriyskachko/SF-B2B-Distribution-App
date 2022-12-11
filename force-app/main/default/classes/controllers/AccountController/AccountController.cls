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

  public static Map<Id, Id> getAccountTerritory2Associations() {
    Map<Id, Id> accountTerritory2Id = new Map<Id, Id>();

    List<ObjectTerritory2Association> lstObjectTerritory2Association = [
      SELECT ObjectId, Territory2Id
      FROM ObjectTerritory2Association
      WITH SECURITY_ENFORCED
    ];

    for (ObjectTerritory2Association ota : lstObjectTerritory2Association) {
      accountTerritory2Id.put(ota.ObjectId, ota.Territory2Id);
    }

    return accountTerritory2Id;
  }
}
