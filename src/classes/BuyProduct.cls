public class BuyProduct {
    public static PageReference goToBuy () {
        PageReference buyProduct = new PageReference('/apex/BuyProduct');
        return buyProduct;
    }
}