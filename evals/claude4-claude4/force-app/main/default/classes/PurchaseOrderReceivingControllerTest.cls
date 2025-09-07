/**
 * @description Test class for PurchaseOrderReceivingController
 * @author Cline
 * @date 2025
 */
@IsTest
private class PurchaseOrderReceivingControllerTest {
    
    /**
     * @description Test setup method to create test data
     */
    @TestSetup
    static void setupTestData() {
        // Create test Account (Supplier)
        Account supplier = new Account(
            Name = 'Test Supplier',
            Type = 'Vendor'
        );
        insert supplier;
        
        // Create test Ingredients
        List<Ingredient__c> ingredients = new List<Ingredient__c>();
        for (Integer i = 1; i <= 3; i++) {
            ingredients.add(new Ingredient__c(
                Name = 'Test Ingredient ' + i,
                In_Stock__c = 100,
                On_Order__c = 50,
                Cost_per_Unit__c = 10.00,
                Unit_of_Purchase__c = 'Pound'
            ));
        }
        insert ingredients;
        
        // Create test Purchase Order
        Purchase_Order__c po = new Purchase_Order__c(
            Supplier__c = supplier.Id,
            Order_Date__c = Date.today(),
            Expected_Delivery_Date__c = Date.today().addDays(7),
            Status__c = 'Submitted',
            Approved__c = true,
            Notes__c = 'Test Purchase Order'
        );
        insert po;
        
        // Create test Purchase Order Line Items
        List<Purchase_Order_Line_Item__c> lineItems = new List<Purchase_Order_Line_Item__c>();
        for (Ingredient__c ingredient : ingredients) {
            lineItems.add(new Purchase_Order_Line_Item__c(
                Purchase_Order__c = po.Id,
                Ingredient__c = ingredient.Id,
                Quantity_Ordered__c = 50,
                Quantity_Received__c = 0,
                Unit_Cost__c = 10.00
            ));
        }
        insert lineItems;
    }
    
    /**
     * @description Test getPurchaseOrderWithLineItems method with valid Purchase Order ID
     */
    @IsTest
    static void testGetPurchaseOrderWithLineItemsValid() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id FROM Purchase_Order__c LIMIT 1];
        
        Test.startTest();
        
        PurchaseOrderReceivingController.PurchaseOrderData result = 
            PurchaseOrderReceivingController.getPurchaseOrderWithLineItems(po.Id);
        
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(null, result.purchaseOrder, 'Purchase Order should not be null');
        System.assertEquals(po.Id, result.purchaseOrder.Id, 'Purchase Order ID should match');
        System.assertNotEquals(null, result.lineItems, 'Line Items should not be null');
        System.assertEquals(3, result.lineItems.size(), 'Should have 3 line items');
        
        // Verify line item data structure
        for (PurchaseOrderReceivingController.LineItemWrapper lineItem : result.lineItems) {
            System.assertNotEquals(null, lineItem.Id, 'Line Item ID should not be null');
            System.assertNotEquals(null, lineItem.ingredientName, 'Ingredient Name should not be null');
            System.assertEquals(50, lineItem.QuantityOrdered, 'Quantity Ordered should be 50');
            System.assertEquals(0, lineItem.QuantityReceived, 'Quantity Received should be 0');
            System.assertEquals(10.00, lineItem.UnitCost, 'Unit Cost should be 10.00');
        }
    }
    
    /**
     * @description Test getPurchaseOrderWithLineItems method with invalid Purchase Order ID
     */
    @IsTest
    static void testGetPurchaseOrderWithLineItemsInvalid() {
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.getPurchaseOrderWithLineItems('001000000000000');
            System.assert(false, 'Exception should have been thrown for invalid ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Purchase Order not found'), 'Error message should mention Purchase Order not found');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test getPurchaseOrderWithLineItems method with null Purchase Order ID
     */
    @IsTest
    static void testGetPurchaseOrderWithLineItemsNull() {
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.getPurchaseOrderWithLineItems(null);
            System.assert(false, 'Exception should have been thrown for null ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('Purchase Order ID is required'), 'Error message should mention ID is required');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test updateLineItemQuantities method with valid updates
     */
    @IsTest
    static void testUpdateLineItemQuantitiesValid() {
        // Get test data
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            ORDER BY Id
        ];
        
        // Prepare update data
        List<Purchase_Order_Line_Item__c> updates = new List<Purchase_Order_Line_Item__c>();
        for (Purchase_Order_Line_Item__c lineItem : lineItems) {
            Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
                Id = lineItem.Id,
                Quantity_Received__c = 25 // Receive half of ordered quantity
            );
            updates.add(updateItem);
        }
        
        Test.startTest();
        
        String result = PurchaseOrderReceivingController.updateLineItemQuantities(updates);
        
        Test.stopTest();
        
        // Verify success message
        System.assert(result.contains('Successfully updated'), 'Should return success message');
        System.assert(result.contains('3'), 'Should mention 3 line items updated');
        
        // Verify line items were updated
        List<Purchase_Order_Line_Item__c> updatedLineItems = [
            SELECT Id, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            WHERE Id IN :lineItems
        ];
        
        for (Purchase_Order_Line_Item__c lineItem : updatedLineItems) {
            System.assertEquals(25, lineItem.Quantity_Received__c, 'Quantity Received should be updated to 25');
        }
        
        // Verify Purchase Order status was updated by trigger
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c LIMIT 1];
        System.assertEquals('Partially Received', updatedPO.Status__c, 'PO Status should be Partially Received');
    }
    
    /**
     * @description Test updateLineItemQuantities method with validation error (quantity too high)
     */
    @IsTest
    static void testUpdateLineItemQuantitiesValidationError() {
        // Get test data
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id, Quantity_Ordered__c 
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        // Prepare invalid update data (quantity received > quantity ordered)
        List<Purchase_Order_Line_Item__c> updates = new List<Purchase_Order_Line_Item__c>();
        Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
            Id = lineItem.Id,
            Quantity_Received__c = lineItem.Quantity_Ordered__c + 10 // More than ordered
        );
        updates.add(updateItem);
        
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.updateLineItemQuantities(updates);
            System.assert(false, 'Exception should have been thrown for validation error');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('cannot exceed'), 'Error message should mention quantity validation');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test updateLineItemQuantities method with empty list
     */
    @IsTest
    static void testUpdateLineItemQuantitiesEmpty() {
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.updateLineItemQuantities(new List<Purchase_Order_Line_Item__c>());
            System.assert(false, 'Exception should have been thrown for empty list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No line items'), 'Error message should mention no line items');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test updateLineItemQuantities method with null list
     */
    @IsTest
    static void testUpdateLineItemQuantitiesNull() {
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.updateLineItemQuantities(null);
            System.assert(false, 'Exception should have been thrown for null list');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('No line items'), 'Error message should mention no line items');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test updateLineItemQuantities method with negative quantity
     */
    @IsTest
    static void testUpdateLineItemQuantitiesNegativeQuantity() {
        // Get test data
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id 
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        // Prepare invalid update data (negative quantity)
        List<Purchase_Order_Line_Item__c> updates = new List<Purchase_Order_Line_Item__c>();
        Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
            Id = lineItem.Id,
            Quantity_Received__c = -5 // Negative quantity
        );
        updates.add(updateItem);
        
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.updateLineItemQuantities(updates);
            System.assert(false, 'Exception should have been thrown for negative quantity');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('cannot be negative'), 'Error message should mention negative quantity validation');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test updateLineItemQuantities method with missing ID
     */
    @IsTest
    static void testUpdateLineItemQuantitiesMissingId() {
        // Prepare invalid update data (no ID)
        List<Purchase_Order_Line_Item__c> updates = new List<Purchase_Order_Line_Item__c>();
        Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
            Quantity_Received__c = 25 // No ID provided
        );
        updates.add(updateItem);
        
        Test.startTest();
        
        try {
            PurchaseOrderReceivingController.updateLineItemQuantities(updates);
            System.assert(false, 'Exception should have been thrown for missing ID');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains('ID is required'), 'Error message should mention ID requirement');
        }
        
        Test.stopTest();
    }
    
    /**
     * @description Test bulk processing with many line items
     */
    @IsTest
    static void testBulkProcessing() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id FROM Purchase_Order__c LIMIT 1];
        
        // Create additional line items for bulk testing
        List<Ingredient__c> ingredients = [SELECT Id FROM Ingredient__c];
        List<Purchase_Order_Line_Item__c> bulkLineItems = new List<Purchase_Order_Line_Item__c>();
        
        for (Integer i = 0; i < 200; i++) {
            bulkLineItems.add(new Purchase_Order_Line_Item__c(
                Purchase_Order__c = po.Id,
                Ingredient__c = ingredients[Math.mod(i, ingredients.size())].Id,
                Quantity_Ordered__c = 10,
                Quantity_Received__c = 0,
                Unit_Cost__c = 5.00
            ));
        }
        insert bulkLineItems;
        
        // Prepare bulk update data
        List<Purchase_Order_Line_Item__c> updates = new List<Purchase_Order_Line_Item__c>();
        for (Purchase_Order_Line_Item__c lineItem : bulkLineItems) {
            Purchase_Order_Line_Item__c updateItem = new Purchase_Order_Line_Item__c(
                Id = lineItem.Id,
                Quantity_Received__c = 5 // Receive half
            );
            updates.add(updateItem);
        }
        
        Test.startTest();
        
        String result = PurchaseOrderReceivingController.updateLineItemQuantities(updates);
        
        Test.stopTest();
        
        // Verify success
        System.assert(result.contains('Successfully updated'), 'Bulk update should succeed');
        System.assert(result.contains('200'), 'Should mention 200 line items updated');
        
        // Verify updates were applied
        List<Purchase_Order_Line_Item__c> updatedItems = [
            SELECT Id, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            WHERE Id IN :bulkLineItems
        ];
        
        for (Purchase_Order_Line_Item__c item : updatedItems) {
            System.assertEquals(5, item.Quantity_Received__c, 'All bulk items should be updated');
        }
    }
    
    /**
     * @description Test security enforcement with WITH SECURITY_ENFORCED
     */
    @IsTest
    static void testSecurityEnforcement() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id FROM Purchase_Order__c LIMIT 1];
        
        Test.startTest();
        
        // This test verifies that the method runs without security exceptions
        // In a real org with restricted access, this would test FLS enforcement
        PurchaseOrderReceivingController.PurchaseOrderData result = 
            PurchaseOrderReceivingController.getPurchaseOrderWithLineItems(po.Id);
        
        Test.stopTest();
        
        // Verify the method executed successfully
        System.assertNotEquals(null, result, 'Method should execute successfully with security enforcement');
    }
    
    /**
     * @description Test wrapper class constructors and properties
     */
    @IsTest
    static void testWrapperClasses() {
        // Get test data
        Purchase_Order__c po = [SELECT Id FROM Purchase_Order__c LIMIT 1];
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id, Purchase_Order__c, Ingredient__c, Ingredient__r.Name,
                   Quantity_Ordered__c, Quantity_Received__c, Unit_Cost__c, Line_Total__c
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        Test.startTest();
        
        // Test PurchaseOrderData constructor
        PurchaseOrderReceivingController.PurchaseOrderData poData = 
            new PurchaseOrderReceivingController.PurchaseOrderData();
        System.assertNotEquals(null, poData.lineItems, 'Line items list should be initialized');
        System.assertEquals(0, poData.lineItems.size(), 'Line items list should be empty initially');
        
        // Test LineItemWrapper constructor
        PurchaseOrderReceivingController.LineItemWrapper wrapper = 
            new PurchaseOrderReceivingController.LineItemWrapper(lineItem);
        
        System.assertEquals(lineItem.Id, wrapper.Id, 'Wrapper ID should match line item ID');
        System.assertEquals(lineItem.Purchase_Order__c, wrapper.PurchaseOrderId, 'Purchase Order ID should match');
        System.assertEquals(lineItem.Ingredient__c, wrapper.IngredientId, 'Ingredient ID should match');
        System.assertEquals(lineItem.Ingredient__r.Name, wrapper.ingredientName, 'Ingredient name should match');
        System.assertEquals(lineItem.Quantity_Ordered__c, wrapper.QuantityOrdered, 'Quantity ordered should match');
        System.assertEquals(lineItem.Quantity_Received__c, wrapper.QuantityReceived, 'Quantity received should match');
        System.assertEquals(lineItem.Unit_Cost__c, wrapper.UnitCost, 'Unit cost should match');
        System.assertEquals(lineItem.Line_Total__c, wrapper.LineTotal, 'Line total should match');
        
        Test.stopTest();
    }
}
