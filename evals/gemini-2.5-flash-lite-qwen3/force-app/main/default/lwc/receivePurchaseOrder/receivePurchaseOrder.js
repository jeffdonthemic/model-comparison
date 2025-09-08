import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getPurchaseOrderAndLineItems from '@salesforce/apex/ReceivePurchaseOrderController.getPurchaseOrderAndLineItems';
import updateLineItems from '@salesforce/apex/ReceivePurchaseOrderController.updateLineItems';

const COLUMNS = [
    { label: 'Ingredient', fieldName: 'Ingredient__r.Name', type: 'text' },
    { label: 'Quantity Ordered', fieldName: 'Quantity_Ordered__c', type: 'number' },
    { 
        label: 'Quantity Received', 
        fieldName: 'Quantity_Received__c', 
        type: 'number',
        editable: true,
        cellAttributes: { class: { fieldName: 'quantityReceivedClass' } }
    },
    { label: 'Unit Cost', fieldName: 'Unit_Cost__c', type: 'currency' }
];

export default class ReceivePurchaseOrder extends LightningElement {
    @api recordId;
    
    purchaseOrder;
    lineItems;
    columns = COLUMNS;
    showSpinner = false;
    errorMessage = '';
    successMessage = '';
    saveDisabled = true;
    originalLineItems = [];
    
    @wire(getPurchaseOrderAndLineItems, { purchaseOrderId: '$recordId' })
    wiredPurchaseOrder(result) {
        this.purchaseOrder = result;
        if (result.data) {
            this.lineItems = result.data.lineItems;
            this.originalLineItems = JSON.parse(JSON.stringify(result.data.lineItems));
            this.saveDisabled = true;
        } else if (result.error) {
            this.errorMessage = 'Error loading purchase order: ' + result.error.body.message;
        }
    }
    
    handleSave() {
        this.showSpinner = true;
        this.errorMessage = '';
        this.successMessage = '';
        
        // Get changed line items
        const changedLineItems = this.getChangedLineItems();
        
        if (changedLineItems.length === 0) {
            this.showSpinner = false;
            this.successMessage = 'No changes to save.';
            return;
        }
        
        // Validate quantities
        const validationError = this.validateQuantities(changedLineItems);
        if (validationError) {
            this.showSpinner = false;
            this.errorMessage = validationError;
            return;
        }
        
        // Update line items
        updateLineItems({ lineItems: changedLineItems })
            .then(() => {
                this.showSpinner = false;
                this.successMessage = 'Purchase order updated successfully.';
                this.saveDisabled = true;
                // Refresh the data
                return refreshApex(this.purchaseOrder);
            })
            .catch(error => {
                this.showSpinner = false;
                this.errorMessage = 'Error updating purchase order: ' + error.body.message;
            });
    }
    
    getChangedLineItems() {
        const changedItems = [];
        const currentLineItems = this.lineItems.data || [];
        
        for (let i = 0; i < currentLineItems.length; i++) {
            const currentItem = currentLineItems[i];
            const originalItem = this.originalLineItems[i];
            
            if (currentItem.Quantity_Received__c !== originalItem.Quantity_Received__c) {
                changedItems.push({
                    Id: currentItem.Id,
                    Quantity_Received__c: currentItem.Quantity_Received__c
                });
            }
        }
        
        return changedItems;
    }
    
    validateQuantities(lineItems) {
        for (let item of lineItems) {
            const lineItem = this.lineItems.data.find(li => li.Id === item.Id);
            if (lineItem) {
                const qtyOrdered = lineItem.Quantity_Ordered__c || 0;
                const qtyReceived = item.Quantity_Received__c || 0;
                
                if (qtyReceived > qtyOrdered) {
                    return `Cannot receive more than ordered for ${lineItem.Ingredient__r?.Name || 'item'}. Ordered: ${qtyOrdered}, Received: ${qtyReceived}`;
                }
                if (qtyReceived < 0) {
                    return `Quantity received cannot be negative for ${lineItem.Ingredient__r?.Name || 'item'}.`;
                }
            }
        }
        return null;
    }
    
    handleCellChange(event) {
        const { draftValues } = event.detail;
        const lineItemsData = [...this.lineItems.data];
        
        draftValues.forEach(draft => {
            const index = lineItemsData.findIndex(item => item.Id === draft.Id);
            if (index !== -1) {
                Object.assign(lineItemsData[index], draft);
            }
        });
        
        this.lineItems = { ...this.lineItems, data: lineItemsData };
        this.saveDisabled = false;
    }
}
