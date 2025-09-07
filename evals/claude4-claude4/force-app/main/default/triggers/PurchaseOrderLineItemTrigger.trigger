/**
 * @description Trigger for Purchase_Order_Line_Item__c object
 * @author System Administrator
 * @date 2025
 */
trigger PurchaseOrderLineItemTrigger on Purchase_Order_Line_Item__c (before insert, before update, after insert, after update) {
    PurchaseOrderLineItemTriggerHandler handler = new PurchaseOrderLineItemTriggerHandler();
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            handler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
