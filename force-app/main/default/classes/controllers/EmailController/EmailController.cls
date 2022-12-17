public with sharing class EmailController {
  @AuraEnabled
  public static Boolean sendEmail(
    List<String> recipientIds,
    String subject,
    String body
  ) {
    try {
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.toAddresses = recipientIds;
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
}
