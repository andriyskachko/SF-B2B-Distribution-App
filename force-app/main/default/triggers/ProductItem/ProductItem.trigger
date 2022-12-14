trigger ProductItem on ProductItem(after update) {
  ProductItemHandler.sendNotificationToRegionalManagerIfProductLowInStock(
    Trigger.new
  );
}