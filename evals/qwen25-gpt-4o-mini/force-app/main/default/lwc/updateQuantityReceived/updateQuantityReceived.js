import { LightningElement, track, api } from 'lwc';
import updateQuantity from '@salesforce/apex/UpdateQuantity.updateQuantity'; // Replace with actual Apex method

export default class UpdateQuantityReceived extends LightningElement {
    @api recordId; // The Purchase Order ID
    @track quantityReceived = 0;
    @track errorMessage = '';

    handleInputChange(event) {
        this.quantityReceived = event.target.value;
    }

    handleSubmit() {
        if (this.quantityReceived < 0) {
            this.errorMessage = 'Quantity received cannot be negative.';
            return;
        }

        // Call Apex method to update the quantity
        updateQuantity({ lineItemId: this.recordId, quantity: this.quantityReceived })
            .then(() => {
                this.errorMessage = '';
                // Optionally, show success message or refresh data
            })
            .catch(error => {
                this.errorMessage = 'Error updating quantity: ' + error.body.message;
            });
    }
}
