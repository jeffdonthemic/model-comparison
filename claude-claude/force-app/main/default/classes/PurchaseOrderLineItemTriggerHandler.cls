/**
 * @description       : Handler class for Purchase Order Line Item trigger
 * @author            : liquidlogixsolutions
 * @group             : 
 * @last modified on  : 09-02-2025
 * @last modified by  : liquidlogixsolutions
**/
public with sharing class PurchaseOrderLineItemTriggerHandler {
    
    public static void handleAfterUpdate(List<Purchase_Order_Line_Item__c> newLineItems, Map<Id, Purchase_Order_Line_Item__c> oldLineItemsMap) {
        Set<Id> ingredientIds = new Set<Id>();
        Set<Id> purchaseOrderIds = new Set<Id>();
        
        // Collect ingredient IDs and purchase order IDs for items where quantity received changed
        for (Purchase_Order_Line_Item__c lineItem : newLineItems) {
            Purchase_Order_Line_Item__c oldLineItem = oldLineItemsMap.get(lineItem.Id);
            
            if (lineItem.Quantity_Received__c != oldLineItem.Quantity_Received__c) {
                if (lineItem.Ingredient__c != null) {
                    ingredientIds.add(lineItem.Ingredient__c);
                }
                purchaseOrderIds.add(lineItem.Purchase_Order__c);
            }
        }
        
        // Update ingredient stock levels
        if (!ingredientIds.isEmpty()) {
            updateIngredientStock(newLineItems, oldLineItemsMap, ingredientIds);
        }
        
        // Update purchase order status
        if (!purchaseOrderIds.isEmpty()) {
            updatePurchaseOrderStatus(purchaseOrderIds);
        }
    }
    
    private static void updateIngredientStock(List<Purchase_Order_Line_Item__c> newLineItems, 
                                            Map<Id, Purchase_Order_Line_Item__c> oldLineItemsMap, 
                                            Set<Id> ingredientIds) {
        
        Map<Id, Ingredient__c> ingredientsToUpdate = new Map<Id, Ingredient__c>();
        
        // Get current ingredient records
        Map<Id, Ingredient__c> ingredientMap = new Map<Id, Ingredient__c>([
            SELECT Id, In_Stock__c 
            FROM Ingredient__c 
            WHERE Id IN :ingredientIds
        ]);
        
        // Calculate stock changes
        for (Purchase_Order_Line_Item__c lineItem : newLineItems) {
            Purchase_Order_Line_Item__c oldLineItem = oldLineItemsMap.get(lineItem.Id);
            
            if (lineItem.Quantity_Received__c != oldLineItem.Quantity_Received__c && lineItem.Ingredient__c != null) {
                Decimal quantityChange = (lineItem.Quantity_Received__c != null ? lineItem.Quantity_Received__c : 0) - 
                                       (oldLineItem.Quantity_Received__c != null ? oldLineItem.Quantity_Received__c : 0);
                
                if (quantityChange != 0) {
                    Ingredient__c ingredient = ingredientMap.get(lineItem.Ingredient__c);
                    if (ingredient != null) {
                        if (!ingredientsToUpdate.containsKey(ingredient.Id)) {
                            ingredientsToUpdate.put(ingredient.Id, ingredient.clone(true, true, true, true));
                        }
                        
                        Ingredient__c ingredientToUpdate = ingredientsToUpdate.get(ingredient.Id);
                        Decimal currentStock = ingredientToUpdate.In_Stock__c != null ? ingredientToUpdate.In_Stock__c : 0;
                        ingredientToUpdate.In_Stock__c = currentStock + quantityChange;
                    }
                }
            }
        }
        
        // Update ingredients
        if (!ingredientsToUpdate.isEmpty()) {
            try {
                update ingredientsToUpdate.values();
            } catch (Exception e) {
                System.debug('Error updating ingredient stock: ' + e.getMessage());
            }
        }
    }
    
    private static void updatePurchaseOrderStatus(Set<Id> purchaseOrderIds) {
        List<Purchase_Order__c> purchaseOrdersToUpdate = new List<Purchase_Order__c>();
        
        // Get purchase orders with their line items
        Map<Id, Purchase_Order__c> purchaseOrderMap = new Map<Id, Purchase_Order__c>([
            SELECT Id, Status__c, 
                   (SELECT Id, Quantity_Ordered__c, Quantity_Received__c 
                    FROM Purchase_Order_Line_Items__r)
            FROM Purchase_Order__c 
            WHERE Id IN :purchaseOrderIds
        ]);
        
        for (Purchase_Order__c po : purchaseOrderMap.values()) {
            String newStatus = calculatePurchaseOrderStatus(po);
            
            if (newStatus != po.Status__c) {
                Purchase_Order__c poToUpdate = new Purchase_Order__c(Id = po.Id, Status__c = newStatus);
                purchaseOrdersToUpdate.add(poToUpdate);
            }
        }
        
        // Update purchase orders
        if (!purchaseOrdersToUpdate.isEmpty()) {
            try {
                update purchaseOrdersToUpdate;
            } catch (Exception e) {
                System.debug('Error updating purchase order status: ' + e.getMessage());
            }
        }
    }
    
    private static String calculatePurchaseOrderStatus(Purchase_Order__c po) {
        if (po.Purchase_Order_Line_Items__r == null || po.Purchase_Order_Line_Items__r.isEmpty()) {
            return po.Status__c; // No change if no line items
        }
        
        Decimal totalOrdered = 0;
        Decimal totalReceived = 0;
        
        for (Purchase_Order_Line_Item__c lineItem : po.Purchase_Order_Line_Items__r) {
            totalOrdered += (lineItem.Quantity_Ordered__c != null ? lineItem.Quantity_Ordered__c : 0);
            totalReceived += (lineItem.Quantity_Received__c != null ? lineItem.Quantity_Received__c : 0);
        }
        
        if (totalReceived == 0) {
            return po.Status__c; // Keep current status if nothing received
        } else if (totalReceived >= totalOrdered) {
            return 'Fully Received';
        } else {
            return 'Partially Received';
        }
    }
}
