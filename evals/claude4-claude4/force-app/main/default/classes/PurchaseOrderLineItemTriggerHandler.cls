/**
 * @description Handler class for Purchase Order Line Item trigger logic
 * @author System Administrator
 * @date 2025
 */
public with sharing class PurchaseOrderLineItemTriggerHandler {
    
    private static Boolean isRecursive = false;
    
    /**
     * @description Before insert handler
     * @param newRecords List of new Purchase Order Line Item records
     */
    public void beforeInsert(List<Purchase_Order_Line_Item__c> newRecords) {
        // No before insert logic needed currently
    }
    
    /**
     * @description Before update handler
     * @param newRecords List of new Purchase Order Line Item records
     * @param oldMap Map of old Purchase Order Line Item records
     */
    public void beforeUpdate(List<Purchase_Order_Line_Item__c> newRecords, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        // No before update logic needed currently
    }
    
    /**
     * @description After insert handler
     * @param newRecords List of new Purchase Order Line Item records
     */
    public void afterInsert(List<Purchase_Order_Line_Item__c> newRecords) {
        // No after insert logic needed currently
    }
    
    /**
     * @description After update handler
     * @param newRecords List of new Purchase Order Line Item records
     * @param oldMap Map of old Purchase Order Line Item records
     */
    public void afterUpdate(List<Purchase_Order_Line_Item__c> newRecords, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        handleQuantityReceivedChanges(newRecords, oldMap);
        updatePurchaseOrderStatus(newRecords, oldMap);
    }
    
    /**
     * @description Handle ingredient stock updates when quantity received changes
     * @param newRecords List of new Purchase Order Line Item records
     * @param oldMap Map of old Purchase Order Line Item records
     */
    private void handleQuantityReceivedChanges(List<Purchase_Order_Line_Item__c> newRecords, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        if (isRecursive) return;
        
        Map<Id, Decimal> ingredientStockChanges = new Map<Id, Decimal>();
        Map<Id, Decimal> ingredientOnOrderChanges = new Map<Id, Decimal>();
        
        for (Purchase_Order_Line_Item__c lineItem : newRecords) {
            Purchase_Order_Line_Item__c oldLineItem = oldMap.get(lineItem.Id);
            
            // Check if quantity received changed
            Decimal oldQuantityReceived = oldLineItem.Quantity_Received__c ?? 0;
            Decimal newQuantityReceived = lineItem.Quantity_Received__c ?? 0;
            
            if (newQuantityReceived != oldQuantityReceived && lineItem.Ingredient__c != null) {
                Decimal delta = newQuantityReceived - oldQuantityReceived;
                Id ingredientId = lineItem.Ingredient__c;
                
                // Update In_Stock by delta (increase)
                if (ingredientStockChanges.containsKey(ingredientId)) {
                    ingredientStockChanges.put(ingredientId, ingredientStockChanges.get(ingredientId) + delta);
                } else {
                    ingredientStockChanges.put(ingredientId, delta);
                }
                
                // Update On_Order by negative delta (decrease)
                if (ingredientOnOrderChanges.containsKey(ingredientId)) {
                    ingredientOnOrderChanges.put(ingredientId, ingredientOnOrderChanges.get(ingredientId) - delta);
                } else {
                    ingredientOnOrderChanges.put(ingredientId, -delta);
                }
            }
        }
        
        if (!ingredientStockChanges.isEmpty()) {
            updateIngredientQuantities(ingredientStockChanges, ingredientOnOrderChanges);
        }
    }
    
    /**
     * @description Update ingredient In_Stock and On_Order quantities
     * @param stockChanges Map of ingredient ID to stock change amount
     * @param onOrderChanges Map of ingredient ID to on order change amount
     */
    private void updateIngredientQuantities(Map<Id, Decimal> stockChanges, Map<Id, Decimal> onOrderChanges) {
        Set<Id> ingredientIds = new Set<Id>();
        ingredientIds.addAll(stockChanges.keySet());
        ingredientIds.addAll(onOrderChanges.keySet());
        
        List<Ingredient__c> ingredientsToUpdate = [
            SELECT Id, In_Stock__c, On_Order__c
            FROM Ingredient__c
            WHERE Id IN :ingredientIds
        ];
        
        for (Ingredient__c ingredient : ingredientsToUpdate) {
            if (stockChanges.containsKey(ingredient.Id)) {
                Decimal currentInStock = ingredient.In_Stock__c ?? 0;
                ingredient.In_Stock__c = currentInStock + stockChanges.get(ingredient.Id);
            }
            
            if (onOrderChanges.containsKey(ingredient.Id)) {
                Decimal currentOnOrder = ingredient.On_Order__c ?? 0;
                ingredient.On_Order__c = Math.max(0, currentOnOrder + onOrderChanges.get(ingredient.Id));
            }
        }
        
        if (!ingredientsToUpdate.isEmpty()) {
            isRecursive = true;
            try {
                update ingredientsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating ingredient quantities: ' + e.getMessage());
                throw e;
            } finally {
                isRecursive = false;
            }
        }
    }
    
    /**
     * @description Update Purchase Order status based on line item received quantities
     * @param newRecords List of new Purchase Order Line Item records
     * @param oldMap Map of old Purchase Order Line Item records
     */
    private void updatePurchaseOrderStatus(List<Purchase_Order_Line_Item__c> newRecords, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        Set<Id> purchaseOrderIds = new Set<Id>();
        
        // Collect Purchase Order IDs where quantity received changed
        for (Purchase_Order_Line_Item__c lineItem : newRecords) {
            Purchase_Order_Line_Item__c oldLineItem = oldMap.get(lineItem.Id);
            
            Decimal oldQuantityReceived = oldLineItem.Quantity_Received__c ?? 0;
            Decimal newQuantityReceived = lineItem.Quantity_Received__c ?? 0;
            
            if (newQuantityReceived != oldQuantityReceived) {
                purchaseOrderIds.add(lineItem.Purchase_Order__c);
            }
        }
        
        if (!purchaseOrderIds.isEmpty()) {
            calculateAndUpdatePurchaseOrderStatus(purchaseOrderIds);
        }
    }
    
    /**
     * @description Calculate and update Purchase Order status based on line item totals
     * @param purchaseOrderIds Set of Purchase Order IDs to update
     */
    private void calculateAndUpdatePurchaseOrderStatus(Set<Id> purchaseOrderIds) {
        // Query all line items for the affected purchase orders
        List<Purchase_Order_Line_Item__c> allLineItems = [
            SELECT Id, Purchase_Order__c, Quantity_Ordered__c, Quantity_Received__c
            FROM Purchase_Order_Line_Item__c
            WHERE Purchase_Order__c IN :purchaseOrderIds
        ];
        
        Map<Id, List<Purchase_Order_Line_Item__c>> poToLineItemsMap = new Map<Id, List<Purchase_Order_Line_Item__c>>();
        
        // Group line items by Purchase Order
        for (Purchase_Order_Line_Item__c lineItem : allLineItems) {
            if (!poToLineItemsMap.containsKey(lineItem.Purchase_Order__c)) {
                poToLineItemsMap.put(lineItem.Purchase_Order__c, new List<Purchase_Order_Line_Item__c>());
            }
            poToLineItemsMap.get(lineItem.Purchase_Order__c).add(lineItem);
        }
        
        List<Purchase_Order__c> purchaseOrdersToUpdate = new List<Purchase_Order__c>();
        
        // Calculate status for each Purchase Order
        for (Id poId : purchaseOrderIds) {
            List<Purchase_Order_Line_Item__c> lineItems = poToLineItemsMap.get(poId);
            if (lineItems == null || lineItems.isEmpty()) continue;
            
            Decimal totalOrdered = 0;
            Decimal totalReceived = 0;
            Boolean hasAnyReceived = false;
            
            for (Purchase_Order_Line_Item__c lineItem : lineItems) {
                Decimal ordered = lineItem.Quantity_Ordered__c ?? 0;
                Decimal received = lineItem.Quantity_Received__c ?? 0;
                
                totalOrdered += ordered;
                totalReceived += received;
                
                if (received > 0) {
                    hasAnyReceived = true;
                }
            }
            
            String newStatus;
            if (!hasAnyReceived) {
                // No items received, keep current status (likely Approved or Submitted)
                continue;
            } else if (totalReceived >= totalOrdered) {
                // All items received
                newStatus = 'Received';
            } else {
                // Some items received but not all
                newStatus = 'Partially Received';
            }
            
            purchaseOrdersToUpdate.add(new Purchase_Order__c(
                Id = poId,
                Status__c = newStatus
            ));
        }
        
        if (!purchaseOrdersToUpdate.isEmpty()) {
            try {
                update purchaseOrdersToUpdate;
            } catch (Exception e) {
                System.debug('Error updating Purchase Order status: ' + e.getMessage());
                throw e;
            }
        }
    }
}
