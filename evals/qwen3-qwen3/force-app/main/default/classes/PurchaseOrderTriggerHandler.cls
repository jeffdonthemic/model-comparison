public with sharing class PurchaseOrderTriggerHandler {
    
    public static void handleBeforeInsert(List<Purchase_Order__c> newPOs) {
        for (Purchase_Order__c po : newPOs) {
            // Set default status to Draft for new purchase orders
            if (String.isBlank(po.Status__c)) {
                po.Status__c = 'Draft';
            }
        }
    }
    
    public static void handleBeforeUpdate(List<Purchase_Order__c> newPOs, Map<Id, Purchase_Order__c> oldMap) {
        for (Purchase_Order__c po : newPOs) {
            Purchase_Order__c oldPO = oldMap.get(po.Id);
            
            // Business Rule 1: When Approved__c is checked, automatically update Status__c to "Approved"
            if (po.Approved__c && !oldPO.Approved__c) {
                po.Status__c = 'Approved';
            }
            
            // Business Rule 2: A user can only manually change Status__c to "Submitted" if Approved__c = TRUE
            if (po.Status__c == 'Submitted' && !po.Approved__c) {
                po.Status__c = oldPO.Status__c; // Revert to old status
                po.addError('Status can only be set to "Submitted" when the Purchase Order is approved.');
            }
        }
    }
    
    public static void handleAfterUpdate(List<Purchase_Order__c> newPOs, Map<Id, Purchase_Order__c> oldMap) {
        List<Purchase_Order_Line_Item__c> lineItemsToUpdate = new List<Purchase_Order_Line_Item__c>();
        Set<Id> poIdsToProcess = new Set<Id>();
        
        for (Purchase_Order__c po : newPOs) {
            Purchase_Order__c oldPO = oldMap.get(po.Id);
            
            // Business Rule 3: When a Purchase Order is set to "Submitted"
            if (po.Status__c == 'Submitted' && oldPO.Status__c != 'Submitted') {
                poIdsToProcess.add(po.Id);
            }
        }
        
        if (!poIdsToProcess.isEmpty()) {
            // Get all line items for the submitted purchase orders
            List<Purchase_Order_Line_Item__c> lineItems = [
                SELECT Id, Ingredient__c, Quantity_Ordered__c 
                FROM Purchase_Order_Line_Item__c 
                WHERE Purchase_Order__c IN :poIdsToProcess 
                AND Ingredient__c != null
            ];
            
            // Create map of ingredient IDs to quantity ordered
            Map<Id, Decimal> ingredientQtyMap = new Map<Id, Decimal>();
            
            for (Purchase_Order_Line_Item__c lineItem : lineItems) {
                if (ingredientQtyMap.containsKey(lineItem.Ingredient__c)) {
                    ingredientQtyMap.put(lineItem.Ingredient__c, 
                        ingredientQtyMap.get(lineItem.Ingredient__c) + lineItem.Quantity_Ordered__c);
                } else {
                    ingredientQtyMap.put(lineItem.Ingredient__c, lineItem.Quantity_Ordered__c);
                }
            }
            
            // Get ingredients and update On_Order__c
            if (!ingredientQtyMap.isEmpty()) {
                List<Ingredient__c> ingredients = [
                    SELECT Id, On_Order__c 
                    FROM Ingredient__c 
                    WHERE Id IN :ingredientQtyMap.keySet()
                ];
                
                for (Ingredient__c ingredient : ingredients) {
                    ingredient.On_Order__c += ingredientQtyMap.get(ingredient.Id);
                }
                
                if (!ingredients.isEmpty()) {
                    update ingredients;
                }
            }
        }
    }
    
    public static void updatePurchaseOrderStatus(List<Purchase_Order_Line_Item__c> newLineItems, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        Set<Id> poIds = new Set<Id>();
        Map<Id, List<Purchase_Order_Line_Item__c>> poLineItemsMap = new Map<Id, List<Purchase_Order_Line_Item__c>>();
        
        // Group line items by purchase order
        for (Purchase_Order_Line_Item__c lineItem : newLineItems) {
            if (lineItem.Purchase_Order__c != null) {
                poIds.add(lineItem.Purchase_Order__c);
                
                if (!poLineItemsMap.containsKey(lineItem.Purchase_Order__c)) {
                    poLineItemsMap.put(lineItem.Purchase_Order__c, new List<Purchase_Order_Line_Item__c>());
                }
                poLineItemsMap.get(lineItem.Purchase_Order__c).add(lineItem);
            }
        }
        
        if (!poIds.isEmpty()) {
            // Get purchase orders
            Map<Id, Purchase_Order__c> poMap = new Map<Id, Purchase_Order__c>([
                SELECT Id, Status__c 
                FROM Purchase_Order__c 
                WHERE Id IN :poIds
            ]);
            
            // Get original line items for comparison
            Map<Id, Purchase_Order_Line_Item__c> oldLineItemsMap = new Map<Id, Purchase_Order_Line_Item__c>();
            if (oldMap != null) {
                oldLineItemsMap = oldMap;
            } else {
                // For insert operations, oldMap is null
                oldLineItemsMap = new Map<Id, Purchase_Order_Line_Item__c>();
                for (Purchase_Order_Line_Item__c lineItem : newLineItems) {
                    oldLineItemsMap.put(lineItem.Id, new Purchase_Order_Line_Item__c(
                        Quantity_Received__c = 0
                    ));
                }
            }
            
            List<Purchase_Order__c> posToUpdate = new List<Purchase_Order__c>();
            List<Ingredient__c> ingredientsToUpdate = new List<Ingredient__c>();
            Map<Id, Ingredient__c> ingredientMap = new Map<Id, Ingredient__c>();
            
            // Process each purchase order
            for (Id poId : poIds) {
                Purchase_Order__c po = poMap.get(poId);
                List<Purchase_Order_Line_Item__c> lineItems = poLineItemsMap.get(poId);
                
                Decimal totalOrdered = 0;
                Decimal totalReceived = 0;
                Boolean hasReceivedItems = false;
                
                // Calculate totals and update ingredients
                for (Purchase_Order_Line_Item__c lineItem : lineItems) {
                    totalOrdered += lineItem.Quantity_Ordered__c;
                    totalReceived += lineItem.Quantity_Received__c;
                    
                    if (lineItem.Quantity_Received__c > 0) {
                        hasReceivedItems = true;
                    }
                    
                    // Get the old value for delta calculation
                    Purchase_Order_Line_Item__c oldLineItem = oldLineItemsMap.get(lineItem.Id);
                    Decimal oldReceived = (oldLineItem != null) ? oldLineItem.Quantity_Received__c : 0;
                    Decimal newReceived = lineItem.Quantity_Received__c;
                    
                    // Calculate delta
                    Decimal delta = newReceived - oldReceived;
                    
                    // Validate that received quantity doesn't exceed ordered quantity
                    if (newReceived > lineItem.Quantity_Ordered__c) {
                        lineItem.Quantity_Received__c = oldLineItem.Quantity_Received__c;
                        lineItem.addError('Received quantity cannot exceed ordered quantity.');
                    }
                    
                    // Update ingredient if there's a delta and ingredient is specified
                    if (delta != 0 && lineItem.Ingredient__c != null) {
                        Ingredient__c ingredient = ingredientMap.get(lineItem.Ingredient__c);
                        if (ingredient == null) {
                            ingredient = new Ingredient__c(Id = lineItem.Ingredient__c);
                            ingredientMap.put(lineItem.Ingredient__c, ingredient);
                        }
                        
                        // Update inventory: increase stock, decrease on order
                        ingredient.In_Stock__c = (ingredient.In_Stock__c == null) ? delta : ingredient.In_Stock__c + delta;
                        ingredient.On_Order__c = (ingredient.On_Order__c == null) ? -delta : ingredient.On_Order__c - delta;
                    }
                }
                
                // Update purchase order status based on received quantities
                if (hasReceivedItems) {
                    if (totalReceived == totalOrdered) {
                        po.Status__c = 'Received';
                    } else {
                        po.Status__c = 'Partially Received';
                    }
                    posToUpdate.add(po);
                }
            }
            
            // Update ingredients
            if (!ingredientMap.isEmpty()) {
                // Query existing ingredient values
                List<Ingredient__c> existingIngredients = [
                    SELECT Id, In_Stock__c, On_Order__c 
                    FROM Ingredient__c 
                    WHERE Id IN :ingredientMap.keySet()
                ];
                
                // Merge the updates with existing values
                for (Ingredient__c existingIngredient : existingIngredients) {
                    Ingredient__c updateIngredient = ingredientMap.get(existingIngredient.Id);
                    updateIngredient.In_Stock__c = existingIngredient.In_Stock__c + updateIngredient.In_Stock__c;
                    updateIngredient.On_Order__c = existingIngredient.On_Order__c + updateIngredient.On_Order__c;
                }
                
                ingredientsToUpdate.addAll(ingredientMap.values());
            }
            
            // Perform updates
            if (!posToUpdate.isEmpty()) {
                update posToUpdate;
            }
            
            if (!ingredientsToUpdate.isEmpty()) {
                update ingredientsToUpdate;
            }
        }
    }
}
