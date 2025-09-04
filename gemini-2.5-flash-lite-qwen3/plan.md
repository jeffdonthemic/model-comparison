# Plan for Purchasing Application in Salesforce

This document outlines the plan to create a purchasing application for a commercial baking company within Salesforce.

## 1. Requirements

Based on the user's input, the key requirements are:

*   **Core Functionalities:**
    *   Inventory management
    *   Order tracking
*   **Data:**
    *   Ingredient and purchase order information.
    *   Use the standard `Account` object for suppliers.
    *   No recipe management is required.
*   **User Interface:**
    *   Users will create and edit purchase orders and purchase order line items using the standard Salesforce interface.
    *   A Lightning Web Component (LWC) is needed to allow users to receive quantities for multiple line items at once.
*   **Business Logic:**
    *   Specific business logic for status updates and inventory management.

## 2. Salesforce Object Data Model

We will create two new custom objects: `PurchaseOrder__c` and `PurchaseOrderLineItem__c`.

### 2.1. Purchase Order (`PurchaseOrder__c`) Object

*   **API Name:** `PurchaseOrder__c`
*   **Label:** `Purchase Order`
*   **Plural Label:** `Purchase Orders`
*   **Fields:**
    *   `Name` (Text) - Standard Name field.
    *   `Supplier__c` (Lookup to `Account.Id`) - To link the PO to a supplier account.
    *   `OrderDate__c` (Date) - The date the order was placed.
    *   `Status__c` (Picklist) - To track the PO's lifecycle. Values: 'Draft', 'Ordered', 'Approved', 'Partially Received', 'Received', 'Cancelled'. Default: 'Draft'.
    *   `Approved__c` (Checkbox) - To indicate if the PO has been approved.
    *   `TotalAmount__c` (Currency) - Roll-Up Summary field from `PurchaseOrderLineItem__c.LineItemTotal__c`.

### 2.2. Purchase Order Line Item (`PurchaseOrderLineItem__c`) Object

*   **API Name:** `PurchaseOrderLineItem__c`
*   **Label:** `Purchase Order Line Item`
*   **Plural Label:** `Purchase Order Line Items`
*   **Fields:**
    *   `Name` (Text) - Standard Name field.
    *   `PurchaseOrder__c` (Master-Detail relationship to `PurchaseOrder__c`) - To link the line item to its parent PO.
    *   `Ingredient__c` (Lookup to `Ingredient__c.Id`) - To link the line item to an ingredient.
    *   `QuantityOrdered__c` (Number) - The quantity of the ingredient ordered.
    *   `QuantityReceived__c` (Number) - The quantity of the ingredient received.
    *   `UnitCost__c` (Currency) - The cost per unit of the ingredient.
    *   `LineItemTotal__c` (Formula - Currency) - Calculated as `QuantityOrdered__c * UnitCost__c`.

## 3. User Interface

### 3.1. Standard Salesforce Interface

Users will use the standard Salesforce UI to create, view, and edit `PurchaseOrder__c` and `PurchaseOrderLineItem__c` records. This includes standard page layouts, list views, and related lists.

### 3.2. Lightning Web Component (LWC): `receivePurchaseOrderItems`

A custom LWC will be created to facilitate the receiving process for multiple line items.

*   **Purpose:** Allow users to select a Purchase Order and input the `Quantity Received` for each of its line items in a single interface.
*   **Location:** Will be placed on the `PurchaseOrder__c` record page.
*   **Functionality:**
    *   Display PO details (PO Number, Supplier, Order Date).
    *   Display a list of line items with columns: Ingredient Name, Quantity Ordered, Unit Cost, Line Total, Quantity Received (editable input field).
    *   Include a "Receive Items" button.
    *   When the button is clicked:
        *   Validate that `Quantity Received` is not negative and does not exceed `Quantity Ordered`.
        *   Update the `QuantityReceived__c` field on the relevant `PurchaseOrderLineItem__c` records.
        *   Display success or error messages to the user.
        *   Refresh the component to show updated data.

## 4. Automation Logic

### 4.1. Purchase Order Status Management

*   **Validation Rule:**
    *   A validation rule on `PurchaseOrder__c` will prevent the `Status__c` from being set to 'Ordered' unless the `Approved__c` checkbox is true.
*   **Flow 1: PO Approval Flow (`PO_Approval_Flow`):**
    *   **Trigger:** Record-triggered Flow on `PurchaseOrder__c` object.
    *   **Entry Criteria:** `Approved__c` field is changed to TRUE.
    *   **Actions:** Update `PurchaseOrder__c.Status__c` to 'Approved'.
*   **Flow 2: PO Receipt Status Flow (`PO_Status_Update_Flow`):**
    *   **Trigger:** Record-triggered Flow on `PurchaseOrderLineItem__c` object.
    *   **Entry Criteria:** `QuantityReceived__c` is changed.
    *   **Logic:**
        *   Get all `PurchaseOrderLineItem__c` records related to the current PO.
        *   Check if all `QuantityReceived__c` >= `QuantityOrdered__c`. If yes, update parent PO `Status__c` to 'Received'.
        *   Else, check if any `QuantityReceived__c` > 0. If yes, update parent PO `Status__c` to 'Partially Received'.

### 4.2. Inventory Management

*   **Apex Trigger: `PurchaseOrderLineItemTrigger`**
    *   **Trigger:** `after update` on `PurchaseOrderLineItem__c`.
    *   **Logic:**
        *   For each updated `PurchaseOrderLineItem__c`, identify the related `Ingredient__c`.
        *   Query all `PurchaseOrderLineItem__c` records for that specific `Ingredient__c` where `QuantityReceived__c` > 0.
        *   Sum up the `QuantityReceived__c` for that ingredient.
        *   Update the `Ingredient__c.In_Stock__c` field with this sum.
        *   (Consider handling bulk updates efficiently and potential exceptions).

## 5. Implementation Steps

1.  **Create Custom Objects and Fields:**
    *   Create `PurchaseOrder__c` object and its fields.
    *   Create `PurchaseOrderLineItem__c` object and its fields.
2.  **Create Validation Rule:**
    *   Create the validation rule on `PurchaseOrder__c` to enforce the 'Ordered' status requirement.
3.  **Develop Lightning Web Component:**
    *   Create `receivePurchaseOrderItems` LWC with HTML, JavaScript, and meta XML files.
    *   Create `ReceivePurchaseOrderItemsController` Apex class to support the LWC.
4.  **Implement Flows:**
    *   Create `PO_Approval_Flow` to update PO status on approval.
    *   Create `PO_Status_Update_Flow` to update PO status based on line item receipt.
5.  **Implement Apex Trigger:**
    *   Create `PurchaseOrderLineItemTrigger` to update ingredient inventory.
6.  **Testing:**
    *   Deploy all components to a Salesforce org.
    *   Create test data (Ingredients, Accounts, Purchase Orders, Line Items).
    *   Test the standard UI for creating/editing POs and line items.
    *   Test the LWC for receiving items.
    *   Test the validation rule, flows, and trigger to ensure they work as expected.
    *   Perform user acceptance testing.

## 6. Files Created

The implementation will result in the following files being created in the `force-app/main/default` directory:

*   `objects/PurchaseOrder__c/PurchaseOrder__c.object-meta.xml`
*   `objects/PurchaseOrder__c/fields/Supplier__c.field-meta.xml`
*   `objects/PurchaseOrder__c/fields/OrderDate__c.field-meta.xml`
*   `objects/PurchaseOrder__c/fields/Status__c.field-meta.xml`
*   `objects/PurchaseOrder__c/fields/Approved__c.field-meta.xml`
*   `objects/PurchaseOrder__c/validationRules/Status_Requires_Approval.validationRule-meta.xml`
*   `objects/PurchaseOrderLineItem__c/PurchaseOrderLineItem__c.object-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/PurchaseOrder__c.field-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/Ingredient__c.field-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/QuantityOrdered__c.field-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/QuantityReceived__c.field-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/UnitCost__c.field-meta.xml`
*   `objects/PurchaseOrderLineItem__c/fields/LineItemTotal__c.field-meta.xml`
*   `lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.html`
*   `lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.js`
*   `lwc/receivePurchaseOrderItems/receivePurchaseOrderItems.js-meta.xml`
*   `classes/ReceivePurchaseOrderItemsController.cls`
*   `classes/ReceivePurchaseOrderItemsController.cls-meta.xml`
*   `flows/PO_Approval_Flow.flow-meta.xml`
*   `flows/PO_Status_Update_Flow.flow-meta.xml`
*   `triggers/PurchaseOrderLineItemTrigger.trigger`
*   `triggers/PurchaseOrderLineItemTrigger.trigger-meta.xml`
