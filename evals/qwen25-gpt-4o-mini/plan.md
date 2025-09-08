# Plan for Purchasing and Inventory System Application

## Objective
To create a complete Salesforce application that implements a purchasing and inventory system for a commercial baking company.

## Components to Implement
1. **Objects**
   - `Purchase_Order__c`
   - `Purchase_Order_Line_Item__c` (Child of `Purchase_Order__c`)
   - `Ingredient__c`
   - Use the standard `Account` object for suppliers.

2. **Fields to Include**
   - **Purchase_Order__c**
     - `Approved__c` (Checkbox)
     - `Status__c` (Picklist: Draft, Submitted, Approved, Partially Received, Received)
   - **Purchase_Order_Line_Item__c**
     - `Quantity_Ordered__c` (Number)
     - `Quantity_Received__c` (Number)
   - **Ingredient__c**
     - `In_Stock__c` (Number)
     - `On_Order__c` (Number)
     - Additional standard purchasing fields (e.g., Unit Cost, Notes, Expected Delivery Date).

3. **Business Logic**
   - Implement logic for status updates based on the `Approved__c` checkbox and `Quantity_Received__c` changes.
   - Ensure proper handling of line items and ingredient stock levels.

4. **User Interface**
   - Admin-only management of Purchase Orders and Line Items via the standard Salesforce UI.
   - Create a Lightning Web Component for updating `Quantity_Received__c`.

5. **Security**
   - Set permissions to restrict access to Admins only.

6. **App Shell**
   - Create a Lightning App with tabs for Purchase Orders, Purchase Order Line Items, Ingredients, Suppliers, and the custom LWC.

7. **Deployment & Testing**
   - Deploy the application to a scratch org.
   - Create and run Apex or Jest tests after successful deployment.

## Next Steps
- Review and correct the `PurchasingApp.appMenu-meta.xml` file to ensure it adheres to the correct structure.
- Retry the deployment after making the necessary adjustments.
