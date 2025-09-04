# Deployment Instructions

## Deploy to Salesforce Org

To deploy this purchasing application to your Salesforce org, run the following command:

```bash
sf project deploy start --source-dir force-app/main/default
```

## Post-Deployment Setup

1. **Assign Permission Set**: Assign the "Purchasing User" permission set to users who need access to the purchasing application.

2. **Create Sample Data**:
   - Create supplier accounts with the "Supplier" record type
   - Ensure you have ingredient records in your system

3. **Test the Application**:
   - Navigate to the "Purchasing" app
   - Create a new Purchase Order
   - Add line items to the purchase order
   - Test the approval workflow
   - Test the receiving process using the Lightning Web Component

## Key Features Implemented

- ✅ Purchase Order management with approval workflow
- ✅ Purchase Order Line Items with ingredient tracking
- ✅ Automatic inventory updates when items are received
- ✅ Status automation (Draft → Approved → Sent → Partially/Fully Received)
- ✅ Lightning Web Component for bulk receiving
- ✅ Supplier management using Account record types
- ✅ Custom Lightning App with all necessary tabs
- ✅ Permission sets for security
- ✅ List views for different purchase order statuses
