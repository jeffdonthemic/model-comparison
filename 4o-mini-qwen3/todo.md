# Todo List for Purchasing Application Implementation

- [x] Create the Purchase Order Object
  - [x] Add Approved__c checkbox field
  - [x] Define Status field with options (Draft, Approved, Sent, Partially Received, Fully Received, Cancelled)
  - [x] Add Order Number field
  - [x] Add Vendor field (lookup to Account)
  - [x] Add Order Date field
  - [x] Add Total Amount field

- [x] Create the Purchase Order Line Items Object
  - [x] Add Product field (lookup to Ingredient__c)
  - [x] Add Quantity field
  - [x] Add Unit Price field
  - [x] Add Total Price field (calculated)

- [x] Implement Logic for Status Updates
  - [x] Create trigger or process to update purchase order status based on line item changes

- [x] Develop Lightning Web Component
  - [x] Create component to handle quantities for multiple items

- [x] Implement Purchase Order Creation and Tracking Functionality
  - [x] Ensure users can create and track purchase orders through the standard Salesforce UI
