# Model Comparison

I built a simple purchasing application in Salesforce for a baking company using different models to test out the results. I did not intend on spending too much time on the applications; I wanted to evaluate what was built with minimal input. I just wanted to build a MVP that was deployable. I have not evaluated the running application.

I built the same version of the application using the following models. I then had Cursor (Claude) analyze each application on its own and then a comparison between different model versions.

- Claude (plan) and Claude (act) – grade B+
- GPT 4o min (plan) and Qwen3 Coder (act) – grade F
- Gemini 2.5 Flash Lite (plan) and Qwen3 Coder (act) – Grade C+

## Analysis

👉 See the files in this repo for an analyzis of each application individually and then a comparison of different applications/models. 


---->>> has the model/agent followed the rules I'd given it

## Prompt

Eval Run ID: claude4-claude4
Plan Model: Claude Sonnet 4
Act Model: Claude Sonnet 4

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

## 📦 Deployment

- Deploy the complete application to the scratch org
- One the application is successfully deployed, create needed Apex or Jest test and deploy

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




## Base Application
For each app, I used a new scratch org that contained an Ingredient__c object.

# General Observations

## Gemini 2.5 Flash Lite - Qwen3 Coder
I [recorded the build planning](https://drive.google.com/file/d/1xhWeSm8P9aSzzHtrxHTdPVeZO89ahO46/view?usp=sharing) phase (16 minutes ) for this application. I was impressed with how thorough the planning was with Gemini. It felt like it was much more indepth than with Claude. Gemini asked me if it was OK to use Flows for automations instead of triggers. I thought I would let it try with Flow and see the process. 

### Deployment Errors

Gemini has much fewer deployment issues than Claude did! It fixed the first two object related errors pretty easily but took much longer (5 tries?) to get the Flow deployable.

```
force-app/main/default/flows/PO_Status_Update_Flow.flow-meta.xml  Error parsing file: Element decisions is duplicated at this location in type Flow (164:20)

force-app/main/default/objects/PurchaseOrder__c/fields/Supplier__c.field-meta.xml  Can not specify 'relationshipOrder' for a CustomField of type Lookup (224:13)

force-app/main/default/objects/PurchaseOrder__c/fields/Supplier__c.field-meta.xml  There is already a Child Relationship named Purchase_Orders on Account. (224:13)
```

## GPT 4o mini - Qwen3 Coder
4o-mini asked much more detailed initial questions during plan mode than Claude. It tried to create a todo list during plan mode which failed. I didn’t look at the file structure and wanted to create the existing Ingredient and Account objects. Even after I told it to look at my current file structure, it still wanted to create the Ingredient object. Finally found the object. It still wanted to create the Account object. Even when I switched to Plan, it asked if I wanted to proceed.

It created the object and then again asked if I wanted to proceed creating other assets. It keeps asking to proceed after completing each item on the todo list. I couldn’t get it to display its focus chain doc. 

4o-mini asked many more detailed questions before generating a plan. Its plan wasn’t as detailed as Claude’s and indicated that it wanted to create standard and existing custom objects.

### Deployment Failures

When I shared the terminal with deployment failures, it displayed a summary of the errors and how to fix them. Asked to proceed. I had to deploy the custom object one by one. It got the sharing model wrong on the child object.

Component Failures [3]
```
┌──────────────┬───────────────────────────────┬──────────────────┬─────────────┐
│ Type         │ Name                          │ Problem          │ Line:Column │
├──────────────┼───────────────────────────────┼──────────────────┼─────────────┤
│ ApexTrigger  │ PurchaseOrderStatusTrigger    │ Variable does    │ 12:39       │
│              │                               │ not exist: Purch │             │
│              │                               │ ase_Order__c     │             │
│              │                               │ (12:39)          │             │
│ CustomObject │ Purchase_Order_Line_Item__c   │ Cannot set       │             │
│              │                               │ sharingModel to  │             │
│              │                               │ ControlledByPare │             │
│              │                               │ nt on a          │             │
│              │                               │ CustomObject     │             │
│              │                               │ without a        │             │
│              │                               │ MasterDetail     │             │
│              │                               │ relationship     │             │
│              │                               │ field            │             │
│ CustomField  │ Purchase_Order__c.Approved__c │ Must specify     │ 165:13      │
│              │                               │ 'defaultValue'   │             │
│              │                               │ for a            │             │
│              │                               │ CustomField of   │             │
│              │                               │ type Checkbox    │             │
│              │                               │ (165:13)         │             │
└──────────────┴───────────────────────────────┴──────────────────┴─────────────┘
```

## Claude - Claude

Did a really good job. Create permission set but didn't assign users to the set now add all of the objects' fields.

It did not set up access to the LWC. No way to get to it. Cline didn’t create the actual quick action until I prompted it to. Had problems deploying the changes; had to deploy the LWC first then the quick action. Cline put the quick action in the wrong directory. Had to remove the quick action from the page layout then deploy the quick action. The main issue is it was trying to create the quick action as a LC instead of an LWC and then put it in the wrong directory. Was not able to actually create the Quick action and quit. I had to add the LWC to the lightning page layout. Not all functionality worked correctly. Especially the LWC.

### Deployment Failures

Component Failures [21]
```
┌──────────────────────────┬──────────────────────────────────────────────┬─────────┬─────────────┐
│ Type                     │ Name                                         │ Problem │ Line:Column │
├──────────────────────────┼──────────────────────────────────────────────┼─────────┼─────────────┤
│ RecordType               │ Account.Supplier                             │ Picklis │ 3:18        │
│                          │                                              │ t       │             │
│                          │                                              │ value:  │             │
│                          │                                              │ Adverti │             │
│                          │                                              │ sement  │             │
│                          │                                              │ in pick │             │
│                          │                                              │ list:   │             │
│                          │                                              │ Account │             │
│                          │                                              │ Source  │             │
│                          │                                              │ not     │             │
│                          │                                              │ found   │             │
│                          │                                              │ (3:18)  │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 19:30       │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Ingredi │             │
│                          │                                              │ ent__c  │             │
│                          │                                              │ (19:30) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 20:48       │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Ingredi │             │
│                          │                                              │ ent__c  │             │
│                          │                                              │ (20:48) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 22:47       │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ e_Order │             │
│                          │                                              │ __c     │             │
│                          │                                              │ (22:47) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 54:95       │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Ingredi │             │
│                          │                                              │ ent__c  │             │
│                          │                                              │ (54:95) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 59:75       │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Ingredi │             │
│                          │                                              │ ent__c  │             │
│                          │                                              │ (59:75) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Didn't  │ 87:86       │
│                          │                                              │ underst │             │
│                          │                                              │ and     │             │
│                          │                                              │ relatio │             │
│                          │                                              │ nship   │             │
│                          │                                              │ 'Purcha │             │
│                          │                                              │ se_Orde │             │
│                          │                                              │ r_Line_ │             │
│                          │                                              │ Items__ │             │
│                          │                                              │ r' in   │             │
│                          │                                              │ FROM    │             │
│                          │                                              │ part of │             │
│                          │                                              │ query   │             │
│                          │                                              │ call.   │             │
│                          │                                              │ If you  │             │
│                          │                                              │ are att │             │
│                          │                                              │ empting │             │
│                          │                                              │ to use  │             │
│                          │                                              │ a       │             │
│                          │                                              │ custom  │             │
│                          │                                              │ relatio │             │
│                          │                                              │ nship,  │             │
│                          │                                              │ be sure │             │
│                          │                                              │ to      │             │
│                          │                                              │ append  │             │
│                          │                                              │ the     │             │
│                          │                                              │ '__r'   │             │
│                          │                                              │ after   │             │
│                          │                                              │ the     │             │
│                          │                                              │ custom  │             │
│                          │                                              │ relatio │             │
│                          │                                              │ nship   │             │
│                          │                                              │ name.   │             │
│                          │                                              │ Please  │             │
│                          │                                              │ referen │             │
│                          │                                              │ ce your │             │
│                          │                                              │ WSDL or │             │
│                          │                                              │ the des │             │
│                          │                                              │ cribe   │             │
│                          │                                              │ call    │             │
│                          │                                              │ for the │             │
│                          │                                              │ appropr │             │
│                          │                                              │ iate    │             │
│                          │                                              │ names.  │             │
│                          │                                              │ (87:86) │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 115:16      │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ e_Order │             │
│                          │                                              │ _Line_I │             │
│                          │                                              │ tems__r │             │
│                          │                                              │ (115:16 │             │
│                          │                                              │ )       │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 115:59      │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ e_Order │             │
│                          │                                              │ _Line_I │             │
│                          │                                              │ tems__r │             │
│                          │                                              │ (115:59 │             │
│                          │                                              │ )       │             │
│ ApexClass                │ PurchaseOrderLineItemTriggerHandler          │ Variabl │ 122:56      │
│                          │                                              │ e does  │             │
│                          │                                              │ not     │             │
│                          │                                              │ exist:  │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ e_Order │             │
│                          │                                              │ _Line_I │             │
│                          │                                              │ tems__r │             │
│                          │                                              │ (122:56 │             │
│                          │                                              │ )       │             │
│ ApexClass                │ PurchaseOrderReceivingController             │ No such │ 13:20       │
│                          │                                              │ column  │             │
│                          │                                              │ 'Ingred │             │
│                          │                                              │ ient__c │             │
│                          │                                              │ ' on    │             │
│                          │                                              │ entity  │             │
│                          │                                              │ 'Purcha │             │
│                          │                                              │ se_Orde │             │
│                          │                                              │ r_Line_ │             │
│                          │                                              │ Item__c │             │
│                          │                                              │ '. If   │             │
│                          │                                              │ you are │             │
│                          │                                              │ attempt │             │
│                          │                                              │ ing to  │             │
│                          │                                              │ use a   │             │
│                          │                                              │ custom  │             │
│                          │                                              │ field,  │             │
│                          │                                              │ be sure │             │
│                          │                                              │ to      │             │
│                          │                                              │ append  │             │
│                          │                                              │ the     │             │
│                          │                                              │ '__c'   │             │
│                          │                                              │ after   │             │
│                          │                                              │ the     │             │
│                          │                                              │ custom  │             │
│                          │                                              │ field   │             │
│                          │                                              │ name.   │             │
│                          │                                              │ Please  │             │
│                          │                                              │ referen │             │
│                          │                                              │ ce your │             │
│                          │                                              │ WSDL or │             │
│                          │                                              │ the des │             │
│                          │                                              │ cribe   │             │
│                          │                                              │ call    │             │
│                          │                                              │ for the │             │
│                          │                                              │ appropr │             │
│                          │                                              │ iate    │             │
│                          │                                              │ names.  │             │
│                          │                                              │ (13:20) │             │
│ CustomField              │ Purchase_Order_Line_Item__c.Ingredient__c    │ field   │ 166:13      │
│                          │                                              │ integri │             │
│                          │                                              │ ty exce │             │
│                          │                                              │ ption:  │             │
│                          │                                              │ unknown │             │
│                          │                                              │ (must   │             │
│                          │                                              │ specify │             │
│                          │                                              │ either  │             │
│                          │                                              │ cascade │             │
│                          │                                              │ delete  │             │
│                          │                                              │ or rest │             │
│                          │                                              │ rict    │             │
│                          │                                              │ delete  │             │
│                          │                                              │ for req │             │
│                          │                                              │ uired   │             │
│                          │                                              │ lookup  │             │
│                          │                                              │ foreign │             │
│                          │                                              │ key) (1 │             │
│                          │                                              │ 66:13)  │             │
│ CustomField              │ Purchase_Order_Line_Item__c.Purchase_Order__ │ Can not │ 188:13      │
│                          │ c                                            │ specify │             │
│                          │                                              │ 'requir │             │
│                          │                                              │ ed' for │             │
│                          │                                              │ a Custo │             │
│                          │                                              │ mField  │             │
│                          │                                              │ of type │             │
│                          │                                              │ MasterD │             │
│                          │                                              │ etail ( │             │
│                          │                                              │ 188:13) │             │
│ Layout                   │ Purchase_Order__c-Purchase Order Layout      │ Field:N │             │
│                          │                                              │ ame     │             │
│                          │                                              │ must    │             │
│                          │                                              │ not be  │             │
│                          │                                              │ Require │             │
│                          │                                              │ d       │             │
│ ListView                 │ Purchase_Order__c.All                        │ In      │ 267:16      │
│                          │                                              │ field:  │             │
│                          │                                              │ columns │             │
│                          │                                              │ - no    │             │
│                          │                                              │ CustomF │             │
│                          │                                              │ ield    │             │
│                          │                                              │ named P │             │
│                          │                                              │ urchase │             │
│                          │                                              │ _Order_ │             │
│                          │                                              │ _c.Supp │             │
│                          │                                              │ lier__c │             │
│                          │                                              │ found ( │             │
│                          │                                              │ 267:16) │             │
│ ListView                 │ Purchase_Order__c.Open_Orders                │ In      │ 279:16      │
│                          │                                              │ field:  │             │
│                          │                                              │ columns │             │
│                          │                                              │ - no    │             │
│                          │                                              │ CustomF │             │
│                          │                                              │ ield    │             │
│                          │                                              │ named P │             │
│                          │                                              │ urchase │             │
│                          │                                              │ _Order_ │             │
│                          │                                              │ _c.Supp │             │
│                          │                                              │ lier__c │             │
│                          │                                              │ found ( │             │
│                          │                                              │ 279:16) │             │
│ ListView                 │ Purchase_Order__c.Pending_Approval           │ In      │ 295:16      │
│                          │                                              │ field:  │             │
│                          │                                              │ columns │             │
│                          │                                              │ - no    │             │
│                          │                                              │ CustomF │             │
│                          │                                              │ ield    │             │
│                          │                                              │ named P │             │
│                          │                                              │ urchase │             │
│                          │                                              │ _Order_ │             │
│                          │                                              │ _c.Supp │             │
│                          │                                              │ lier__c │             │
│                          │                                              │ found ( │             │
│                          │                                              │ 295:16) │             │
│ CustomField              │ Purchase_Order__c.Supplier__c                │ field   │ 245:13      │
│                          │                                              │ integri │             │
│                          │                                              │ ty exce │             │
│                          │                                              │ ption:  │             │
│                          │                                              │ unknown │             │
│                          │                                              │ (must   │             │
│                          │                                              │ specify │             │
│                          │                                              │ either  │             │
│                          │                                              │ cascade │             │
│                          │                                              │ delete  │             │
│                          │                                              │ or rest │             │
│                          │                                              │ rict    │             │
│                          │                                              │ delete  │             │
│                          │                                              │ for req │             │
│                          │                                              │ uired   │             │
│                          │                                              │ lookup  │             │
│                          │                                              │ foreign │             │
│                          │                                              │ key) (2 │             │
│                          │                                              │ 45:13)  │             │
│ CustomApplication        │ Purchasing_App                               │ In      │             │
│                          │                                              │ field:  │             │
│                          │                                              │ utility │             │
│                          │                                              │ Bar -   │             │
│                          │                                              │ no Flex │             │
│                          │                                              │ iPage   │             │
│                          │                                              │ named   │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ ing_App │             │
│                          │                                              │ _Utilit │             │
│                          │                                              │ yBar    │             │
│                          │                                              │ found   │             │
│ PermissionSet            │ Purchasing_User                              │ In      │             │
│                          │                                              │ field:  │             │
│                          │                                              │ applica │             │
│                          │                                              │ tion -  │             │
│                          │                                              │ no Cust │             │
│                          │                                              │ omAppli │             │
│                          │                                              │ cation  │             │
│                          │                                              │ named   │             │
│                          │                                              │ Purchas │             │
│                          │                                              │ ing_App │             │
│                          │                                              │ found   │             │
│ LightningComponentBundle │ purchaseOrderReceiving                       │ Unable  │             │
│                          │                                              │ to find │             │
│                          │                                              │ Apex    │             │
│                          │                                              │ action  │             │
│                          │                                              │ class   │             │
│                          │                                              │ referen │             │
│                          │                                              │ ced as  │             │
│                          │                                              │ 'Purcha │             │
│                          │                                              │ seOrder │             │
│                          │                                              │ Receivi │             │
│                          │                                              │ ngContr │             │
│                          │                                              │ oller'. │             │
│                          │                                              │ Unable  │             │
│                          │                                              │ to find │             │
│                          │                                              │ Apex    │             │
│                          │                                              │ action  │             │
│                          │                                              │ class   │             │
│                          │                                              │ referen │             │
│                          │                                              │ ced as  │             │
│                          │                                              │ 'Purcha │             │
│                          │                                              │ seOrder │             │
│                          │                                              │ Receivi │             │
│                          │                                              │ ngContr │             │
│                          │                                              │ oller'. │             │
└──────────────────────────┴──────────────────────────────────────────────┴─────────┴─────────────┘
```

Another deploy:

Component Failures [2]
```
┌────────────┬─────────────────────────────────────────┬───────────────────────────────────────────┬─────────────┐
│ Type       │ Name                                    │ Problem                                   │ Line:Column │
├────────────┼─────────────────────────────────────────┼───────────────────────────────────────────┼─────────────┤
│ RecordType │ Account.Supplier                        │ Picklist value: Advertisement in          │ 3:18        │
│            │                                         │ picklist: AccountSource not found (3:18)  │             │
│ Layout     │ Purchase_Order__c-Purchase Order Layout │ Cannot find related                       │             │
│            │                                         │ list:Purchase_Order_Line_Items__r         │             │
└────────────┴─────────────────────────────────────────┴───────────────────────────────────────────┴─────────────┘
```

Component Failures [2]
```
┌────────────┬─────────────────────────────────────────┬───────────────────────────────────────────┬─────────────┐
│ Type       │ Name                                    │ Problem                                   │ Line:Column │
├────────────┼─────────────────────────────────────────┼───────────────────────────────────────────┼─────────────┤
│ RecordType │ Account.Supplier                        │ Picklist value: Analyst in picklist: Type │ 3:18        │
│            │                                         │ not found (3:18)                          │             │
│ Layout     │ Purchase_Order__c-Purchase Order Layout │ Cannot find related                       │             │
│            │                                         │ list:Purchase_Order_Line_Items            │             │
└────────────┴─────────────────────────────────────────┴───────────────────────────────────────────┴─────────────┘
```