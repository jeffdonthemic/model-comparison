public with sharing class ReceivePurchaseOrderController {
    
    @AuraEnabled(cacheable=true)
    public static PurchaseOrderWrapper getPurchaseOrderAndLineItems(Id purchaseOrderId) {
        Purchase_Order__c po = [
            SELECT Id, Name, Status__c
            FROM Purchase_Order__c
            WHERE Id = :purchaseOrderId
        ];
        
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c, Unit_Cost__c, Ingredient__c, Ingredient__r.Name
            FROM Purchase_Order_Line_Item__c
            WHERE Purchase_Order__c = :purchaseOrderId
            ORDER BY Ingredient__r.Name
        ];
        
        return new PurchaseOrderWrapper(po, lineItems);
    }
    
    @AuraEnabled
    public static void updateLineItems(List<Purchase_Order_Line_Item__c> lineItems) {
        if (lineItems != null && !lineItems.isEmpty()) {
            update lineItems;
        }
    }
    
    public class PurchaseOrderWrapper {
        @AuraEnabled public Purchase_Order__c purchaseOrder { get; private set; }
        @AuraEnabled public List<Purchase_Order_Line_Item__c> lineItems { get; private set; }
        
        public PurchaseOrderWrapper(Purchase_Order__c po, List<Purchase_Order_Line_Item__c> items) {
            this.purchaseOrder = po;
            this.lineItems = items;
        }
    }
}
