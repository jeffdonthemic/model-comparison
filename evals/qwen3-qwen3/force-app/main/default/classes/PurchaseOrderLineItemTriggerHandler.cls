public with sharing class PurchaseOrderLineItemTriggerHandler {
    
    public static void handleBeforeInsert(List<Purchase_Order_Line_Item__c> newLineItems) {
        validateReceivedQuantity(newLineItems, null);
    }
    
    public static void handleBeforeUpdate(List<Purchase_Order_Line_Item__c> newLineItems, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        validateReceivedQuantity(newLineItems, oldMap);
    }
    
    public static void handleAfterInsert(List<Purchase_Order_Line_Item__c> newLineItems) {
        PurchaseOrderTriggerHandler.updatePurchaseOrderStatus(newLineItems, null);
    }
    
    public static void handleAfterUpdate(List<Purchase_Order_Line_Item__c> newLineItems, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        PurchaseOrderTriggerHandler.updatePurchaseOrderStatus(newLineItems, oldMap);
    }
    
    public static void handleAfterDelete(List<Purchase_Order_Line_Item__c> oldLineItems) {
        // When line items are deleted, we might want to update the parent PO status
        // For simplicity, we'll just call the same method with empty new items
        PurchaseOrderTriggerHandler.updatePurchaseOrderStatus(new List<Purchase_Order_Line_Item__c>(), 
            new Map<Id, Purchase_Order_Line_Item__c>(oldLineItems));
    }
    
    private static void validateReceivedQuantity(List<Purchase_Order_Line_Item__c> lineItems, Map<Id, Purchase_Order_Line_Item__c> oldMap) {
        for (Purchase_Order_Line_Item__c lineItem : lineItems) {
            // Validate that received quantity doesn't exceed ordered quantity
            if (lineItem.Quantity_Received__c != null && lineItem.Quantity_Received__c > lineItem.Quantity_Ordered__c) {
                lineItem.Quantity_Received__c = (oldMap != null && oldMap.containsKey(lineItem.Id)) 
                    ? oldMap.get(lineItem.Id).Quantity_Received__c : 0;
                lineItem.addError('Received quantity cannot exceed ordered quantity.');
            }
        }
    }
}
