public without sharing class SiteAuthController {
  private class UserNotFoundException extends Exception {
  }

  private class TokenHasExpiredException extends Exception {
  }

  private class InvalidTokenException extends Exception {
  }

  private static final String DEFAULT_TOKEN = 'hello world';

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
      Datetime expirationDate = generateExpirationDate();

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
  public static String authenticate(String token) {
    try {
      List<Account_User_Login__c> lstAccountUserLogin = [
        SELECT
          Account__c,
          User_Login__r.Password__c,
          User_Login__r.Login__c,
          User_Login__r.Custom_Auth__r.Token__c,
          User_Login__r.Custom_Auth__r.Expires_At__c
        FROM Account_User_Login__c
        WHERE User_Login__r.Custom_Auth__r.Token__c = :token
        WITH SECURITY_ENFORCED
      ];

      if (lstAccountUserLogin.size() == 0) {
        throw new InvalidTokenException('Token is invalid!');
      }

      Account_User_Login__c acctUserLogin = lstAccountUserLogin[0];

      if (
        acctUserLogin.User_Login__r.Custom_Auth__r.Expires_At__c >=
        Datetime.now()
      ) {
        throw new TokenHasExpiredException('Token has expired!');
      }

      return acctUserLogin.Account__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String generateSessionToken() {
    return DEFAULT_TOKEN;
  }

  private static Datetime generateExpirationDate() {
    return Datetime.now();
  }
}
