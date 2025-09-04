import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getLineItems from '@salesforce/apex/PurchaseOrderReceivingController.getLineItems';
import updateLineItems from '@salesforce/apex/PurchaseOrderReceivingController.updateLineItems';

export default class PurchaseOrderReceiving extends LightningElement {
    @api recordId;
    @track lineItems = [];
    @track isLoading = false;
    wiredLineItemsResult;

    @wire(getLineItems, { purchaseOrderId: '$recordId' })
    wiredLineItems(result) {
        this.wiredLineItemsResult = result;
        if (result.data) {
            this.lineItems = result.data.map(item => ({
                ...item,
                quantityToReceive: item.Quantity_Received__c || 0
            }));
        } else if (result.error) {
            this.showToast('Error', 'Error loading line items: ' + result.error.body.message, 'error');
        }
    }

    handleQuantityChange(event) {
        const itemId = event.target.dataset.id;
        const newQuantity = parseFloat(event.target.value) || 0;
        
        this.lineItems = this.lineItems.map(item => {
            if (item.Id === itemId) {
                return { ...item, quantityToReceive: newQuantity };
            }
            return item;
        });
    }

    async handleSave() {
        this.isLoading = true;
        
        try {
            const itemsToUpdate = this.lineItems.map(item => ({
                Id: item.Id,
                Quantity_Received__c: item.quantityToReceive
            }));

            await updateLineItems({ lineItems: itemsToUpdate });
            
            this.showToast('Success', 'Line items updated successfully', 'success');
            
            // Refresh the data
            await refreshApex(this.wiredLineItemsResult);
            
            // Close the modal or navigate back
            this.dispatchEvent(new CustomEvent('close'));
            
        } catch (error) {
            this.showToast('Error', 'Error updating line items: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    get hasLineItems() {
        return this.lineItems && this.lineItems.length > 0;
    }
}
