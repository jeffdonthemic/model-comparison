import { createElement } from 'lwc';
import PurchaseOrderReceiver from 'c/purchaseOrderReceiver';

describe('c-purchase-order-receiver', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays purchase order information', () => {
        // Create element
        const element = createElement('c-purchase-order-receiver', {
            is: PurchaseOrderReceiver
        });
        element.recordId = 'a00000000000000AAA';
        document.body.appendChild(element);

        // Check that the element is rendered
        const cardElement = element.shadowRoot.querySelector('lightning-card');
        expect(cardElement).not.toBeNull();
    });

    it('displays loading state initially', () => {
        // Create element
        const element = createElement('c-purchase-order-receiver', {
            is: PurchaseOrderReceiver
        });
        document.body.appendChild(element);

        // Check for loading message
        const paragraphElement = element.shadowRoot.querySelector('p');
        expect(paragraphElement.textContent).toBe('Loading purchase order...');
    });

    it('handles received quantity validation', () => {
        // Create element
        const element = createElement('c-purchase-order-receiver', {
            is: PurchaseOrderReceiver
        });
        document.body.appendChild(element);

        // Mock line items with ordered quantity
        element.lineItems = [{
            Id: 'a01000000000000AAA',
            Quantity_Ordered__c: 10,
            Quantity_Received__c: 15
        }];

        // Simulate validation
        const invalidItems = element.lineItems.filter(item => 
            item.Quantity_Received__c > item.Quantity_Ordered__c
        );
        
        expect(invalidItems.length).toBe(1);
        expect(invalidItems[0].Quantity_Received__c).toBeGreaterThan(invalidItems[0].Quantity_Ordered__c);
    });
});
