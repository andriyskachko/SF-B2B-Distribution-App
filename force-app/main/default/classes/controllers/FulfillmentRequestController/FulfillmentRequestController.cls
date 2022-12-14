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
      SELECT Id, Name
      FROM Fulfillment_Request__c
      WHERE LocationId__c = :locationId AND Status__c = 'New'
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
    ]) {
      FulfillmentRequestDTO request = new FulfillmentRequestDTO();
      request.id = f.Id;
      request.url = Utils.getObjectURL(f.Id);
      request.name = f.Name;
      lstFulfillmentRequestDTO.add(request);
    }

    return lstFulfillmentRequestDTO;
  }
}