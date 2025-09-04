import { LightningElement, api, track } from 'lwc';

export default class PurchaseOrderComponent extends LightningElement {
    @track lineItems = [{ id: 1, product: '', quantity: 0, unitPrice: 0, totalPrice: 0 }];

    addLineItem() {
        this.lineItems = [...this.lineItems, { id: this.lineItems.length + 1, product: '', quantity: 0, unitPrice: 0, totalPrice: 0 }];
    }

    removeLineItem(event) {
        const id = event.target.dataset.id;
        this.lineItems = this.lineItems.filter(item => item.id != id);
    }

    updateLineItem(event) {
        const id = event.target.dataset.id;
        const field = event.target.dataset.field;
        const value = event.target.value;

        this.lineItems = this.lineItems.map(item => {
            if (item.id == id) {
                return { ...item, [field]: value };
            }
            return item;
        });
    }
}
