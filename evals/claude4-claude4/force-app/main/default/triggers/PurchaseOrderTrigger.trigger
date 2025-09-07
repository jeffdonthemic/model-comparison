/**
 * @description Trigger for Purchase_Order__c object
 * @author System Administrator
 * @date 2025
 */
trigger PurchaseOrderTrigger on Purchase_Order__c (before insert, before update, after insert, after update) {
    PurchaseOrderTriggerHandler handler = new PurchaseOrderTriggerHandler();
    
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
