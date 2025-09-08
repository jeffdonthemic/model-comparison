@isTest
private class PurchaseOrderTriggerHandlerTest {
    
    @isTest
    static void testApprovedCheckboxUpdatesStatus() {
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = false,
            Status__c = 'Draft'
        );
        insert po;
        
        // Update Approved__c to true
        po.Approved__c = true;
        update po;
        
        // Verify Status__c is updated to 'Approved'
        Purchase_Order__c updatedPO = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Approved', updatedPO.Status__c, 'Status should be Approved when Approved__c is checked');
    }
    
    @isTest
    static void testCannotSetStatusToSubmittedWhenNotApproved() {
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = false,
            Status__c = 'Draft'
        );
        insert po;
        
        // Try to set Status__c to 'Submitted' without approval
        po.Status__c = 'Submitted';
        update po;
        
        // Verify Status__c should remain 'Draft'
        Purchase_Order__c updatedPO = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Draft', updatedPO.Status__c, 'Status should remain Draft when trying to set to Submitted without approval');
    }
    
    @isTest
    static void testCanSetStatusToSubmittedWhenApproved() {
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = true,
            Status__c = 'Draft'
        );
        insert po;
        
        // Set Status__c to 'Submitted' when approved
        po.Status__c = 'Submitted';
        update po;
        
        // Verify Status__c is updated to 'Submitted'
        Purchase_Order__c updatedPO = [SELECT Id, Status__c, Approved__c FROM Purchase_Order__c WHERE Id = :po.Id];
        System.assertEquals('Submitted', updatedPO.Status__c, 'Status should be Submitted when Approved__c is true');
    }
    
    @isTest
    static void testOnOrderUpdatedWhenPOSubmitted() {
        // Create an ingredient
        Ingredient__c ingredient = new Ingredient__c(
            Name = 'Flour',
            In_Stock__c = 100,
            On_Order__c = 50,
            Cost_per_Unit__c = 2.50
        );
        insert ingredient;
        
        // Create a purchase order
        Purchase_Order__c po = new Purchase_Order__c(
            Name = 'Test PO',
            Approved__c = true,
            Status__c = 'Draft'
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
        
        // Change PO status to 'Submitted'
        po.Status__c = 'Submitted';
        update po;
        
        // Verify On_Order__c is updated
        Ingredient__c updatedIngredient = [SELECT Id, On_Order__c FROM Ingredient__c WHERE Id = :ingredient.Id];
        System.assertEquals(75, updatedIngredient.On_Order__c, 'On_Order__c should be increased by Quantity_Ordered__c');
    }
}
