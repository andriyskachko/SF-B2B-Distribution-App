public with sharing class Product2Controller {
  public static Map<Id, Double> getProduct2PriceInStandardPricebook() {
    List<PriceBook2> lstStandardPriceBooks = [
      SELECT (SELECT Product2Id, UnitPrice FROM PricebookEntries)
      FROM PriceBook2
      WHERE IsStandard = TRUE
      WITH SECURITY_ENFORCED
    ];

    if (lstStandardPriceBooks.size() == 0) {
      return null;
    }

    PriceBook2 pb = lstStandardPriceBooks[0];

    Map<Id, Double> product2Price = new Map<Id, Double>();

    for (PricebookEntry pe : pb.PricebookEntries) {
      product2Price.put(pe.Product2Id, pe.UnitPrice);
    }

    return product2Price;
  }
}
