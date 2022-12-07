public with sharing class FulfillmentRequestController {
  @AuraEnabled(cacheable=true)
  public static List<FulfillmentRequestDTO> getFulfillmentRequestsForUserAssociatedWarehouse(
    String userId
  ) {
    Id warehouseId = UserController.getUserAssociatedWarehouse(userId);

    if (warehouseId == null) {
      return null;
    }

    Id locationId = WarehouseController.getWarehouseLocationId(warehouseId);

    if (locationId == null) {
      return null;
    }

    List<FulfillmentRequestDTO> lstFulfillmentRequestDTO = new List<FulfillmentRequestDTO>();

    for (Fulfillment_Request__c f : [
      SELECT Id
      FROM Fulfillment_Request__c
      WHERE LocationId__c = :locationId
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
    ]) {
      FulfillmentRequestDTO request = new FulfillmentRequestDTO();
      request.id = f.Id;
      lstFulfillmentRequestDTO.add(request);
    }

    return lstFulfillmentRequestDTO;
  }
}
