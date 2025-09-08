import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getPurchaseOrderWithLineItems from '@salesforce/apex/PurchaseOrderReceiverController.getPurchaseOrderWithLineItems';
import updateLineItems from '@salesforce/apex/PurchaseOrderReceiverController.updateLineItems';

const COLUMNS = [
    { label: 'Ingredient', fieldName: 'Ingredient__r.Name', type: 'text' },
    { label: 'Quantity Ordered', fieldName: 'Quantity_Ordered__c', type: 'number' },
    { 
        label: 'Quantity Received', 
        fieldName: 'Quantity_Received__c', 
        type: 'number',
        editable: true,
        cellAttributes: { class: { fieldName: 'receivedCellClass' } }
    },
    { label: 'Unit Cost', fieldName: 'Unit_Cost__c', type: 'currency' },
    { label: 'Line Total', fieldName: 'Line_Total__c', type: 'currency' }
];

export default class PurchaseOrderReceiver extends LightningElement {
    @api recordId;
    
    purchaseOrder;
    lineItems = [];
    columns = COLUMNS;
    loadingError;
    errorMessage;
    showSuccessMessage = false;
    isSaving = false;
    wiredPurchaseOrderResult;
    
    @wire(getPurchaseOrderWithLineItems, { purchaseOrderId: '$recordId' })
    wiredPurchaseOrder(result) {
        this.wiredPurchaseOrderResult = result;
        if (result.data) {
            this.purchaseOrder = result.data.purchaseOrder;
            this.lineItems = this.formatLineItems(result.data.lineItems);
            this.loadingError = undefined;
        } else if (result.error) {
            this.loadingError = 'Error loading purchase order: ' + result.error.body.message;
            this.purchaseOrder = undefined;
            this.lineItems = [];
        }
    }
    
    formatLineItems(lineItems) {
        return lineItems.map(item => {
            // Add validation for received quantity
            const receivedCellClass = item.Quantity_Received__c > item.Quantity_Ordered__c ? 
                'slds-text-color_error' : '';
            
            return {
                ...item,
                receivedCellClass: receivedCellClass
            };
        });
    }
    
    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        
        // Update line items with new values
        draftValues.forEach(draft => {
            const lineItem = this.lineItems.find(item => item.Id === draft.Id);
            if (lineItem) {
                Object.assign(lineItem, draft);
                
                // Validate received quantity doesn't exceed ordered
                if (draft.Quantity_Received__c !== undefined) {
                    if (draft.Quantity_Received__c > lineItem.Quantity_Ordered__c) {
                        lineItem.receivedCellClass = 'slds-text-color_error';
                        this.errorMessage = 'Received quantity cannot exceed ordered quantity';
                    } else {
                        lineItem.receivedCellClass = '';
                        this.errorMessage = '';
                    }
                }
            }
        });
    }
    
    handleSave() {
        // Validate that no received quantities exceed ordered quantities
        const invalidItems = this.lineItems.filter(item => 
            item.Quantity_Received__c > item.Quantity_Ordered__c
        );
        
        if (invalidItems.length > 0) {
            this.errorMessage = 'Received quantity cannot exceed ordered quantity for any line item';
            return;
        }
        
        // Clear any previous error messages
        this.errorMessage = '';
        this.showSuccessMessage = false;
        this.isSaving = true;
        
        // Prepare data for update
        const lineItemsToUpdate = this.lineItems
            .filter(item => item.Quantity_Received__c !== undefined && item.Quantity_Received__c !== item.Quantity_Received__c_Old)
            .map(item => ({
                Id: item.Id,
                Quantity_Received__c: item.Quantity_Received__c
            }));
        
        if (lineItemsToUpdate.length === 0) {
            this.isSaving = false;
            this.showSuccessMessage = true;
            setTimeout(() => {
                this.showSuccessMessage = false;
            }, 3000);
            return;
        }
        
        updateLineItems({ lineItems: lineItemsToUpdate })
            .then(() => {
                this.isSaving = false;
                this.showSuccessMessage = true;
                
                // Refresh the data
                return refreshApex(this.wiredPurchaseOrderResult);
            })
            .then(() => {
                // Clear success message after 3 seconds
                setTimeout(() => {
                    this.showSuccessMessage = false;
                }, 3000);
            })
            .catch(error => {
                this.isSaving = false;
                this.errorMessage = 'Error saving receipts: ' + error.body.message;
            });
    }
}
