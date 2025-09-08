@isTest
private class PurchaseOrderLineItemTriggerHandlerTest {
    
    @isTest
    static void testIngredientStockUpdatedWhenQuantityReceivedChanged() {
        // Create an ingredient
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Sugar',
            In_Stock__c = 100,
            On_Order__c = 50,
            Cost_per_Unit__c = 1.50
        );
        insert ingredient;
        
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = true,
            Status__c = 'Submitted'
        );
        insert po;
        
        // Create a line item
        Purchase_Order_Line_Item__c lineItem = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 25,
            Quantity_Received__c = 0
        );
        insert lineItem;
        
        // Update Quantity_Received__c
        lineItem.Quantity_Received__c = 15;
        update lineItem;
        
        // Verify ingredient stock is updated
        Ingredient__c updatedIngredient = [SELECT Id, In_Stock__c, On_Order__c FROM Ingredient__c WHERE Id = :ingredient.Id];
        System.assertEquals(115, updatedIngredient.In_Stock__c, 'In_Stock__c should be increased by received quantity');
        System.assertEquals(35, updatedIngredient.On_Order__c, 'On_Order__c should be decreased by received quantity');
    }
    
    @isTest
    static void testPOStatusUpdatedToPartiallyReceived() {
        // Create an ingredient
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Butter',
            In_Stock__c = 100,
            On_Order__c = 50,
            Cost_per_Unit__c = 3.00
        );
        insert ingredient;
        
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = true,
            Status__c = 'Submitted'
        );
        insert po;
        
        // Create line items
        Purchase_Order_Line_Item__c lineItem1 = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 20,
            Quantity_Received__c = 0
        );
        
        Purchase_Order_Line_Item__c lineItem2 = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 30,
            Quantity_Received__c = 0
        );
        
        insert new List<Purchase_Order_Line_Item__c>{lineItem1, lineItem2};
        
        // Update one line item to receive partial quantity
        lineItem1.Quantity_Received__c = 10;
        update lineItem1;
        
        // Verify PO status is updated to Partially Received
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Partially Received', updatedPO.Status__c, 'Status should be Partially Received when some items are received');
    }
    
    @isTest
    static void testPOStatusUpdatedToReceived() {
        // Create an ingredient
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Eggs',
            In_Stock__c = 100,
            On_Order__c = 50,
            Cost_per_Unit__c = 0.25
        );
        insert ingredient;
        
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = true,
            Status__c = 'Submitted'
        );
        insert po;
        
        // Create line items
        Purchase_Order_Line_Item__c lineItem1 = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 20,
            Quantity_Received__c = 0
        );
        
        Purchase_Order_Line_Item__c lineItem2 = new Purchase_Order_Line_Item__c(
            Purchase_Order__c = po.Id,
            Ingredient__c = ingredient.Id,
            Quantity_Ordered__c = 30,
            Quantity_Received__c = 0
        );
        
        insert new List<Purchase_Order_Line_Item__c>{lineItem1, lineItem2};
        
        // Update both line items to receive full quantity
        lineItem1.Quantity_Received__c = 20;
        lineItem2.Quantity_Received__c = 30;
        update new List<Purchase_Order_Line_Item__c>{lineItem1, lineItem2};
        
        // Verify PO status is updated to Received
        Purchase_Order__c updatedPO = [SELECT Id, Status__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Received', updatedPO.Status__c, 'Status should be Received when all items are received');
    }
}
