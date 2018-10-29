@isTest
public class PoductTableControllerTest {
    
    @testSetup
    static void createData() {
        List<Product_Table__c> productList = new List<Product_Table__c>();
        for (Integer i=0; i<10; i++) {
            productList.add(new Product_Table__c(
                Name = 'test name '+ i, 
                Image_URL__c = 'test Image_URL__c '+i, 
                Product_Description__c =  generateRandomString(101)+i,
                Product_Title__c = 'test Product_Title__c ' + i, 
                Units_Available__c = 10,
                Unit__c = 3
            ));
        }
        insert productList;
    }
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr ='';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    @isTest
    static void getProductsList_test() {
        ProductTableController ctrl = new ProductTableController();
        List<Product_Table__c> testList = ctrl.getProductsList();
        System.assertNotEquals(null, testList);
        System.assertEquals(10, testList.size());
    }
    @isTest
    private static void goToShopping_test () {
        ProductTableController ctrl = new ProductTableController();
        
        Test.startTest();
        Product_Table__c testProduct = [SELECT Id, Name, Image_URL__c, Product_Description__c, Product_Title__c, Units_Available__c, Unit__c FROM Product_Table__c LIMIT 1];
        Test.stopTest();
        
        ctrl.id = testProduct.Id;
        ctrl.unitCount = 1;
        ctrl.mail = 'test@test.com';
        ctrl.fName = 'fname';
        ctrl.lName = 'lname';
        ctrl.totalAmountCalc ();
        System.assertEquals(Integer.valueOf(testProduct.Unit__c) * 1, ctrl.totalAmount);
        System.assertEquals(testProduct, ctrl.selectedProduct);
        
        ctrl.goToShopping();
        System.assertEquals(0, ctrl.unitCount);
        System.assertEquals(null, ctrl.mail);
        System.assertEquals(null, ctrl.fName);
        System.assertEquals(null, ctrl.lName);
        //        System.assertEquals(null, ctrl.selectedProduct);
        
        System.assertEquals(0, ctrl.totalAmount);
        
        ctrl.selectedProduct = testProduct;
        System.assertNotEquals(null, ctrl.selectedProduct);
        
        //        ctrl.selectedProduct = [SELECT Id, Name, Image_URL__c, Product_Description__c, Product_Title__c, Units_Available__c, Unit__c FROM Product_Table__c WHERE Id =: id LIMIT 1];
    }
    @isTest
    private static void goToPages_test () {
        ProductTableController.goToBuy();
        ProductTableController.goToDetail();
    }
    
    @isTest
    private static void buy_test () {
        ProductTableController ctrl = new ProductTableController(); 
        Product_Table__c testProduct = [SELECT Id, Name, Image_URL__c, Product_Description__c, Product_Title__c, Units_Available__c, Unit__c FROM Product_Table__c LIMIT 1];
        Id testId = testProduct.Id;
        ctrl.id = testProduct.Id;
        ctrl.unitCount = 1;
        String testMail = 'test@test.com';
        ctrl.mail = testMail;
        ctrl.fName = 'fname';
        ctrl.lName = 'lname';
        ctrl.buy();
        List<Contact> testCnt = new List<Contact> ();
        testCnt = [SELECT Id, LastName, FirstName, Email FROM Contact WHERE Email =:testMail AND Email!= NULL];
        
        System.assertNotEquals(null, testCnt);
        System.assertEquals(1, testCnt.size());
        
        ctrl.contactId = testCnt[0].Id;
        ctrl.mail = testMail;
        ctrl.fName = 'fname';
        ctrl.lName = 'lname';        
        
        ctrl.id = testProduct.Id;
        ctrl.unitCount = 1;
        ctrl.buy();
        testProduct = [SELECT Id, Name, Units_Available__c, Unit__c FROM Product_Table__c WHERE Id =: testId LIMIT 1];
        Order_Table__c testOrder = [SELECT Id, Product__c, Units__c , Order_Amount__c , Contact__c FROM Order_Table__c LIMIT 1];
        System.assertEquals(1, testOrder.Units__c);
        System.assertEquals(testCnt[0].Id, testOrder.Contact__c);
        System.assertEquals(8, testProduct.Units_Available__c);
        
        ctrl.mail = 'fail';
        ctrl.buy();       
        ctrl.id = testId;
        ctrl.unitCount = 100;
        ctrl.mail = testMail;
        ctrl.fName = 'fname';
        ctrl.lName = 'lname';
        ctrl.buy();        
    }
}