global class ProductTableController {
    public static List<Product_Table__c> productsList;
    public String MyString;
    
    public Id id { get; set; }
    public Integer totalAmount { get; set; }
    public Integer unitCount { get; set; }
    
    public  String mail { get; set; }
    public  String fName { get; set; }
    public  String lName { get; set; }
    public  Id contactId { get; set; }
    
    public  Product_Table__c selectedProduct {
        get {
            if(selectedProduct==null) {
                selectedProduct = [SELECT Id, Name, Image_URL__c, Product_Description__c, Product_Title__c, Units_Available__c, Unit__c FROM Product_Table__c WHERE Id =: id LIMIT 1];          
            }
            return selectedProduct;
        }
        set ;
    }
    
    //methods
    //
    public List<Product_Table__c> getProductsList() {
        if(productsList == null) {
            productsList = [SELECT Id, Name, Image_URL__c, Product_Description__c, Product_Title__c, Units_Available__c, Unit__c FROM Product_Table__c LIMIT 500];
            for (Product_Table__c temp : productsList) {
                if(temp.Product_Description__c.length()>100) {
                	temp.Product_Description__c = temp.Product_Description__c.substring(0,100) + '... ';    
                }
            }
        }
        return productsList;
    }
    
    public PageReference goToShopping () {
        PageReference mainPage = new PageReference('/apex/ProductPage');
        cleanData();
        return mainPage;
    }
    
    public static PageReference goToDetail () {
        PageReference detailProduct = new PageReference('/apex/DetailProduct');
        return detailProduct;
    }
    
    public static PageReference goToBuy () {
        PageReference buyProduct = new PageReference('/apex/BuyProduct');
        return buyProduct;
    }
    
    public void totalAmountCalc () {
        totalAmount = Integer.valueOf(selectedProduct.Unit__c) * unitCount ;
    }
    
    public void buy () {
        List<Contact> currentCnt = new List<Contact> ();
        currentCnt = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email =:mail AND Email!= NULL];
        if(!currentCnt.isEmpty()) {
            currentCnt[0].FirstName = fName;
            currentCnt[0].LastName = lName;
            contactId = currentCnt[0].Id;
            update currentCnt[0];
            updateProduct();
        } else {
            try{
                Contact newContact = new Contact (
                    Email = mail,
                    FirstName = fName,
                    LastName = lName
                );
                insert newContact;
                contactId = newContact.Id;
                updateProduct();
            } catch(DmlException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter email like "email@domain.com"' ));
            }
            
        }    
       cleanData();
    }
    private void createOrder () {
        Order_Table__c newOrder = new Order_Table__c (
            Product__c = selectedProduct.Id,
            Units__c = unitCount,
            Order_Amount__c = totalAmount,
            Contact__c = contactId
        );
        insert newOrder;
    }
    private void updateProduct () {
        Product_Table__c currentProduct = [SELECT Id, Name, Units_Available__c, Unit__c FROM Product_Table__c WHERE Id =: id LIMIT 1];
        
        System.debug('in updateProduct selectedProduct: '+currentProduct + ' unitCount: '+unitCount);
        if ((currentProduct.Units_Available__c - unitCount) > 0) {
            createOrder(); 
            currentProduct.Units_Available__c -= unitCount;
            update currentProduct;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Order created succesfully'));
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter quantity less or equal then '+currentProduct.Units_Available__c ));
            return;
        }
        System.debug('in updateProduct AFTER selectedProduct.Units_Available__c: '+currentProduct.Units_Available__c);
    }
    
    private void cleanData() {
        totalAmount=0;
        unitCount = 0;
        mail = null;
        fName = null;
        lName = null;
        selectedProduct = null;
    }
}