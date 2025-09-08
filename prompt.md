Eval Run ID: qwen3-qwen3
Plan Model: Qwen3
Act Model: Qwen3

You are to generate a complete Salesforce application that implements a purchasing and inventory system for a **commercial baking company**. After reviewing the instructions, analyze the current org structure in the local file system. Ask me any clarifying questions.

Before starting the application build process, create a new ./plan.md file and write the details of your plan to this file.

When completely finished with the application building process, it if was successfully completed or not, create a new ./act.md file with the details of what was built, including what was successful and/or not.

---

## 🧱 Objects

Implement the following Salesforce data model:

1. **Purchase_Order__c**  
2. **Purchase_Order_Line_Item__c**  
   - Child of Purchase_Order__c  
3. **Ingredient__c**
4. Use the standard **Account** object for suppliers

---

## 🧩 Fields to Include

### 🔹 Purchase_Order__c
- `Approved__c` (Checkbox)
- `Status__c` (Picklist) with values:
  - `Draft`
  - `Submitted`
  - `Approved`
  - `Partially Received`
  - `Received`

### 🔹 Purchase_Order_Line_Item__c
- `Quantity_Ordered__c` (Number)
- `Quantity_Received__c` (Number)

### 🔹 Ingredient__c
- `In_Stock__c` (Number)
- `On_Order__c` (Number)

> In addition, include any other **standard purchasing fields** used in industry (e.g., Unit Cost, Notes, Expected Delivery Date).

---

## 🔁 Business Logic

1. When `Approved__c` is checked on a Purchase Order, automatically update `Status__c` to `"Approved"`.

2. A user can only manually change `Status__c` to `"Submitted"` if `Approved__c = TRUE`.

3. When a Purchase Order is set to `"Submitted"`:
   - For each related Line Item:
     - Find the associated Ingredient__c
     - Increase `On_Order__c` by `Quantity_Ordered__c`

4. When a Line Item’s `Quantity_Received__c` is changed:
   - Calculate the **delta** between new and old value
   - Update the related Ingredient__c:
     - Increment `In_Stock__c` by the delta
     - Decrease `On_Order__c` by the delta

5. After all updates:
   - If any line has `Quantity_Received__c > 0` and totals don't match → `Status__c = "Partially Received"`
   - If total received equals total ordered → `Status__c = "Received"`


- No Supplier management functionality
- No approval processes. Use the simple `Approved__c` checkbox
- No minimun stock levels or reorder points for ingredients.
- No cost tracking
- No multi-locations
- No integrations with other systems, including ERP or accounting systems

---

## 🖼️ User Interface

1. Only Admins should be able to manage Purchase Orders and Line Items via the **standard Salesforce UI**. 

2. Create a **Lightning Web Component** that:
   - Accepts a Purchase Order ID
   - Loads its related Line Items
   - Provides input fields to update `Quantity_Received__c`
   - Validates: cannot receive more than `Quantity_Ordered__c`
   - On submit:
     - Apply updates
     - Trigger all relevant logic
     - Display success/error messages

---

## 🔒 Security

- Application is **admin-only** initially.
- Set permissions accordingly (profile/permset).
- No guest, community, or portal access.

---

## 🧭 App Shell

Create a **Lightning App** with tabs for:

- Purchase Orders  
- Purchase Order Line Items  
- Ingredients  
- Suppliers (Accounts)  
- The custom Lightning Web Component  

---

## 📦 Deployment & Testing

- Deploy the complete application to the scratch org
- Once the application is successfully deployed, create any needed Apex or Jest tests
- Deploy the tests and run them for code coverage. Report code coverage. 

## 🛑 Constraints

- ❌ Do **not** generate Apex tests or Jest tests until after the application is successfully deployed
- ❌ Do **not** assume any managed packages
- ✅ Follow Salesforce DX project structure

---

## ✅ Expected Output

A deployed Salesforce application that includes:

- All metadata for objects, fields, automation, and UI
- A working Lightning Web Component
- No hallucinated fields or APIs
- Logic grounded in Salesforce platform behavior