# Purchasing Application Plan

## Overview
This plan outlines the steps to create a purchasing application for a commercial baking company using Salesforce. The application will focus on purchase order creation and tracking, utilizing existing objects like `Ingredient__c` and the standard `Account` object.

## Implementation Steps

1. **Create the Purchase Order Object**:
   - Add an **Approved__c** checkbox field to indicate when the purchase order is approved.
   - Define the **Status** field with the following options:
     - Draft
     - Approved
     - Sent
     - Partially Received
     - Fully Received
     - Cancelled

2. **Define Fields for the Purchase Order Line Items Object**:
   - Create fields such as:
     - Product (lookup to Ingredient__c)
     - Quantity
     - Unit Price
     - Total Price (calculated field)

3. **Implement Logic for Status Updates**:
   - Ensure that when line items are marked updated, the status of the purchase order changes accordingly.

4. **Develop a Lightning Web Component**:
   - Create a component to handle quantities for multiple items.

5. **Implement Purchase Order Creation and Tracking Functionality**:
   - Ensure users can create and track purchase orders through the standard Salesforce UI.

## Todo List
- [ ] Define fields for the **Purchase Order** object:
  - Order Number
  - Vendor (lookup to Account)
  - Order Date
  - Status (with defined options)
  - Approved__c (checkbox)
  - Total Amount
- [ ] Define fields for the **Purchase Order Line Items** object:
  - Product (lookup to Ingredient__c)
  - Quantity
  - Unit Price
  - Total Price
- [ ] Implement logic to update the purchase order status based on line item updates.
- [ ] Develop a Lightning Web Component to handle quantities for multiple items.
- [ ] Implement purchase order creation and tracking functionality.
