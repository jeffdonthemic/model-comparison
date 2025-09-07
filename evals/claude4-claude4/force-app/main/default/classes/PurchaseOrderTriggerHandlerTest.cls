/**
 * @description Test class for PurchaseOrderTriggerHandler
 * @author Cline
 * @date 2025
 */
@IsTest
private class PurchaseOrderTriggerHandlerTest {
    
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
                On_Order__c = 0,
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
            Status__c = 'Draft',
            Approved__c = false,
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
     * @description Test approval workflow - when Approved__c is checked, Status__c should be 'Approved'
     */
    @IsTest
    static void testApprovalWorkflow() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c LIMIT 1];
        
        Test.startTest();
        
        // Update Purchase Order to approved
        po.Approved__c = true;
        update po;
        
        Test.stopTest();
        
        // Verify Status__c was updated to 'Approved'
        po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Approved', po.Status__c, 'Status should be Approved when Approved__c is true');
    }
    
    /**
     * @description Test status change to Submitted updates ingredient On_Order__c quantities
     */
    @IsTest
    static void testSubmittedStatusUpdatesIngredients() {
        // Get test data
        Purchase_Order__c po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c LIMIT 1];
        List<Ingredient__c> originalIngredients = [SELECT Id, On_Order__c FROM Ingredient__c ORDER BY Name];
        
        // First approve the PO
        po.Approved__c = true;
        update po;
        
        Test.startTest();
        
        // Change status to Submitted
        po.Status__c = 'Submitted';
        update po;
        
        Test.stopTest();
        
        // Verify ingredients On_Order__c quantities were updated
        List<Ingredient__c> updatedIngredients = [SELECT Id, On_Order__c FROM Ingredient__c ORDER BY Name];
        
        for (Integer i = 0; i < updatedIngredients.size(); i++) {
            System.assertEquals(
                originalIngredients[i].On_Order__c + 50, 
                updatedIngredients[i].On_Order__c,
                'On_Order__c should be increased by Quantity_Ordered__c (50)'
            );
        }
    }
    
    /**
     * @description Test bulk processing with multiple Purchase Orders
     */
    @IsTest
    static void testBulkProcessing() {
        // Get test supplier and ingredients
        Account supplier = [SELECT Id FROM Account LIMIT 1];
        List<Ingredient__c> ingredients = [SELECT Id FROM Ingredient__c];
        
        // Create multiple Purchase Orders
        List<Purchase_Order__c> purchaseOrders = new List<Purchase_Order__c>();
        for (Integer i = 1; i <= 200; i++) {
            purchaseOrders.add(new Purchase_Order__c(
                Supplier__c = supplier.Id,
                Order_Date__c = Date.today(),
                Expected_Delivery_Date__c = Date.today().addDays(7),
                Status__c = 'Draft',
                Approved__c = false
            ));
        }
        insert purchaseOrders;
        
        Test.startTest();
        
        // Bulk approve all Purchase Orders
        for (Purchase_Order__c po : purchaseOrders) {
            po.Approved__c = true;
        }
        update purchaseOrders;
        
        Test.stopTest();
        
        // Verify all were updated to Approved status
        List<Purchase_Order__c> updatedPOs = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id IN :purchaseOrders];
        for (Purchase_Order__c po : updatedPOs) {
            System.assertEquals('Approved', po.Status__c, 'All Purchase Orders should be approved');
        }
    }
    
    /**
     * @description Test validation - Status__c can only be changed to Submitted if Approved__c is true
     */
    @IsTest
    static void testSubmittedValidation() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c LIMIT 1];
        
        Test.startTest();
        
        Boolean exceptionThrown = false;
        try {
            // Try to change status to Submitted without approval
            po.Status__c = 'Submitted';
            update po;
        } catch (DmlException e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('approved'), 'Error message should mention approval requirement');
        }
        
        Test.stopTest();
        
        System.assert(exceptionThrown, 'Exception should be thrown when trying to submit unapproved PO');
    }
    
    /**
     * @description Test recursive trigger prevention
     */
    @IsTest
    static void testRecursiveTriggerPrevention() {
        // Get test Purchase Order
        Purchase_Order__c po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c LIMIT 1];
        
        Test.startTest();
        
        // This should not cause infinite recursion
        po.Approved__c = true;
        po.Status__c = 'Approved'; // Setting both at the same time
        update po;
        
        Test.stopTest();
        
        // Verify the update was successful
        po = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Approved', po.Status__c, 'Status should be Approved');
        System.assertEquals(true, po.Approved__c, 'Approved should be true');
    }
}
