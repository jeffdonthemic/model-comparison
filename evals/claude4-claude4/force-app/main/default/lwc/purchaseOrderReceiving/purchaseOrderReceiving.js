import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getPurchaseOrderWithLineItems from '@salesforce/apex/PurchaseOrderReceivingController.getPurchaseOrderWithLineItems';
import updateLineItemQuantities from '@salesforce/apex/PurchaseOrderReceivingController.updateLineItemQuantities';

export default class PurchaseOrderReceiving extends LightningElement {
    @api purchaseOrderId;
    @track purchaseOrder = {};
    @track lineItems = [];
    @track isLoading = false;
    @track hasErrors = false;
    @track errorMessage = '';

    wiredPurchaseOrderResult;

    @wire(getPurchaseOrderWithLineItems, { purchaseOrderId: '$purchaseOrderId' })
    wiredPurchaseOrder(result) {
        this.wiredPurchaseOrderResult = result;
        if (result.data) {
            this.purchaseOrder = result.data.purchaseOrder;
            this.lineItems = result.data.lineItems.map(item => ({
                ...item,
                originalQuantityReceived: item.QuantityReceived || 0
            }));
            this.hasErrors = false;
            this.errorMessage = '';
        } else if (result.error) {
            this.hasErrors = true;
            this.errorMessage = 'Error loading purchase order: ' + result.error.body.message;
            console.error('Error loading purchase order:', result.error);
        }
    }

    get columns() {
        return [
            {
                label: 'Ingredient',
                fieldName: 'ingredientName',
                type: 'text',
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Quantity Ordered',
                fieldName: 'QuantityOrdered',
                type: 'number',
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Quantity Received',
                fieldName: 'QuantityReceived',
                type: 'number',
                editable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Unit Cost',
                fieldName: 'UnitCost',
                type: 'currency',
                cellAttributes: { alignment: 'left' }
            }
        ];
    }

    get hasData() {
        return this.lineItems && this.lineItems.length > 0;
    }

    get purchaseOrderNumber() {
        return this.purchaseOrder?.Name || '';
    }

    get supplierName() {
        return this.purchaseOrder?.Supplier__r?.Name || '';
    }

    get orderStatus() {
        return this.purchaseOrder?.Status__c || '';
    }

    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        
        // Validate quantities
        for (let draft of draftValues) {
            const lineItem = this.lineItems.find(item => item.Id === draft.Id);
            if (lineItem && draft.QuantityReceived > lineItem.QuantityOrdered) {
                this.showToast('Error', 'Quantity received cannot exceed quantity ordered', 'error');
                return;
            }
            if (draft.QuantityReceived < 0) {
                this.showToast('Error', 'Quantity received cannot be negative', 'error');
                return;
            }
        }

        // Update line items with draft values
        this.lineItems = this.lineItems.map(item => {
            const draft = draftValues.find(d => d.Id === item.Id);
            if (draft) {
                return { ...item, ...draft };
            }
            return item;
        });
    }

    handleSave(event) {
        this.isLoading = true;
        const draftValues = event.detail.draftValues;
        
        // Prepare updates only for changed items
        const updates = [];
        for (let draft of draftValues) {
            const lineItem = this.lineItems.find(item => item.Id === draft.Id);
            if (lineItem && draft.Quantity_Received__c !== lineItem.originalQuantityReceived) {
                updates.push({
                    Id: draft.Id,
                    Quantity_Received__c: draft.Quantity_Received__c || 0
                });
            }
        }

        if (updates.length === 0) {
            this.isLoading = false;
            this.showToast('Info', 'No changes to save', 'info');
            return;
        }

        updateLineItemQuantities({ lineItemUpdates: updates })
            .then(() => {
                this.showToast('Success', 'Quantities updated successfully', 'success');
                
                // Clear draft values
                this.template.querySelector('lightning-datatable').draftValues = [];
                
                // Refresh data
                return refreshApex(this.wiredPurchaseOrderResult);
            })
            .catch(error => {
                console.error('Error updating quantities:', error);
                this.showToast('Error', 'Error updating quantities: ' + error.body.message, 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCancel() {
        // Clear draft values
        this.template.querySelector('lightning-datatable').draftValues = [];
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}
