public with sharing class PurchaseOrderTriggerHandler {
    
    public static void handleBeforeInsert(List<Purchase_Order__c> newPurchaseOrders) {
        // Logic for before insert
    }
    
    public static void handleBeforeUpdate(List<Purchase_Order__c> newPurchaseOrders, Map<Id, Purchase_Order__c> oldMap) {
        // Logic for before update
        for (Purchase_Order__c newPO : newPurchaseOrders) {
            Purchase_Order__c oldPO = oldMap.get(newPO.Id);
            
            // Rule 1: When Approved__c is checked, update Status__c to "Approved"
            if (newPO.Approved__c && !oldPO.Approved__c) {
                newPO.Status__c = 'Approved';
            }
            
            // Rule 2: Can only manually change Status__c to "Submitted" if Approved__c = TRUE
            if (newPO.Status__c == 'Submitted' && !newPO.Approved__c) {
                newPO.Status__c = oldPO.Status__c; // Revert to old status
                // Optionally, add an error message
                // newPO.addError('Status cannot be changed to Submitted unless Approved is checked.');
            }
        }
    }
    
    public static void handleAfterUpdate(List<Purchase_Order__c> newPurchaseOrders, Map<Id, Purchase_Order__c> oldMap) {
        // Rule 3: When a Purchase Order is set to "Submitted", update On_Order__c for related line items
        List<Ingredient__c> ingredientsToUpdate = new List<Ingredient__c>();
        Set<Id> poIdsToProcess = new Set<Id>();
        
        for (Purchase_Order__c newPO : newPurchaseOrders) {
            Purchase_Order__c oldPO = oldMap.get(newPO.Id);
            
            // Check if Status changed to "Submitted"
            if (newPO.Status__c == 'Submitted' && oldPO.Status__c != 'Submitted') {
                poIdsToProcess.add(newPO.Id);
            }
        }
        
        if (!poIdsToProcess.isEmpty()) {
            // Query related line items
            List<Purchase_Order_Line_Item__c> relatedLineItems = [
                SELECT Id, Quantity_Ordered__c, Ingredient__c
                FROM Purchase_Order_Line_Item__c
                WHERE Purchase_Order__c IN :poIdsToProcess
                AND Ingredient__c != NULL
            ];
            
            // Query related ingredients
            Set<Id> ingredientIds = new Set<Id>();
            for (Purchase_Order_Line_Item__c lineItem : relatedLineItems) {
                ingredientIds.add(lineItem.Ingredient__c);
            }
            
            if (!ingredientIds.isEmpty()) {
                Map<Id, Ingredient__c> ingredientMap = new Map<Id, Ingredient__c>([
                    SELECT Id, On_Order__c
                    FROM Ingredient__c
                    WHERE Id IN :ingredientIds
                ]);
                
                // Update On_Order__c for each ingredient
                for (Purchase_Order_Line_Item__c lineItem : relatedLineItems) {
                    Ingredient__c ingredient = ingredientMap.get(lineItem.Ingredient__c);
                    if (ingredient != null) {
                        if (ingredient.On_Order__c == null) {
                            ingredient.On_Order__c = 0;
                        }
                        ingredient.On_Order__c += lineItem.Quantity_Ordered__c;
                        ingredientsToUpdate.add(ingredient);
                    }
                }
                
                // Update ingredients
                if (!ingredientsToUpdate.isEmpty()) {
                    update ingredientsToUpdate;
                }
            }
        }
    }
}
