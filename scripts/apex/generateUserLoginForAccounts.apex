List<String> lstAccountIds = new List<String>{
  '0011x00001is5xuAAA',
  '0011x00001is6D8AAI'
};
List<Account_User_Login__c> lstAccountUserLogin = new List<Account_User_Login__c>();
for (String id : lstAccountIds) {
  User_Login__c userLogin = new User_Login__c();
  userLogin.Login__c = 'login_' + id;
  userLogin.Password__c = 'id';
  insert userLogin;
  Account_User_Login__c acctUserLogin = new Account_User_Login__c();
  acctUserLogin.Account__c = id;
  acctUserLogin.User_Login__c = userLogin.Id;
  insert acctUserLogin;
}
