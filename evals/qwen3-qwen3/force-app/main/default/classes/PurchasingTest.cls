@isTest
public class PurchasingTest {
    
    static testMethod void testPurchaseOrderApprovalWorkflow() {
        // Create test data
        Account supplier = new Account(Name = 'Test Supplier');
        insert supplier;
        
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Flour',
            Category__c = 'Flour',
            Unit_of_Purchase__c = 'Bag',
            Cost_per_Unit__c = 10.00,
            In_Stock__c = 100,
            On_Order__c = 0
        );
        insert ingredient;
        
        // Test 1: Create Purchase Order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'PO-001',
            Supplier__c = supplier.Id,
            Status__c = 'Draft'
        );
        insert po;
        
        // Verify default status is Draft
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Draft', po.Status__c, 'Default status should be Draft');
        
        // Test 2: Approve Purchase Order
        po.Approved__c = true;
        update po;
        
        // Verify status changed to Approved
        po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Approved', po.Status__c, 'Status should be Approved when Approved__c is checked');
        System.assertEquals(true, po.Approved__c, 'Approved__c should be true');
        
        // Test 3: Try to set status to Submitted without approval (should fail)
        po.Status__c = 'Submitted';
        po.Approved__c = false;
        Test.startTest();
        try {
            update po;
            System.assert(false, 'Should have thrown an error');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Status can only be set to "Submitted" when the Purchase Order is approved'));
        }
        Test.stopTest();
        
        // Test 4: Set status to Submitted with approval
        po.Approved__c = true;
        po.Status__c = 'Submitted';
        update po;
        
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Submitted', po.Status__c, 'Status should be Submitted');
    }
    
    static testMethod void testPurchaseOrderLineItemWorkflow() {
        // Create test data
        Account supplier = new Account(Name = 'Test Supplier');
        insert supplier;
        
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Sugar',
            Category__c = 'Sweeteners',
            Unit_of_Purchase__c = 'Bag',
            Cost_per_Unit__c = 5.00,
            In_Stock__c = 50,
            On_Order__c = 0
        );
        insert ingredient;
        
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'PO-002',
            Supplier__c = supplier.Id,
            Status__c = 'Draft',
            Approved__c = true
        );
        insert po;
        
        // Test 1: Create Line Item
        Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 10,
            Unit_Cost__c = 5.00
        );
        insert lineItem;
        
        // Verify Line Total calculation
        lineItem = [SELECT Id, Line_Total__c FROM Purchase_Order_Line_Item__c WHERE Id = :lineItem.Id];
        System.assertEquals(50.00, lineItem.Line_Total__c, 'Line total should be quantity * unit cost');
        
        // Test 2: Submit Purchase Order (should update On_Order__c)
        po.Status__c = 'Submitted';
        update po;
        
        ingredient = [SELECT Id, On_Order__c FROM Ingredient__c WHERE Id = :ingredient.Id];
        System.assertEquals(10, ingredient.On_Order__c, 'On_Order__c should be updated when PO is submitted');
        
        // Test 3: Receive partial quantity
        lineItem.Quantity_Received__c = 5;
        update lineItem;
        
        // Verify inventory updates
        ingredient = [SELECT Id, In_Stock__c, On_Order__c FROM Ingredient__c WHERE Id = :ingredient.Id];
        System.assertEquals(55, ingredient.In_Stock__c, 'In_Stock__c should increase by received quantity');
        System.assertEquals(5, ingredient.On_Order__c, 'On_Order__c should decrease by received quantity');
        
        // Verify PO status update
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Partially Received', po.Status__c, 'PO status should be Partially Received');
        
        // Test 4: Receive remaining quantity
        lineItem.Quantity_Received__c = 10;
        update lineItem;
        
        // Verify final inventory updates
        ingredient = [SELECT Id, In_Stock__c, On_Order__c FROM Ingredient__c WHERE Id = :ingredient.Id];
        System.assertEquals(60, ingredient.In_Stock__c, 'In_Stock__c should increase by remaining quantity');
        System.assertEquals(0, ingredient.On_Order__c, 'On_Order__c should be zero');
        
        // Verify PO status update
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Received', po.Status__c, 'PO status should be Received');
    }
    
    static testMethod void testPurchaseOrderReceiverController() {
        // Create test data
        Account supplier = new Account(Name = 'Test Supplier');
        insert supplier;
        
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Butter',
            Category__c = 'Dairy',
            Unit_of_Purchase__c = 'Case',
            Cost_per_Unit__c = 20.00,
            In_Stock__c = 25,
            On_Order__c = 0
        );
        insert ingredient;
        
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'PO-003',
            Supplier__c = supplier.Id,
            Status__c = 'Submitted',
            Approved__c = true
        );
        insert po;
        
        Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 20,
            Unit_Cost__c = 20.00,
            Quantity_Received__c = 0
        );
        insert lineItem;
        
        // Test 1: Get Purchase Order with Line Items
        Test.startTest();
        PurchaseOrderReceiverController.PurchaseOrderWrapper wrapper = 
            PurchaseOrderReceiverController.getPurchaseOrderWithLineItems(po.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, wrapper, 'Wrapper should not be null');
        System.assertEquals(po.Id, wrapper.purchaseOrder.Id, 'Purchase Order ID should match');
        System.assertEquals(1, wrapper.lineItems.size(), 'Should have 1 line item');
        System.assertEquals(lineItem.Id, wrapper.lineItems[0].Id, 'Line item ID should match');
        
        // Test 2: Update Line Items
        List<Purchase_Order_Line_Item__c> itemsToUpdate = new List<Purchase_Order_Line_Item__c>();
        Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
            Id = lineItem.Id,
            Quantity_Received__c = 15
        );
        itemsToUpdate.add(updateItem);
        
        Test.startTest();
        PurchaseOrderReceiverController.updateLineItems(itemsToUpdate);
        Test.stopTest();
        
        // Verify updates
        lineItem = [SELECT Id, Quantity_Received__c FROM Purchase_Order_Line_Item__c WHERE Id = :lineItem.Id];
        System.assertEquals(15, lineItem.Quantity_Received__c, 'Quantity received should be updated');
        
        // Test 3: Try to receive more than ordered (should fail)
        updateItem.Quantity_Received__c = 25; // More than ordered (20)
        itemsToUpdate.clear();
        itemsToUpdate.add(updateItem);
        
        Test.startTest();
        try {
            PurchaseOrderReceiverController.updateLineItems(itemsToUpdate);
            System.assert(false, 'Should have thrown an error');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Received quantity cannot exceed ordered quantity'));
        }
        Test.stopTest();
    }
    
    static testMethod void testLWCComponentFunctionality() {
        // This test verifies the overall workflow that would be used by the LWC
        // Create test data
        Account supplier = new Account(Name = 'Test Supplier');
        insert supplier;
        
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Eggs',
            Category__c = 'Dairy',
            Unit_of_Purchase__c = 'Case',
            Cost_per_Unit__c = 3.00,
            In_Stock__c = 100,
            On_Order__c = 0
        );
        insert ingredient;
        
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'PO-004',
            Supplier__c = supplier.Id,
            Status__c = 'Submitted',
            Approved__c = true
        );
        insert po;
        
        List<Purchase_Order_Line_Item__c> lineItems = new List<Purchase_Order_Line_Item__c>();
        for (Integer i = 0; i < 3; i++) {
            Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
                Purchase_Order__c = po.Id,
                Ingredient__c = ingredient.Id,
                Quantity_Ordered__c = 10,
                Unit_Cost__c = 3.00,
                Quantity_Received__c = 0
            );
            lineItems.add(lineItem);
        }
        insert lineItems;
        
        // Simulate receiving process
        List<Purchase_Order_Line_Item__c> itemsToUpdate = new List<Purchase_Order_Line_Item__c>();
        for (Purchase_Order_Line_Item__c item : lineItems) {
            Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
                Id = item.Id,
                Quantity_Received__c = 5 // Partial receive
            );
            itemsToUpdate.add(updateItem);
        }
        
        Test.startTest();
        update itemsToUpdate;
        Test.stopTest();
        
        // Verify partial receive updates
        List<Purchase_Order_Line_Item__c> updatedItems = [
            SELECT Id, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            WHERE Purchase_Order__c = :po.Id
        ];
        
        for (Purchase_Order_Line_Item__c item : updatedItems) {
            System.assertEquals(5, item.Quantity_Received__c, 'Each item should have 5 received');
        }
        
        // Verify PO status
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Partially Received', po.Status__c, 'PO should be partially received');
        
        // Simulate full receive
        itemsToUpdate.clear();
        for (Purchase_Order_Line_Item__c item : lineItems) {
            Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
                Id = item.Id,
                Quantity_Received__c = 10 // Full receive
            );
            itemsToUpdate.add(updateItem);
        }
        
        Test.startTest();
        update itemsToUpdate;
        Test.stopTest();
        
        // Verify PO status is now Received
        po = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Received', po.Status__c, 'PO should be fully received');
    }
}
