public with sharing class PurchaseOrderReceiverController {
    
    public class PurchaseOrderWrapper {
        public Purchase_Order__c purchaseOrder { get; set; }
        public List<Purchase_Order_Line_Item__c> lineItems { get; set; }
        
        public PurchaseOrderWrapper(Purchase_Order__c po, List<Purchase_Order_Line_Item__c> items) {
            this.purchaseOrder = po;
            this.lineItems = items;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static PurchaseOrderWrapper getPurchaseOrderWithLineItems(Id purchaseOrderId) {
        // Get the purchase order
        Purchase_Order__c po = [
            SELECT Id, Name, Status__c, Supplier__c, Supplier__r.Name, Expected_Delivery_Date__c, Notes__c
            FROM Purchase_Order__c 
            WHERE Id = :purchaseOrderId
            LIMIT 1
        ];
        
        // Get the line items
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Name, Ingredient__c, Ingredient__r.Name, Quantity_Ordered__c, 
                   Quantity_Received__c, Unit_Cost__c, Line_Total__c, Purchase_Order__c
            FROM Purchase_Order_Line_Item__c 
            WHERE Purchase_Order__c = :purchaseOrderId
            ORDER BY Name
        ];
        
        return new PurchaseOrderWrapper(po, lineItems);
    }
    
    @AuraEnabled
    public static void updateLineItems(List<Purchase_Order_Line_Item__c> lineItems) {
        if (lineItems != null && !lineItems.isEmpty()) {
            // Validate that received quantities don't exceed ordered quantities
            Set<Id> lineItemIds = new Set<Id>();
            for (Purchase_Order_Line_Item__c item : lineItems) {
                lineItemIds.add(item.Id);
            }
            
            // Get original line items for validation
            Map<Id, Purchase_Order_Line_Item__c> originalItems = new Map<Id, Purchase_Order_Line_Item__c>([
                SELECT Id, Quantity_Ordered__c 
                FROM Purchase_Order_Line_Item__c 
                WHERE Id IN :lineItemIds
            ]);
            
            // Validate each item
            for (Purchase_Order_Line_Item__c item : lineItems) {
                Purchase_Order_Line_Item__c originalItem = originalItems.get(item.Id);
                if (originalItem != null && item.Quantity_Received__c > originalItem.Quantity_Ordered__c) {
                    throw new AuraHandledException('Received quantity cannot exceed ordered quantity for line item: ' + originalItem.Name);
                }
            }
            
            // Update the line items
            update lineItems;
        }
    }
}
