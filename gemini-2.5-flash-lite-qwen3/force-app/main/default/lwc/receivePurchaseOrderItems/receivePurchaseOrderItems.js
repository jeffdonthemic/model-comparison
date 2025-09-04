import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

// Import fields for Purchase Order
import PO_NAME_FIELD from '@salesforce/schema/PurchaseOrder__c.Name';
import PO_SUPPLIER_FIELD from '@salesforce/schema/PurchaseOrder__c.Supplier__r.Name';
import PO_ORDER_DATE_FIELD from '@salesforce/schema/PurchaseOrder__c.OrderDate__c';

// Import fields for Purchase Order Line Item
import LINE_ITEM_ID_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.Id';
import LINE_ITEM_INGREDIENT_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.Ingredient__r.Name';
import LINE_ITEM_QUANTITY_ORDERED_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.QuantityOrdered__c';
import LINE_ITEM_UNIT_COST_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.UnitCost__c';
import LINE_ITEM_LINE_TOTAL_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.LineItemTotal__c';
import LINE_ITEM_QUANTITY_RECEIVED_FIELD from '@salesforce/schema/PurchaseOrderLineItem__c.QuantityReceived__c';

// Import Apex method to get line items
import getPurchaseOrderLineItems from '@salesforce/apex/ReceivePurchaseOrderItemsController.getPurchaseOrderLineItems';

const PO_FIELDS = [PO_NAME_FIELD, PO_SUPPLIER_FIELD, PO_ORDER_DATE_FIELD];
const LINE_ITEM_FIELDS = [
    LINE_ITEM_ID_FIELD,
    LINE_ITEM_INGREDIENT_FIELD,
    LINE_ITEM_QUANTITY_ORDERED_FIELD,
    LINE_ITEM_UNIT_COST_FIELD,
    LINE_ITEM_LINE_TOTAL_FIELD,
    LINE_ITEM_QUANTITY_RECEIVED_FIELD
];

export default class ReceivePurchaseOrderItems extends LightningElement {
    @api recordId; // Purchase Order ID

    lineItems = [];
    error;
    successMessage;
    columns = [
        { label: 'Ingredient', fieldName: 'IngredientName', type: 'text' },
        { label: 'Quantity Ordered', fieldName: 'QuantityOrdered__c', type: 'number' },
        { label: 'Unit Cost', fieldName: 'UnitCost__c', type: 'currency' },
        { label: 'Line Total', fieldName: 'LineItemTotal__c', type: 'currency' },
        { label: 'Quantity Received', fieldName: 'QuantityReceived__c', type: 'number', editable: true }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: PO_FIELDS })
    purchaseOrder;

    @wire(getPurchaseOrderLineItems, { purchaseOrderId: '$recordId' })
    wiredLineItems({ error, data }) {
        if (data) {
            this.lineItems = data.map(item => {
                return {
                    ...item,
                    IngredientName: item.Ingredient__r ? item.Ingredient__r.Name : '',
                    QuantityReceived__c: item.QuantityReceived__c || 0
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.lineItems = [];
        }
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        // Update the lineItems array with the new draft values
        this.lineItems = this.lineItems.map(item => {
            const draftItem = draftValues.find(draft => draft.Id === item.Id);
            if (draftItem) {
                return { ...item, ...draftItem };
            }
            return item;
        });
    }

    handleReceiveItems() {
        // Validate inputs
        let isValid = true;
        const updatedLineItems = [];

        this.lineItems.forEach(item => {
            const quantityOrdered = item.QuantityOrdered__c;
            const quantityReceived = item.QuantityReceived__c || 0;
            const newQuantityReceived = (item.draftValues && item.draftValues.QuantityReceived__c !== undefined) 
                ? item.draftValues.QuantityReceived__c 
                : quantityReceived;

            if (newQuantityReceived < 0) {
                isValid = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Quantity Received cannot be negative.',
                        variant: 'error'
                    })
                );
                return;
            }

            if (newQuantityReceived > quantityOrdered) {
                isValid = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Quantity Received cannot exceed Quantity Ordered.',
                        variant: 'error'
                    })
                );
                return;
            }

            // If there's a change, prepare the record input for update
            if (newQuantityReceived !== quantityReceived) {
                updatedLineItems.push({
                    fields: {
                        Id: item.Id,
                        QuantityReceived__c: newQuantityReceived
                    }
                });
            }
        });

        if (!isValid) {
            return;
        }

        if (updatedLineItems.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Info',
                    message: 'No changes to save.',
                    variant: 'info'
                })
            );
            return;
        }

        // Update records
        const updatePromises = updatedLineItems.map(recordInput => updateRecord(recordInput));

        Promise.all(updatePromises)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Purchase order line items updated.',
                        variant: 'success'
                    })
                );
                // Refresh the data
                this.refreshData();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    refreshData() {
        // This will refresh the wire adapters
        // Note: This is a simplified approach. In a real scenario, you might want to use a more robust refresh mechanism.
        this.error = undefined;
        this.successMessage = 'Items received successfully.';
        // Clear draft values
        this.template.querySelector('lightning-datatable').draftValues = [];
    }
}
