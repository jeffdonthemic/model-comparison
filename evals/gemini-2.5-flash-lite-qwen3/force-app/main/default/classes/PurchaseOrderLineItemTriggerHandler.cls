public with sharing class PurchaseOrderLineItemTriggerHandler {
    
    public static void handleAfterInsertOrUpdate(List<Purchase_Order_Line_Item__c> newLineItems, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        // Rule 4: Handle Quantity_Received__c changes
        List<Ingredient__c> ingredientsToUpdate = new List<Ingredient__c>();
        Map<Id, Purchase_Order__c> posToUpdate = new Map<Id, Purchase_Order__c>();
        
        // Collect ingredients to update
        Set<Id> ingredientIds = new Set<Id>();
        for (Purchase_Order_Line_Item__c newLineItem : newLineItems) {
            if (newLineItem.Ingredient__c != null) {
                ingredientIds.add(newLineItem.Ingredient__c);
            }
        }
        
        // Query ingredients
        Map<Id, Ingredient__c> ingredientMap = new Map<Id, Ingredient__c>();
        if (!ingredientIds.isEmpty()) {
            ingredientMap = new Map<Id, Ingredient__c>([
                SELECT Id, In_Stock__c, On_Order__c
                FROM Ingredient__c
                WHERE Id IN :ingredientIds
            ]);
        }
        
        // Process each line item
        for (Purchase_Order_Line_Item__c newLineItem : newLineItems) {
            Purchase_Order_Line_Item__c oldLineItem = oldMap?.get(newLineItem.Id);
            
            // Check if Quantity_Received__c changed
            Decimal oldQuantityReceived = oldLineItem?.Quantity_Received__c != null ? oldLineItem.Quantity_Received__c : 0;
            Decimal newQuantityReceived = newLineItem.Quantity_Received__c != null ? newLineItem.Quantity_Received__c : 0;
            
            if (oldQuantityReceived != newQuantityReceived && newLineItem.Ingredient__c != null) {
                Decimal delta = newQuantityReceived - oldQuantityReceived;
                Ingredient__c ingredient = ingredientMap.get(newLineItem.Ingredient__c);
                
                if (ingredient != null) {
                    // Update In_Stock__c and On_Order__c
                    if (ingredient.In_Stock__c == null) {
                        ingredient.In_Stock__c = 0;
                    }
                    if (ingredient.On_Order__c == null) {
                        ingredient.On_Order__c = 0;
                    }
                    
                    ingredient.In_Stock__c += delta;
                    ingredient.On_Order__c -= delta;
                    
                    ingredientsToUpdate.add(ingredient);
                }
            }
            
            // Collect parent POs for status update (Rule 5)
            if (newLineItem.Purchase_Order__c != null) {
                posToUpdate.put(newLineItem.Purchase_Order__c, null); // Will query later
            }
        }
        
        // Update ingredients
        if (!ingredientsToUpdate.isEmpty()) {
            update ingredientsToUpdate;
        }
        
        // Rule 5: Update PO Status based on received quantities
        updatePurchaseOrderStatuses(posToUpdate.keySet());
    }
    
    private static void updatePurchaseOrderStatuses(Set<Id> poIds) {
        if (poIds.isEmpty()) return;
        
        // Query POs with their line items
        List<Purchase_Order__c> pos = [
            SELECT Id, Status__c, 
                   (SELECT Id, Quantity_Ordered__c, Quantity_Received__c 
                    FROM Purchase_Order_Line_Items__r) 
            FROM Purchase_Order__c 
            WHERE Id IN :poIds
        ];
        
        List<Purchase_Order__c> posToUpdate = new List<Purchase_Order__c>();
        
        for (Purchase_Order__c po : pos) {
            Decimal totalOrdered = 0;
            Decimal totalReceived = 0;
            Boolean hasReceivedItems = false;
            
            for (Purchase_Order_Line_Item__c lineItem : po.Purchase_Order_Line_Items__r) {
                Decimal qtyOrdered = lineItem.Quantity_Ordered__c != null ? lineItem.Quantity_Ordered__c : 0;
                Decimal qtyReceived = lineItem.Quantity_Received__c != null ? lineItem.Quantity_Received__c : 0;
                
                totalOrdered += qtyOrdered;
                totalReceived += qtyReceived;
                
                if (qtyReceived > 0) {
                    hasReceivedItems = true;
                }
            }
            
            // Update status based on received quantities
            if (hasReceivedItems) {
                if (totalReceived > 0 && totalReceived < totalOrdered) {
                    po.Status__c = 'Partially Received';
                    posToUpdate.add(po);
                } else if (totalReceived == totalOrdered && totalOrdered > 0) {
                    po.Status__c = 'Received';
                    posToUpdate.add(po);
                }
            }
        }
        
        // Update POs
        if (!posToUpdate.isEmpty()) {
            update posToUpdate;
        }
    }
}
