public with sharing class LocationController {
  @AuraEnabled(cacheable=true)
  public static List<ProductItemDTO> getLocationProductItmes(
    String locationId
  ) {
    Schema.Location location = [
      SELECT
        (
          SELECT
            Id,
            Product2.Id,
            Product2.Name,
            ProductItemNumber,
            QuantityOnHand,
            SerialNumber
          FROM ProductItems
        )
      FROM Location
      WHERE Id = :locationId
      WITH SECURITY_ENFORCED
      LIMIT 5000
    ];

    if (location.PrudctItems.isEmpty()) {
      return null;
    }

    List<ProductItemDTO> lstProductItemDTO = new List<ProductItemDTO>();

    for (ProductItem p : location.ProductItems) {
      ProductItemDTO productItem = new ProductItemDTO();

      productItem.productId = p.Product2.Id;
      productItem.productItemId = p.Id;
      productItem.productItemNumber = p.ProductItemNumber;
      productItem.productItemQuantity = p.QuantityOnHand;
      productItem.productItemSerialNumber = p.SerialNumber;
      productItem.productName = p.Product2.Name;
      productItem.productUrl = Utils.getObjectURL(p.Product2.Id);
      productItem.productItemUrl = Utils.getObjectURL(p.Id);

      lstProductItemDTO.add(productItem);
    }

    return lstProductItemDTO;
  }
}
