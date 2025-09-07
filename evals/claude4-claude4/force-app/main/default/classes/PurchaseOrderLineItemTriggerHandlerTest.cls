/**
 * @description Test class for PurchaseOrderLineItemTriggerHandler
 * @author Cline
 * @date 2025
 */
@IsTest
private class PurchaseOrderLineItemTriggerHandlerTest {
    
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
                On_Order__c = 50, // Start with some on order
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
     * @description Test receiving partial quantities updates ingredient stock and on-order
     */
    @IsTest
    static void testPartialReceiving() {
        // Get test data
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c, Ingredient__c 
            FROM Purchase_Order_Line_Item__c 
            ORDER BY Id
        ];
        
        List<Ingredient__c> originalIngredients = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            ORDER BY Name
        ];
        
        Test.startTest();
        
        // Receive partial quantities for first line item
        lineItems[0].Quantity_Received__c = 25; // Receive 25 out of 50 ordered
        update lineItems[0];
        
        Test.stopTest();
        
        // Verify ingredient stock was updated correctly
        List<Ingredient__c> updatedIngredients = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            WHERE Id = :lineItems[0].Ingredient__c
        ];
        
        System.assertEquals(
            originalIngredients[0].In_Stock__c + 25,
            updatedIngredients[0].In_Stock__c,
            'In_Stock__c should be increased by received quantity (25)'
        );
        
        System.assertEquals(
            originalIngredients[0].On_Order__c - 25,
            updatedIngredients[0].On_Order__c,
            'On_Order__c should be decreased by received quantity (25)'
        );
        
        // Verify Purchase Order status is updated to Partially Received
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c LIMIT 1];
        System.assertEquals('Partially Received', updatedPO.Status__c, 'PO Status should be Partially Received');
    }
    
    /**
     * @description Test receiving full quantities updates status to Received
     */
    @IsTest
    static void testFullReceiving() {
        // Get test data
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c, Ingredient__c 
            FROM Purchase_Order_Line_Item__c 
            ORDER BY Id
        ];
        
        Test.startTest();
        
        // Receive full quantities for all line items
        for (Purchase_Order_Line_Item__c lineItem : lineItems) {
            lineItem.Quantity_Received__c = lineItem.Quantity_Ordered__c;
        }
        update lineItems;
        
        Test.stopTest();
        
        // Verify Purchase Order status is updated to Received
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c LIMIT 1];
        System.assertEquals('Received', updatedPO.Status__c, 'PO Status should be Received when all items fully received');
    }
    
    /**
     * @description Test delta calculation when quantity received is updated multiple times
     */
    @IsTest
    static void testDeltaCalculation() {
        // Get test data
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c, Ingredient__c 
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        Ingredient__c originalIngredient = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            WHERE Id = :lineItem.Ingredient__c
        ];
        
        Test.startTest();
        
        // First update - receive 20
        lineItem.Quantity_Received__c = 20;
        update lineItem;
        
        // Second update - receive 10 more (total 30)
        lineItem.Quantity_Received__c = 30;
        update lineItem;
        
        // Third update - reduce to 25 (delta -5)
        lineItem.Quantity_Received__c = 25;
        update lineItem;
        
        Test.stopTest();
        
        // Verify final ingredient quantities
        Ingredient__c finalIngredient = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            WHERE Id = :lineItem.Ingredient__c
        ];
        
        System.assertEquals(
            originalIngredient.In_Stock__c + 25,
            finalIngredient.In_Stock__c,
            'In_Stock__c should reflect final received quantity (25)'
        );
        
        System.assertEquals(
            originalIngredient.On_Order__c - 25,
            finalIngredient.On_Order__c,
            'On_Order__c should reflect final received quantity (25)'
        );
    }
    
    /**
     * @description Test bulk processing with multiple line items
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
        
        Test.startTest();
        
        // Bulk update all line items to received
        for (Purchase_Order_Line_Item__c lineItem : bulkLineItems) {
            lineItem.Quantity_Received__c = lineItem.Quantity_Ordered__c;
        }
        update bulkLineItems;
        
        Test.stopTest();
        
        // Verify no exceptions were thrown and updates were successful
        List<Purchase_Order_Line_Item__c> updatedItems = [
            SELECT Id, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            WHERE Id IN :bulkLineItems
        ];
        
        for (Purchase_Order_Line_Item__c item : updatedItems) {
            System.assertEquals(10, item.Quantity_Received__c, 'All items should be fully received');
        }
    }
    
    /**
     * @description Test status calculation with mixed receiving scenarios
     */
    @IsTest
    static void testMixedReceivingStatus() {
        // Get test data
        List<Purchase_Order_Line_Item__c> lineItems = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            ORDER BY Id
        ];
        
        Test.startTest();
        
        // Receive different amounts for different line items
        lineItems[0].Quantity_Received__c = lineItems[0].Quantity_Ordered__c; // Full
        lineItems[1].Quantity_Received__c = lineItems[1].Quantity_Ordered__c / 2; // Partial
        lineItems[2].Quantity_Received__c = 0; // None
        
        update lineItems;
        
        Test.stopTest();
        
        // Verify Purchase Order status is Partially Received
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c LIMIT 1];
        System.assertEquals('Partially Received', updatedPO.Status__c, 'PO Status should be Partially Received with mixed receiving');
    }
    
    /**
     * @description Test recursive trigger prevention
     */
    @IsTest
    static void testRecursiveTriggerPrevention() {
        // Get test data
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        Test.startTest();
        
        // This should not cause infinite recursion
        lineItem.Quantity_Received__c = 25;
        update lineItem;
        
        // Update again
        lineItem.Quantity_Received__c = 30;
        update lineItem;
        
        Test.stopTest();
        
        // Verify the updates were successful
        lineItem = [
            SELECT Id, Quantity_Received__c 
            FROM Purchase_Order_Line_Item__c 
            WHERE Id = :lineItem.Id
        ];
        System.assertEquals(30, lineItem.Quantity_Received__c, 'Final quantity should be 30');
    }
    
    /**
     * @description Test zero quantity handling
     */
    @IsTest
    static void testZeroQuantityHandling() {
        // Get test data
        Purchase_Order_Line_Item__c lineItem = [
            SELECT Id, Quantity_Ordered__c, Quantity_Received__c, Ingredient__c 
            FROM Purchase_Order_Line_Item__c 
            LIMIT 1
        ];
        
        Ingredient__c originalIngredient = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            WHERE Id = :lineItem.Ingredient__c
        ];
        
        Test.startTest();
        
        // Receive some quantity first
        lineItem.Quantity_Received__c = 20;
        update lineItem;
        
        // Then set back to zero
        lineItem.Quantity_Received__c = 0;
        update lineItem;
        
        Test.stopTest();
        
        // Verify ingredient quantities are back to original
        Ingredient__c finalIngredient = [
            SELECT Id, In_Stock__c, On_Order__c 
            FROM Ingredient__c 
            WHERE Id = :lineItem.Ingredient__c
        ];
        
        System.assertEquals(
            originalIngredient.In_Stock__c,
            finalIngredient.In_Stock__c,
            'In_Stock__c should be back to original value'
        );
        
        System.assertEquals(
            originalIngredient.On_Order__c,
            finalIngredient.On_Order__c,
            'On_Order__c should be back to original value'
        );
    }
}
