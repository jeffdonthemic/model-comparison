public with sharing class UpdateQuantity {
    @AuraEnabled
    public static void updateQuantity(Id lineItemId, Decimal quantity) {
        Purchase_Order_Line_Item__c lineItem = [SELECT Id, Quantity_Ordered__c FROM Purchase_Order_Line_Item__c WHERE Id = :lineItemId LIMIT 1];
        
        if (quantity > lineItem.Quantity_Ordered__c) {
            throw new AuraHandledException('Quantity received cannot exceed quantity ordered.');
        }
        
        lineItem.Quantity_Received__c = quantity;
        update lineItem;
    }
}
