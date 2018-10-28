public class DetailProduct {
    public static PageReference goToBuy () {
        PageReference buyProduct = new PageReference('/apex/BuyProduct');
        return buyProduct;
    }
}