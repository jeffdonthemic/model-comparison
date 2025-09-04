# Commercial Baking Company - Purchasing Application Plan

## **Application Architecture**

### **Core Objects:**

1. **Purchase_Order__c** (Custom Object)
   - Fields: PO Number (auto-number), Supplier (lookup to Account), Order Date, Expected Delivery Date, Total Amount, Status (picklist), Approved (checkbox), Notes
   - Status values: Draft, Approved, Sent, Partially Received, Fully Received, Cancelled

2. **Purchase_Order_Line_Item__c** (Custom Object)
   - Fields: Purchase Order (master-detail to Purchase_Order__c), Ingredient (lookup to Ingredient__c), Quantity Ordered, Quantity Received, Unit Price, Line Total
   - This enables multiple ingredients per purchase order

3. **Account** (Standard Object - for Suppliers)
   - Will use existing Account object with a Record Type for "Supplier"
   - Standard fields: Name, Phone, Email, Billing Address

4. **Ingredient__c** (Existing Custom Object)
   - Will enhance with additional fields if needed for purchasing integration

### **Key Features:**

1. **Purchase Order Creation**
   - **Standard Salesforce UI** for creating Purchase Orders
   - Standard page layouts with related lists for line items
   - Users create PO header, then add line items using standard related list functionality
   - Lookup to select supplier (Account with Supplier record type)

2. **Simple Approval Process**
   - Checkbox field "Approved" on Purchase Order
   - Only approved POs can be marked as "Sent"

3. **Receiving Process**
   - **Lightning Web Component** specifically for receiving
   - Component displays all line items for a Purchase Order
   - Allows bulk update of "Quantity Received" for multiple line items at once
   - Automatically update Ingredient "In_Stock" quantities when items are received
   - Auto-calculate PO status based on received quantities

4. **Automation**
   - Apex triggers to update ingredient stock levels
   - **Flows only** (no Process Builder) to manage PO status transitions
   - Validation rules to ensure data integrity

### **User Interface:**

1. **Purchase Order App**
   - Custom Lightning App with tabs for Purchase Orders, Ingredients, and Suppliers

2. **List Views**
   - All Purchase Orders, Pending Approval, Open Orders, Recently Received

3. **Page Layouts**
   - Standard Salesforce page layouts for Purchase Orders
   - Related lists showing line items on PO records
   - Custom action button to launch receiving LWC

### **Implementation Steps:**

1. Create custom objects (Purchase_Order__c, Purchase_Order_Line_Item__c)
2. Set up Account record type for Suppliers
3. Create custom fields and relationships
4. Configure standard page layouts for Purchase Order creation
5. Build Lightning Web Component for receiving process only
6. Implement Apex triggers for inventory updates
7. Create Flows for PO status automation
8. Create validation rules
9. Set up list views and page layouts
10. Create custom Lightning App
11. Configure permissions and security

## **Requirements Summary:**
- Purchase Order Management: ✅ Yes (with approval workflow)
- Supplier Management: ✅ Basic (using Account object)
- Inventory Integration: ✅ Yes (automatic stock updates)
- Budget/Cost Control: ❌ No
- Users and Permissions: ❌ No special requirements
- Reporting: ❌ No reports at this time
- Integration: ❌ No external systems
- Mobile Access: ❌ No mobile requirements

## **Technical Specifications:**
- Salesforce API Version: 64.0
- UI Framework: Standard Salesforce UI + Lightning Web Components (receiving only)
- Automation: Flows and Apex Triggers
- Data Model: Master-Detail relationships for data integrity
