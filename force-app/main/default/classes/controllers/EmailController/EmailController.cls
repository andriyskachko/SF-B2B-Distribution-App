public with sharing class EmailController {
  private class NoUserWithEmailFoundException extends Exception {
  }

  @AuraEnabled
  public static Boolean sendEmail(
    String salesManagerId,
    String subject,
    String body
  ) {
    try {
      String userEmail = getUserEmail(salesManagerId);
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.toAddresses = new List<String>{ userEmail };
      message.optOutPolicy = 'FILTER';
      message.subject = subject;
      message.plainTextBody = subject;
      List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);

      if (!results[0].success) {
        throw new EmailException(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }

      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  private static String getUserEmail(String userId) {
    List<User> lstUser = [
      SELECT Email
      FROM User
      WHERE Id = :userId
      WITH SECURITY_ENFORCED
    ];
    User user = lstUser[0];
    return user.Email;
  }
}
