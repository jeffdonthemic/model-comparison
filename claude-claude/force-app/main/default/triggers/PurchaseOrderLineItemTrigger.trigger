/**
 * @description       : Trigger for Purchase Order Line Item automation
 * @author            : jeffdonthemic
 * @group             : 
 * @last modified on  : 09-04-2025
 * @last modified by  : jeffdonthemic
**/
trigger PurchaseOrderLineItemTrigger on Purchase_Order_Line_Item__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        PurchaseOrderLineItemTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
