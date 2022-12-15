public without sharing class SiteAuthController {
  private class UserNotFoundException extends Exception {
  }

  private class TokenHasExpiredException extends Exception {
  }

  private final String defaultToken = 'hello world';

  @AuraEnabled
  public static List<String> login(String loginOrEmail, String password) {
    try {
      List<Account_User_Login__c> lstAccountUserLogin = [
        SELECT Account__c, User_Login__r.Password__c, User_Login__r.Login__c
        FROM Account_User_Login__c
        WHERE
          User_Login__r.Login__c = :loginOrEmail
          OR User_Login__r.Email__c = :loginOrEmail
        WITH SECURITY_ENFORCED
      ];

      if (
        lstAccountUserLogin.size() == 0 ||
        lstAccountUserLogin[0].User_Login__r.Password__c != password
      ) {
        throw new UserNotFoundException('Invalid credentials!');
      }

      Account_User_Login__c acctUserLogin = lstAccountUserLogin[0];

      String token = generateSessionToken();
      String expirationDate = generateExpirationDate();

      // SET TOKEN AND EXPIRATION DATE
      // TO THE ACCOUNT LOGIN CUSTOM AUTH TO LATER AUTH BY IT

      List<String> accountAndToken = new List<String>{
        acctUserLogin.Account__c,
        token
      };

      return accountAndToken;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static string authenticate(String token) {
    try {
      List<Account_User_Login__c> lstAccountUserLogin = [
        // SELECT Custom Auth Token
        SELECT Account__c, User_Login__r.Password__c, User_Login__r.Login__c
        FROM Account_User_Login__c
        WHERE Token__c = :token
        WITH SECURITY_ENFORCED
      ];

      // IF TOKEN FOUND AND IT ISN'T EXPIRED
      // RETURN AccountId
      // OTHERWISE call throw exception

      throw new TokenHasExpiredException('Token has expired!');

      return '';
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private string generateSessionToken() {
    // TODO: IMPROVE LOGIC FOR TOKEN GENERATION
    return defaultToken;
  }

  private Datetime generateExpirationDate() {
    // TODO: IMPROVE LOGIC FOR TOKEN GENERATION
    return new Datetime() + 1;
  }
}
