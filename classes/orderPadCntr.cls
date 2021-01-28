/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-18-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-17-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class orderPadCntr {

    //Getters
    @AuraEnabled
    public static List<PricebookEntry> getProducts(){
        return [SELECT Id,Product2.Id,Product2.Name,Product2.Description,UnitPrice,Product2.Image__c 
                FROM PricebookEntry WHERE PriceBook2.IsStandard = true ORDER BY Product2.Name
                LIMIT 15];
    }
    @AuraEnabled
    public static List<PricebookEntry> searchProductDetail(String keyWord){
        string searchText = '%'+ keyWord +'%';
        system.debug('Hello');
        return[SELECT Id,Product2.Id,Product2.Name,Product2.Description,UnitPrice,Product2.Image__c 
               FROM PricebookEntry WHERE Product2.Name LIKE :searchText LIMIT 5];
    }
    
    
    @AuraEnabled
    public static RG_Cart__c getCart() {
        RG_Cart__c currentCart = new RG_Cart__c();
        List<RG_Cart__c> carts = [SELECT Id,Name,OwnerId,Active__c,CartItem_Count__c FROM RG_Cart__c 
                                  WHERE OwnerId = :UserInfo.getUserId() ];
        if ( carts.isEmpty() ) {
            insert currentCart;
        } else {
            currentCart = carts[0];
        }
        return currentCart;
    }
    @AuraEnabled
    public static User getUserInfo() {
        return [SELECT Id,FirstName,LastName,City,CompanyName,Country,Phone,PostalCode,State,Street FROM User WHERE Id = :UserInfo.getUserId()];
    }
    @AuraEnabled
    public static List<RG_Cart_Item__c> getCartItems(Id cartId) {
        List<RG_Cart_Item__c> cartItems = [SELECT Id,Name,RG_Cart__c,Product__c,Product__r.Id,Quantity__c,Total_Price__c,Unit_Price__c FROM RG_Cart_Item__c WHERE RG_Cart__c = :cartId];
        return cartItems;
    }
    // Setters
    @AuraEnabled
    public static RG_Cart_Item__c updateCartItems(String cartItemId, Decimal quantity) {
        RG_Cart_Item__c cartItem = [SELECT Id,Quantity__c FROM RG_Cart_Item__c WHERE Id = :cartItemId];
        cartItem.Quantity__c = quantity;
        update cartItem;
        return cartItem;
    }
    @AuraEnabled
    public static void updateUserInfo(String firstName, String lastName, String company, String street, String city, String state, String zip) {
        User u = [SELECT Id,FirstName,LastName,City,CompanyName,Country,Phone,PostalCode,State,Street FROM User WHERE Id = :UserInfo.getUserId()];
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CompanyName = company;
        u.Street = street;
        u.City = city;
        u.State = state;
        u.PostalCode = zip;
        update u;
    }
    @AuraEnabled
    public static void deleteCartItems(String cartId) {
        system.debug('Id'+cartId);
        List<RG_Cart_Item__c> cartItems = [SELECT Id,Quantity__c FROM RG_Cart_Item__c WHERE RG_Cart__c = :cartId];
        System.debug(cartItems);
        delete cartItems;
    }
    @AuraEnabled
    public static RG_Cart_Item__c updateCart(Id cartId, String itemName, String productId, Decimal price, Decimal quantity) {
        RG_Cart_Item__c cartItem = new RG_Cart_Item__c(
            RG_Cart__c = cartId,
            Name = itemName,
            Product__c = productId,
            Quantity__c = quantity,
            Unit_Price__c = price
        );
        try {
            
            insert cartItem;
            return cartItem;
        } catch(Exception e) {
            System.debug('Error: '+e.getMessage());
            return null;
        }
        
    }
    @AuraEnabled
    public static RG_Cart__c closeOrder(Id cartId, String cardNumber, String expiration, String securityCode, Decimal tax, Decimal shipping){
        RG_Cart__c cart = [SELECT Id,Name,OwnerId,Active__c,CartItem_Count__c,Credit_Card__c,Expiration__c,Security_Code__c FROM RG_Cart__c WHERE Id = :cartId];
        cart.Credit_Card__c = cardNumber;
        cart.Expiration__c = expiration;
        cart.Security_Code__c = securityCode;
        cart.Tax__c = tax;
        cart.Shipping__c = shipping;
        cart.Active__c = false;
        update cart;
        return cart;
    }
    
    
    @AuraEnabled
    public static List<RG_Cart_Item__c> getUserCartItems() {
        RG_Cart__c currentCart = new RG_Cart__c();
        List<RG_Cart__c> carts = [SELECT Id,Name,OwnerId,Active__c,CartItem_Count__c FROM RG_Cart__c WHERE OwnerId = :UserInfo.getUserId() AND Active__c = true];
        if ( carts.isEmpty() ) {
            // No cart, return empty list of carts...
            return new List<RG_Cart_Item__c>();
        } else {
            // cart found
            currentCart = carts[0];
            List<RG_Cart_Item__c> cartItems = [SELECT Id,Name,RG_Cart__c,Product__c,Product__r.Id,Quantity__c,Total_Price__c,Unit_Price__c FROM RG_Cart_Item__c WHERE RG_Cart__c = :currentCart.Id];
            return cartItems;
        }
    }
    
    @AuraEnabled 
    public static List<Contact> getAddressDetails(String contactId)
    {
        return [SELECT Id,AccountId,Name,Account.BillingStreet, Account.BillingCity, Account.BillingState,Account.BillingPostalCode, 
                Account.BillingCountry, Account.BillingLatitude, Account.BillingLongitude, Account.BillingGeocodeAccuracy, Account.BillingAddress,
                Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry, Account.ShippingLatitude,
                Account.ShippingLongitude, Account.ShippingGeocodeAccuracy, Account.ShippingAddress
                FROM Contact 
                WHERE Id=:contactId];
    }
    
    @AuraEnabled 
    public static Order createOrder(String cartId,String contactId,string storeId,string odmId,string priceBook,string accountId){
        Order newOrder = new Order();
        newOrder.EffectiveDate = system.today();
        neworder.AccountId = accountId;
        neworder.Status = 'Draft';
        neworder.Contact__c = contactId;
        newOrder.OwnerId = UserInfo.getUserId();
        newOrder.SalesStoreId = storeId;
        neworder.Pricebook2Id =priceBook;
        insert newOrder;
    
         List<RG_Cart_Item__c> cartItems = [SELECT Id,Name,RG_Cart__c,Product__c,Product__r.Id,Quantity__c,Total_Price__c,Unit_Price__c 
         FROM RG_Cart_Item__c
          WHERE RG_Cart__c = :cartId];

           OrderDeliveryGroup odg = new OrderDeliveryGroup();
            odg.OrderId=newOrder.id;
            odg.OrderDeliveryMethodId=odmId;
            odg.DeliverToName='The Shipping Address';
            insert odg;

       orderPadCntr.createOrderItems(cartItems,newOrder.Id,odg);
       return newOrder;
    }

    @AuraEnabled 
    public static void createOrderItems(List<RG_Cart_Item__c> cartItems,String orderId,OrderDeliveryGroup odg){
        List<OrderItem> newOrderItemList = new List<OrderItem>();
        system.debug('Cart Item' + cartItems);
        system.debug('Order ID' + orderId);
     
        
        for(RG_Cart_Item__c cartRG : cartItems){
                    OrderItem newOItem = new OrderItem();
        newOItem.OrderId = orderId;
        newOItem.Product2Id = cartRG.Product__r.Id;
        newOItem.Quantity = cartRG.Quantity__c;
        List<PricebookEntry> priceBookId = [SELECT Id,Product2Id
                                            FROM PricebookEntry 
                                            WHERE Product2Id=:cartRG.Product__r.Id];
        system.debug(priceBookId[0].Id);
        newOItem.PricebookEntryId =priceBookId[0].Id;
        newOItem.UnitPrice = cartRG.Unit_Price__c;
        newOItem.OrderDeliveryGroupId = odg.Id;
        newOItem.Type='Order Product';
        //newOItem.ListPrice = cartRG.Unit_Price__c;
        newOrderItemList.add(newOItem);
        }

        insert newOrderItemList; 
        system.debug('Id'+newOrderItemList);
        orderPadCntr.activateOrder(orderId);
        
        
    }

    @AuraEnabled
     public static Order activateOrder(string orderId){
        Order  o = [SELECT ID FROM Order Where Id=:orderId];
        o.Status = 'Activated';
       update o;
       return o;

    }
}