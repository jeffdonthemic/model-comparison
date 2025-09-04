/**
 * @description       : 
 * @author            : liquidlogixsolutions
 * @group             : 
 * @last modified on  : 09-03-2025
 * @last modified by  : liquidlogixsolutions
**/
trigger PurchaseOrderLineItemTrigger on PurchaseOrderLineItem__c (after insert, after update) {
    // Map to store ingredient ID and the total quantity received for that ingredient
    Map<Id, Decimal> ingredientQuantityMap = new Map<Id, Decimal>();
    
    // Get the IDs of the ingredients from the updated/inserted line items
    Set<Id> ingredientIds = new Set<Id>();
    
    for (PurchaseOrderLineItem__c lineItem : Trigger.new) {
        if (lineItem.Ingredient__c != null) {
            ingredientIds.add(lineItem.Ingredient__c);
        }
    }
    
    // If no ingredients, exit
    if (ingredientIds.isEmpty()) {
        return;
    }
    
    // Query all line items for these ingredients where QuantityReceived__c > 0
    List<PurchaseOrderLineItem__c> allLineItems = [
        SELECT Id, Ingredient__c, QuantityReceived__c
        FROM PurchaseOrderLineItem__c
        WHERE Ingredient__c IN :ingredientIds
        AND QuantityReceived__c > 0
    ];
    
    // Sum up the QuantityReceived__c for each ingredient
    for (PurchaseOrderLineItem__c lineItem : allLineItems) {
        if (ingredientQuantityMap.containsKey(lineItem.Ingredient__c)) {
            ingredientQuantityMap.put(lineItem.Ingredient__c, ingredientQuantityMap.get(lineItem.Ingredient__c) + lineItem.QuantityReceived__c);
        } else {
            ingredientQuantityMap.put(lineItem.Ingredient__c, lineItem.QuantityReceived__c);
        }
    }
    
    // Update the In_Stock__c field on the Ingredient__c records
    List<Ingredient__c> ingredientsToUpdate = new List<Ingredient__c>();
    
    for (Id ingredientId : ingredientQuantityMap.keySet()) {
        ingredientsToUpdate.add(new Ingredient__c(
            Id = ingredientId,
            In_Stock__c = ingredientQuantityMap.get(ingredientId)
        ));
    }
    
    if (!ingredientsToUpdate.isEmpty()) {
        try {
            update ingredientsToUpdate;
        } catch (DmlException e) {
            // Handle exception
            System.debug('Error updating Ingredient records: ' + e.getMessage());
        }
    }
}
