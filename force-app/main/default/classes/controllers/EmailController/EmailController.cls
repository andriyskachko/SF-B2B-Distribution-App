public with sharing class EmailController {
  @AuraEnabled
  public static String sendEmail(
    List<String> recipientIds,
    String topic,
    String body
  ) {
    try {
      // Add sending logic here!
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
