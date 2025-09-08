trigger PurchaseOrderLineItemTrigger on Purchase_Order_Line_Item__c (before insert, before update, after insert, after update, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            PurchaseOrderLineItemTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            PurchaseOrderLineItemTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PurchaseOrderLineItemTriggerHandler.handleAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            PurchaseOrderLineItemTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            PurchaseOrderLineItemTriggerHandler.handleAfterDelete(Trigger.old);
        }
    }
}
