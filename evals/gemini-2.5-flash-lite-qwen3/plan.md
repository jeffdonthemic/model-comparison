# Salesforce Purchasing and Inventory System - Plan

This document outlines the plan to develop a Salesforce application for a commercial baking company's purchasing and inventory system.

## Phase 1: Data Model and Fields

1.  **Create Custom Objects:**
    *   `Purchase_Order__c`
    *   `Purchase_Order_Line_Item__c` (child of `Purchase_Order__c`)
    *   `Ingredient__c`
    *   Utilize standard `Account` object for suppliers.

2.  **Define Fields:**
    *   `Purchase_Order__c`:
        *   `Approved__c` (Checkbox)
        *   `Status__c` (Picklist: Draft, Submitted, Approved, Partially Received, Received)
        *   Standard purchasing fields (e.g., Unit Cost, Notes, Expected Delivery Date)
    *   `Purchase_Order_Line_Item__c`:
        *   `Quantity_Ordered__c` (Number)
        *   `Quantity_Received__c` (Number)
        *   Standard purchasing fields (e.g., Unit Cost, Notes)
    *   `Ingredient__c`:
        *   `In_Stock__c` (Number)
        *   `On_Order__c` (Number)
        *   Potentially other relevant fields.

## Phase 2: Business Logic (Apex)

1.  **Automation Implementation:**
    *   When `Approved__c` is checked on `Purchase_Order__c`, update `Status__c` to "Approved".
    *   Enforce that `Status__c` can only be manually changed to "Submitted" if `Approved__c` is TRUE.
    *   When `Purchase_Order__c.Status__c` is set to "Submitted", update `Ingredient__c.On_Order__c` for related line items.
    *   When `Purchase_Order_Line_Item__c.Quantity_Received__c` is updated, calculate the delta and update `Ingredient__c.In_Stock__c` and `Ingredient__c.On_Order__c`.
    *   Update `Purchase_Order__c.Status__c` to "Partially Received" or "Received" based on the total received quantities across line items.

## Phase 3: User Interface

1.  **Lightning Web Component (LWC):**
    *   Accepts a Purchase Order ID.
    *   Loads and displays related `Purchase_Order_Line_Item__c` records.
    *   Provides input fields for users to update `Quantity_Received__c`.
    *   Includes validation to prevent receiving more than `Quantity_Ordered__c`.
    *   On submit, applies updates and triggers the relevant business logic.
    *   Displays success or error messages to the user.
2.  **Apex Controllers:**
    *   Create necessary Apex classes to support the LWC's functionality (e.g., for data retrieval and updates).

## Phase 4: Security and App Shell

1.  **Permission Set:**
    *   Create a permission set that grants administrators access to manage the new custom objects and the LWC.
    *   Assign this permission set to the Admin profile.
2.  **Lightning App:**
    *   Create a new Lightning App.
    *   Add tabs to the app for: Purchase Orders, Purchase Order Line Items, Ingredients, Suppliers (Accounts), and the custom LWC.

## Phase 5: Deployment and Testing

1.  **Deployment:**
    *   Deploy all created metadata (objects, fields, Apex classes, LWC, permission sets, app, tabs) to a scratch org using Salesforce DX commands.
2.  **Testing:**
    *   Write Apex unit tests to cover the business logic implemented in Phase 2.
    *   Write Jest tests for the LWC developed in Phase 3.
    *   Deploy the tests to the scratch org.
    *   Run all tests and report the code coverage percentage.

## Phase 6: Final Output

1.  **act.md:**
    *   Create an `act.md` file detailing the successfully built application, including any components that may not have been fully implemented or encountered issues.
