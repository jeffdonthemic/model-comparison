# Salesforce Purchasing and Inventory System - Implementation Plan

## Overview
This document outlines the implementation plan for a complete Salesforce purchasing and inventory system for a commercial baking company. The system will include Purchase Orders, Purchase Order Line Items, and integration with the existing Ingredient inventory management.

## Current State Analysis
- Existing Ingredient__c object with fields: Category__c, Cost_per_Unit__c, Description__c, In_Stock__c, On_Order__c, Unit_of_Purchase__c
- Existing layout, tab, and Admin profile permissions for Ingredient__c
- No existing Purchase Order or Purchase Order Line Item objects
- No existing Apex classes, triggers, or LWC components

## Implementation Components

### 1. Object Model
#### Purchase_Order__c (New Custom Object)
- Approved__c (Checkbox)
- Status__c (Picklist): Draft, Submitted, Approved, Partially Received, Received
- Supplier__c (Lookup to Account)
- Expected_Delivery_Date__c (Date)
- Notes__c (Text Area)
- Standard fields for tracking and reporting

#### Purchase_Order_Line_Item__c (New Custom Object)
- Purchase_Order__c (Master-Detail to Purchase_Order__c)
- Ingredient__c (Lookup to Ingredient__c)
- Quantity_Ordered__c (Number)
- Quantity_Received__c (Number)
- Unit_Cost__c (Currency)
- Line_Total__c (Formula: Quantity_Ordered__c * Unit_Cost__c)

#### Ingredient__c (Enhancements)
- Verify existing fields meet requirements
- Add any missing standard purchasing fields

### 2. Business Logic Implementation
#### Trigger Logic
1. Purchase Order Approval Workflow
   - When Approved__c is checked → Status__c = "Approved"
   - Status__c can only be set to "Submitted" when Approved__c = TRUE

2. Order Submission Processing
   - When Status__c changes to "Submitted":
     - For each Line Item: Increase Ingredient__c.On_Order__c by Quantity_Ordered__c

3. Receipt Processing
   - When Quantity_Received__c changes:
     - Calculate delta (new - old)
     - Update Ingredient__c:
       - In_Stock__c += delta
       - On_Order__c -= delta
   - Update Purchase Order Status:
     - If partial receipt → Status__c = "Partially Received"
     - If fully received → Status__c = "Received"

### 3. User Interface
#### Lightning Web Component: c/purchase-order-receiver
- Accepts Purchase Order ID as input
- Displays related Line Items in editable table
- Validates receipt quantities (cannot exceed ordered)
- Submit button to process receipts
- Success/error messaging

#### Lightning App: PurchasingApp
- Tabs for: Purchase Orders, Purchase Order Line Items, Ingredients, Suppliers
- Custom LWC component integration

### 4. Security Model
#### Permission Sets
- Purchasing_Admin (Full access)
- Purchasing_User (Read/Write access)
- Purchasing_Receiver (Limited receive functionality)

### 5. Testing Strategy
#### Apex Tests
- Test trigger logic for all business scenarios
- Test validation rules and error handling
- Test bulk processing capabilities

#### LWC Tests
- Jest tests for component functionality
- Test user interactions and validations

## Implementation Sequence

1. Create object metadata (Purchase_Order__c and Purchase_Order_Line_Item__c)
2. Implement Apex trigger handlers and business logic
3. Create Lightning Web Component for receiving functionality
4. Create Lightning App and navigation setup
5. Configure security permissions and profiles
6. Deploy to scratch org and perform initial testing
7. Create and run comprehensive test suite
8. Document implementation and usage

## Expected Outcomes
- Complete purchasing workflow from order creation to receipt
- Real-time inventory tracking and updates
- Admin-only access with proper security controls
- Full test coverage and deployment readiness
