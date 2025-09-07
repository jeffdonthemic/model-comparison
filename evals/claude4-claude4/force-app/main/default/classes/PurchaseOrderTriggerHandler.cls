/**
 * @description Handler class for Purchase Order trigger logic
 * @author System Administrator
 * @date 2025
 */
public with sharing class PurchaseOrderTriggerHandler {
    
    private static Boolean isRecursive = false;
    
    /**
     * @description Before insert handler
     * @param newRecords List of new Purchase Order records
     */
    public void beforeInsert(List<Purchase_Order__c> newRecords) {
        handleApprovalStatusUpdate(newRecords, null);
    }
    
    /**
     * @description Before update handler
     * @param newRecords List of new Purchase Order records
     * @param oldMap Map of old Purchase Order records
     */
    public void beforeUpdate(List<Purchase_Order__c> newRecords, Map<Id, Purchase_Order__c> oldMap) {
        validateStatusChange(newRecords, oldMap);
        handleApprovalStatusUpdate(newRecords, oldMap);
    }
    
    /**
     * @description After insert handler
     * @param newRecords List of new Purchase Order records
     */
    public void afterInsert(List<Purchase_Order__c> newRecords) {
        // No after insert logic needed currently
    }
    
    /**
     * @description After update handler
     * @param newRecords List of new Purchase Order records
     * @param oldMap Map of old Purchase Order records
     */
    public void afterUpdate(List<Purchase_Order__c> newRecords, Map<Id, Purchase_Order__c> oldMap) {
        handleSubmittedStatusChange(newRecords, oldMap);
    }
    
    /**
     * @description Handle automatic status update when Approved checkbox is checked
     * @param newRecords List of new Purchase Order records
     * @param oldMap Map of old Purchase Order records (null for insert)
     */
    private void handleApprovalStatusUpdate(List<Purchase_Order__c> newRecords, Map<Id, Purchase_Order__c> oldMap) {
        for (Purchase_Order__c po : newRecords) {
            Purchase_Order__c oldPO = oldMap?.get(po.Id);
            
            // If Approved checkbox is checked and it wasn't before, set status to Approved
            if (po.Approved__c && (oldPO == null || !oldPO.Approved__c)) {
                po.Status__c = 'Approved';
            }
        }
    }
    
    /**
     * @description Validate status changes - only allow Submitted if Approved is true
     * @param newRecords List of new Purchase Order records
     * @param oldMap Map of old Purchase Order records
     */
    private void validateStatusChange(List<Purchase_Order__c> newRecords, Map<Id, Purchase_Order__c> oldMap) {
        for (Purchase_Order__c po : newRecords) {
            Purchase_Order__c oldPO = oldMap.get(po.Id);
            
            // If status is being changed to Submitted, validate that Approved is true
            if (po.Status__c == 'Submitted' && oldPO.Status__c != 'Submitted' && !po.Approved__c) {
                po.addError('Purchase Order must be approved before it can be submitted.');
            }
        }
    }
    
    /**
     * @description Handle ingredient On_Order quantity updates when PO status changes to Submitted
     * @param newRecords List of new Purchase Order records
     * @param oldMap Map of old Purchase Order records
     */
    private void handleSubmittedStatusChange(List<Purchase_Order__c> newRecords, Map<Id, Purchase_Order__c> oldMap) {
        if (isRecursive) return;
        
        Set<Id> submittedPOIds = new Set<Id>();
        
        for (Purchase_Order__c po : newRecords) {
            Purchase_Order__c oldPO = oldMap.get(po.Id);
            
            // Check if status changed to Submitted
            if (po.Status__c == 'Submitted' && oldPO.Status__c != 'Submitted') {
                submittedPOIds.add(po.Id);
            }
        }
        
        if (!submittedPOIds.isEmpty()) {
            updateIngredientOnOrderQuantities(submittedPOIds);
        }
    }
    
    /**
     * @description Update ingredient On_Order quantities for submitted purchase orders
     * @param purchaseOrderIds Set of Purchase Order IDs that were submitted
     */
    private void updateIngredientOnOrderQuantities(Set<Id> purchaseOrderIds) {
        // Query line items for submitted purchase orders
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Ingredient__c, Quantity_Ordered__c
            FROM Purchase_Order_Line_Item__c
            WHERE Purchase_Order__c IN :purchaseOrderIds
            AND Ingredient__c != null
        ];
        
        if (lineItems.isEmpty()) return;
        
        // Group quantities by ingredient
        Map<Id, Decimal> ingredientQuantityMap = new Map<Id, Decimal>();
        
        for (Purchase_Order_Line_Item__c lineItem : lineItems) {
            Id ingredientId = lineItem.Ingredient__c;
            Decimal quantity = lineItem.Quantity_Ordered__c ?? 0;
            
            if (ingredientQuantityMap.containsKey(ingredientId)) {
                ingredientQuantityMap.put(ingredientId, ingredientQuantityMap.get(ingredientId) + quantity);
            } else {
                ingredientQuantityMap.put(ingredientId, quantity);
            }
        }
        
        // Query and update ingredients
        List<Ingredient__c> ingredientsToUpdate = [
            SELECT Id, On_Order__c
            FROM Ingredient__c
            WHERE Id IN :ingredientQuantityMap.keySet()
        ];
        
        for (Ingredient__c ingredient : ingredientsToUpdate) {
            Decimal currentOnOrder = ingredient.On_Order__c ?? 0;
            Decimal additionalQuantity = ingredientQuantityMap.get(ingredient.Id);
            ingredient.On_Order__c = currentOnOrder + additionalQuantity;
        }
        
        if (!ingredientsToUpdate.isEmpty()) {
            isRecursive = true;
            try {
                update ingredientsToUpdate;
            } catch (Exception e) {
                System.debug('Error updating ingredient On_Order quantities: ' + e.getMessage());
                throw e;
            } finally {
                isRecursive = false;
            }
        }
    }
}
