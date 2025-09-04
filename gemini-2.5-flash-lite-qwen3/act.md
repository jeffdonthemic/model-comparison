# Implementation Details (ACT Mode)

This document outlines the implementation steps and files created during the ACT mode for the purchasing application.

## 1. Custom Objects and Fields

### 1.1. Purchase Order (`PurchaseOrder__c`) Object

*   **Object Definition:**
    *   File: `force-app/main/default/objects/PurchaseOrder__c/PurchaseOrder__c.object-meta.xml`
*   **Fields:**
    *   `Supplier__c` (Lookup to `Account`)
        *   File: `force-app/main/default/objects/PurchaseOrder__c/fields/Supplier__c.field-meta.xml`
    *   `OrderDate__c` (Date)
        *   File: `force-app/main/default/objects/PurchaseOrder__c/fields/OrderDate__c.field-meta.xml`
    *   `Status__c` (Picklist)
        *   File: `force-app/main/default/objects/PurchaseOrder__c/fields/Status__c.field-meta.xml`
    *   `Approved__c` (Checkbox)
        *   File: `force-app/main/default/objects/PurchaseOrder__c/fields/Approved__c.field-meta.xml`

### 1.2. Purchase Order Line Item (`PurchaseOrderLineItem__c`) Object

*   **Object Definition:**
    *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/PurchaseOrderLineItem__c.object-meta.xml`
*   **Fields:**
    *   `PurchaseOrder__c` (Master-Detail to `PurchaseOrder__c`)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/PurchaseOrder__c.field-meta.xml`
    *   `Ingredient__c` (Lookup to `Ingredient__c`)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/Ingredient__c.field-meta.xml`
    *   `QuantityOrdered__c` (Number)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/QuantityOrdered__c.field-meta.xml`
    *   `QuantityReceived__c` (Number)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/QuantityReceived__c.field-meta.xml`
    *   `UnitCost__c` (Currency)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/UnitCost__c.field-meta.xml`
    *   `LineItemTotal__c` (Formula - Currency)
        *   File: `force-app/main/default/objects/PurchaseOrderLineItem__c/fields/LineItemTotal__c.field-meta.xml`

## 2. Validation Rule

*   **Validation Rule:**
    *   Name: `Status_Requires_Approval`
    *   Description: PO Status can only be set to 'Ordered' if the PO is approved.
    *   File: `force-app/main/default/objects/PurchaseOrder__c/validationRules/Status_Requires_Approval.validationRule-meta.xml`

## 3. Lightning Web Component (LWC)

*   **Component Name:** `receivePurchaseOrderItems`
*   **Files:**
    *   HTML: `force-app/main/default/lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.html`
    *   JavaScript: `force-app/main/default/lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.js`
    *   Meta XML: `force-app/main/default/lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.js-meta.xml`

## 4. Apex Class

*   **Class Name:** `ReceivePurchaseOrderItemsController`
*   **Purpose:** To support the LWC by providing data.
*   **Files:**
    *   Class: `force-app/main/default/classes/ReceivePurchaseOrderItemsController.cls`
    *   Meta XML: `force-app/main/default/classes/ReceivePurchaseOrderItemsController.cls-meta.xml`

## 5. Flows

### 5.1. PO Approval Flow

*   **Flow Name:** `PO_Approval_Flow`
*   **Purpose:** To update PO Status to Approved when Approved checkbox is checked.
*   **File:** `force-app/main/default/flows/PO_Approval_Flow.flow-meta.xml`

### 5.2. PO Status Update Flow

*   **Flow Name:** `PO_Status_Update_Flow`
*   **Purpose:** To update PO Status based on line item receipt status.
*   **File:** `force-app/main/default/flows/PO_Status_Update_Flow.flow-meta.xml`

## 6. Apex Trigger

*   **Trigger Name:** `PurchaseOrderLineItemTrigger`
*   **Purpose:** To update `Ingredient__c.In_Stock__c` based on `PurchaseOrderLineItem__c.QuantityReceived__c`.
*   **Files:**
    *   Trigger: `force-app/main/default/triggers/PurchaseOrderLineItemTrigger.trigger`
    *   Meta XML: `force-app/main/default/triggers/PurchaseOrderLineItemTrigger.trigger-meta.xml`

## 7. Summary of Implementation Steps

1.  Created `PurchaseOrder__c` object and its fields.
2.  Created `PurchaseOrderLineItem__c` object and its fields.
3.  Created a validation rule on `PurchaseOrder__c` to enforce the 'Ordered' status requirement.
4.  Developed the `receivePurchaseOrderItems` LWC with HTML, JavaScript, and meta XML files.
5.  Created the `ReceivePurchaseOrderItemsController` Apex class to support the LWC.
6.  Implemented the `PO_Approval_Flow` to update PO status on approval.
7.  Implemented the `PO_Status_Update_Flow` to update PO status based on line item receipt.
8.  Implemented the `PurchaseOrderLineItemTrigger` to update ingredient inventory.
