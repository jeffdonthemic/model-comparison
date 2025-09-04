/**
 * @description       : 
 * @author            : liquidlogixsolutions
 * @group             : 
 * @last modified on  : 09-03-2025
 * @last modified by  : liquidlogixsolutions
**/
public with sharing class ReceivePurchaseOrderItemsController {
    
    @AuraEnabled(cacheable=true)
    public static List<PurchaseOrderLineItem__c> getPurchaseOrderLineItems(Id purchaseOrderId) {
        List<PurchaseOrderLineItem__c> lineItems = [
            SELECT Id, 
                   Ingredient__r.Name, 
                   QuantityOrdered__c, 
                   UnitCost__c, 
                   LineItemTotal__c, 
                   QuantityReceived__c
            FROM PurchaseOrderLineItem__c 
            WHERE PurchaseOrder__c = :purchaseOrderId
        ];
        
        return lineItems;
    }
}
