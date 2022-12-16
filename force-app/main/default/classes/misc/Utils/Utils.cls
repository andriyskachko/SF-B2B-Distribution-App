public with sharing class Utils {
  public static String getObjectURL(String id) {
    return URL.getSalesforceBaseUrl().toExternalForm() + '/' + id;
  }

  public static Map<Id, Id> getLocationToWarehouseMap() {
    Map<Id, Id> mapLocationWarehouse = new Map<Id, Id>();

    List<Schema.Location> lstLocation = [
      SELECT Id, (SELECT Id FROM Warehouses__r)
      FROM Location
      WITH SECURITY_ENFORCED
    ];

    for (Schema.Location l : lstLocation) {
      mapLocationWarehouse.put(l.Id, l.Warehouses__r[0].Id);
    }

    return mapLocationWarehouse;
  }

  public static String getStringValue(Object obj) {
    if (obj == null) {
      return '';
    }
    return String.valueOf(obj);
  }

  public static Integer getIntegerValue(Object obj) {
    if (obj == null) {
      return 0;
    }
    return Integer.valueOf(Utils.getStringValue(obj));
  }
}
