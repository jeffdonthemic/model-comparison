/**
 * @description Controller class for Purchase Order Receiving Lightning Web Component
 * @author System Administrator
 * @date 2025
 */
public with sharing class PurchaseOrderReceivingController {
    
    /**
     * @description Wrapper class for Purchase Order data
     */
    public class PurchaseOrderData {
        @AuraEnabled
        public Purchase_Order__c purchaseOrder { get; set; }
        
        @AuraEnabled
        public List<LineItemWrapper> lineItems { get; set; }
        
        public PurchaseOrderData() {
            this.lineItems = new List<LineItemWrapper>();
        }
    }
    
    /**
     * @description Wrapper class for Line Item data with ingredient name
     */
    public class LineItemWrapper {
        @AuraEnabled
        public Id Id { get; set; }
        
        @AuraEnabled
        public Id PurchaseOrderId { get; set; }
        
        @AuraEnabled
        public Id IngredientId { get; set; }
        
        @AuraEnabled
        public String ingredientName { get; set; }
        
        @AuraEnabled
        public Decimal QuantityOrdered { get; set; }
        
        @AuraEnabled
        public Decimal QuantityReceived { get; set; }
        
        @AuraEnabled
        public Decimal UnitCost { get; set; }
        
        @AuraEnabled
        public Decimal LineTotal { get; set; }
        
        public LineItemWrapper(Purchase_Order_Line_Item__c lineItem) {
            this.Id = lineItem.Id;
            this.PurchaseOrderId = lineItem.Purchase_Order__c;
            this.IngredientId = lineItem.Ingredient__c;
            this.ingredientName = lineItem.Ingredient__r?.Name;
            this.QuantityOrdered = lineItem.Quantity_Ordered__c;
            this.QuantityReceived = lineItem.Quantity_Received__c;
            this.UnitCost = lineItem.Unit_Cost__c;
            this.LineTotal = lineItem.Line_Total__c;
        }
    }
    
    /**
     * @description Get Purchase Order with related Line Items
     * @param purchaseOrderId The ID of the Purchase Order
     * @return PurchaseOrderData wrapper containing Purchase Order and Line Items
     */
    @AuraEnabled(cacheable=true)
    public static PurchaseOrderData getPurchaseOrderWithLineItems(Id purchaseOrderId) {
        try {
            if (purchaseOrderId == null) {
                throw new AuraHandledException('Purchase Order ID is required');
            }
            
            PurchaseOrderData result = new PurchaseOrderData();
            
            // Query Purchase Order
            List<Purchase_Order__c> purchaseOrders = [
                SELECT Id, Name, Status__c, Approved__c, Order_Date__c, 
                       Expected_Delivery_Date__c, Total_Amount__c, Notes__c,
                       Supplier__c, Supplier__r.Name
                FROM Purchase_Order__c
                WHERE Id = :purchaseOrderId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            
            if (purchaseOrders.isEmpty()) {
                throw new AuraHandledException('Purchase Order not found');
            }
            
            result.purchaseOrder = purchaseOrders[0];
            
            // Query Line Items
            List<Purchase_Order_Line_Item__c> lineItems = [
                SELECT Id, Purchase_Order__c, Ingredient__c, Ingredient__r.Name,
                       Quantity_Ordered__c, Quantity_Received__c, Unit_Cost__c, Line_Total__c
                FROM Purchase_Order_Line_Item__c
                WHERE Purchase_Order__c = :purchaseOrderId
                WITH SECURITY_ENFORCED
                ORDER BY Ingredient__r.Name
            ];
            
            // Convert to wrapper objects
            for (Purchase_Order_Line_Item__c lineItem : lineItems) {
                result.lineItems.add(new LineItemWrapper(lineItem));
            }
            
            return result;
            
        } catch (Exception e) {
            System.debug('Error in getPurchaseOrderWithLineItems: ' + e.getMessage());
            throw new AuraHandledException('Error loading purchase order data: ' + e.getMessage());
        }
    }
    
    /**
     * @description Update line item quantities received
     * @param lineItemUpdates List of line items with updated quantities
     * @return String success message
     */
    @AuraEnabled
    public static String updateLineItemQuantities(List<Purchase_Order_Line_Item__c> lineItemUpdates) {
        try {
            if (lineItemUpdates == null || lineItemUpdates.isEmpty()) {
                throw new AuraHandledException('No line items to update');
            }
            
            // Validate that all records have IDs
            for (Purchase_Order_Line_Item__c lineItem : lineItemUpdates) {
                if (lineItem.Id == null) {
                    throw new AuraHandledException('Line item ID is required for updates');
                }
                
                // Validate quantity received is not negative
                if (lineItem.Quantity_Received__c < 0) {
                    throw new AuraHandledException('Quantity received cannot be negative');
                }
            }
            
            // Query existing line items to validate quantity constraints
            Set<Id> lineItemIds = new Set<Id>();
            for (Purchase_Order_Line_Item__c lineItem : lineItemUpdates) {
                lineItemIds.add(lineItem.Id);
            }
            
            Map<Id, Purchase_Order_Line_Item__c> existingLineItems = new Map<Id, Purchase_Order_Line_Item__c>([
                SELECT Id, Quantity_Ordered__c, Quantity_Received__c
                FROM Purchase_Order_Line_Item__c
                WHERE Id IN :lineItemIds
                WITH SECURITY_ENFORCED
            ]);
            
            // Validate quantity constraints
            for (Purchase_Order_Line_Item__c updateItem : lineItemUpdates) {
                Purchase_Order_Line_Item__c existingItem = existingLineItems.get(updateItem.Id);
                if (existingItem == null) {
                    throw new AuraHandledException('Line item not found: ' + updateItem.Id);
                }
                
                if (updateItem.Quantity_Received__c > existingItem.Quantity_Ordered__c) {
                    throw new AuraHandledException('Quantity received cannot exceed quantity ordered');
                }
            }
            
            // Update the line items
            Database.SaveResult[] results = Database.update(lineItemUpdates, false);
            
            // Check for errors
            List<String> errors = new List<String>();
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error error : results[i].getErrors()) {
                        errors.add('Line item ' + lineItemUpdates[i].Id + ': ' + error.getMessage());
                    }
                }
            }
            
            if (!errors.isEmpty()) {
                throw new AuraHandledException('Update failed: ' + String.join(errors, '; '));
            }
            
            return 'Successfully updated ' + lineItemUpdates.size() + ' line item(s)';
            
        } catch (Exception e) {
            System.debug('Error in updateLineItemQuantities: ' + e.getMessage());
            throw new AuraHandledException('Error updating line items: ' + e.getMessage());
        }
    }
}
