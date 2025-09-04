/**
 * @description       : 
 * @author            : liquidlogixsolutions
 * @group             : 
 * @last modified on  : 09-02-2025
 * @last modified by  : liquidlogixsolutions
**/
public with sharing class PurchaseOrderReceivingController {
    
    @AuraEnabled(cacheable=true)
    public static List<Purchase_Order_Line_Item__c> getLineItems(Id purchaseOrderId) {
        try {
            return [
                SELECT Id, Name, Ingredient__c, Ingredient__r.Name, 
                       Quantity_Ordered__c, Quantity_Received__c, Unit_Price__c, Line_Total__c
                FROM Purchase_Order_Line_Item__c 
                WHERE Purchase_Order__c = :purchaseOrderId
                ORDER BY Ingredient__r.Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving line items: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateLineItems(List<Purchase_Order_Line_Item__c> lineItems) {
        try {
            if (lineItems != null && !lineItems.isEmpty()) {
                update lineItems;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error updating line items: ' + e.getMessage());
        }
    }
}
