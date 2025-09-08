trigger PurchaseOrderTrigger on Purchase_Order__c (before insert, before update, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            PurchaseOrderTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            PurchaseOrderTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        PurchaseOrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
