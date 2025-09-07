# Purchasing and Inventory System Implementation Plan

## Project Overview
Complete Salesforce application for a commercial baking company's purchasing and inventory management system.

## Current State Analysis
**✅ Already Implemented:**
- Salesforce DX project structure with API version 64.0
- `Ingredient__c` custom object with required fields:
  - `In_Stock__c` (Number, default 0)
  - `On_Order__c` (Number, default 0)
  - Additional fields: `Category__c`, `Cost_per_Unit__c`, `Description__c`, `Unit_of_Purchase__c`
- Admin profile with permissions for Ingredient object
- Basic layout and tab for Ingredients

## Implementation Plan

### Phase 1: Data Model Creation
**Purchase_Order__c Object:**
- `Approved__c` (Checkbox)
- `Status__c` (Picklist): Draft, Submitted, Approved, Partially Received, Received
- `Order_Date__c` (Date)
- `Expected_Delivery_Date__c` (Date)
- `Total_Amount__c` (Currency)
- `Notes__c` (Long Text Area)
- `Supplier__c` (Lookup to Account)

**Purchase_Order_Line_Item__c Object:**
- Master-Detail to Purchase_Order__c
- `Ingredient__c` (Lookup to Ingredient__c)
- `Quantity_Ordered__c` (Number)
- `Quantity_Received__c` (Number, default 0)
- `Unit_Cost__c` (Currency)
- `Line_Total__c` (Formula: Quantity_Ordered__c * Unit_Cost__c)

### Phase 2: Business Logic (Apex Triggers)
**Purchase Order Trigger Logic:**
1. When `Approved__c` = true → Set `Status__c` = "Approved"
2. Validation: Only allow `Status__c` = "Submitted" if `Approved__c` = true
3. When Status changes to "Submitted" → Update related Ingredient `On_Order__c` quantities

**Line Item Trigger Logic:**
1. When `Quantity_Received__c` changes → Update Ingredient `In_Stock__c` and `On_Order__c`
2. After line item updates → Recalculate Purchase Order status:
   - Any received > 0 but totals don't match → "Partially Received"
   - Total received = total ordered → "Received"

### Phase 3: Lightning Web Component
**Component: `purchaseOrderReceiving`**
- Input: Purchase Order ID
- Display: All related line items in a data table
- Functionality: 
  - Editable `Quantity_Received__c` fields
  - Validation: Cannot exceed `Quantity_Ordered__c`
  - Bulk update capability
  - Success/error messaging

### Phase 4: Lightning App & Navigation
**App: "Purchasing Management"**
- Purchase Orders tab
- Purchase Order Line Items tab  
- Ingredients tab
- Suppliers tab (Account with custom list view)
- PO Receiving tab (custom tab for the LWC)

### Phase 5: Security & Permissions
**Permission Sets:**
- `PurchApp_Admin_Full` - Complete access to all purchasing objects
- `PurchApp_Receiving_Execute` - Access to receiving component and related objects
- `PurchApp_ApexExec_Purchasing` - Execute permissions for trigger classes

### Phase 6: Testing & Deployment
- Apex test classes for all trigger logic
- LWC Jest tests for component functionality
- Deploy to scratch org
- Validation testing

## Requirements Clarifications
- No Supplier management functionality beyond basic Account lookup
- No approval processes - use simple `Approved__c` checkbox
- No minimum stock levels or reorder points for ingredients
- No cost tracking beyond basic unit cost
- No multi-locations
- No integrations with other systems

## Technical Implementation Details
**Trigger Architecture:**
- `PurchaseOrderTrigger` with `PurchaseOrderTriggerHandler` class
- `PurchaseOrderLineItemTrigger` with `PurchaseOrderLineItemTriggerHandler` class
- Bulkified logic following Salesforce best practices
- Proper exception handling

**Component Architecture:**
- Wire service to load Purchase Order and Line Items
- Lightning Data Service for record updates
- Custom Apex methods for bulk operations
- Proper error handling and user feedback
