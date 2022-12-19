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
      List<User_Login__c> lstUserLogin = [
        SELECT
          Id,
          Custom_Auth__c,
          Custom_Auth__r.Token__c,
          Custom_Auth__r.Expires_At__c,
          Login__c,
          Password__c,
          (SELECT Account__c FROM Account_User_Logins__r)
        FROM User_Login__c
        WHERE
          User_Login__c.Login__c = :loginOrEmail
          OR User_Login__c.Email__c = :loginOrEmail
      ];

      if (lstUserLogin.size() == 0 || lstUserLogin[0].Password__c != password) {
        throw new UserNotFoundException('Invalid credentials!');
      }

      User_Login__c userLogin = lstUserLogin[0];

      String token = generateSessionToken();
      Datetime expirationDate = generateExpirationDate();

      if (userLogin.Custom_Auth__c == null) {
        Custom_Auth__c customAuth = new Custom_Auth__c();
        customAuth.Token__c = token;
        customAuth.Expires_At__c = expirationDate;
        insert customAuth;
        userLogin.Custom_Auth__c = customAuth.Id;
        update userLogin;
      } else {
        List<Custom_Auth__c> lstCustomAuth = [
          SELECT Id, Token__c, Expires_At__c
          FROM Custom_Auth__c
          WHERE Id = :userLogin.Custom_Auth__c
        ];

        Custom_Auth__c customAuth = lstCustomAuth[0];
        customAuth.Token__c = token;
        customAuth.Expires_At__c = expirationDate;

        update customAuth;
      }

      List<String> accountAndToken = new List<String>{
        userLogin.Account_User_Logins__r[0].Account__c,
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
      List<User_Login__c> lstUserLogin = [
        SELECT
          Id,
          Custom_Auth__c,
          Custom_Auth__r.Token__c,
          Custom_Auth__r.Expires_At__c,
          Login__c,
          Password__c,
          (SELECT Account__c FROM Account_User_Logins__r)
        FROM User_Login__c
        WHERE Custom_Auth__r.Token__c = :token
      ];

      if (lstUserLogin.size() == 0) {
        throw new InvalidTokenException('Token is invalid');
      }

      User_Login__c userLogin = lstUserLogin[0];

      if (userLogin.Custom_Auth__r.Expires_At__c <= Datetime.now()) {
        throw new TokenHasExpiredException('Token has expired!');
      }

      return userLogin.Account_User_Logins__r[0].Account__c;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String generateSessionToken() {
    return DEFAULT_TOKEN +
      String.valueOf(Integer.valueof((Math.random() * 1000)));
  }

  private static Datetime generateExpirationDate() {
    return Datetime.now().addDays(1);
  }
}
