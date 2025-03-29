import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';


enum ProductConditionEnums {
  newCondition(name: "New", assestLocation: "assets/icons/new.svg"),
  used(name: "Gentle used", assestLocation: "assets/icons/used.svg"),
  gentelUsed(name: "Used", assestLocation: "assets/icons/used.svg");

  final String name;
  final String assestLocation;

  const ProductConditionEnums({
    required this.name,
    required this.assestLocation,
  });
}

enum ProductLoadingEnums {
  getAllProducts,
  searchProducts,
  createProduct,
  updateProduct;
}
