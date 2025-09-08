trigger PurchaseOrderLineItemTrigger on Purchase_Order_Line_Item__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            PurchaseOrderLineItemTriggerHandler.handleAfterInsertOrUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
