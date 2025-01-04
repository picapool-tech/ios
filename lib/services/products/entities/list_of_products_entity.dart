import 'package:picapool/services/products/entities/product_entity.dart';

class ProductsList {
  List<ProductData> productsList;
  int count;
  ProductsList({
    required this.productsList,
    required this.count,
  });

  factory ProductsList.fromJson(Map<String, dynamic> json) => ProductsList(
        productsList:
            List<ProductData>.from(json["data"].map((x) => ProductData.fromJson(x))),
        count: List<ProductData>.from(json["data"].map((x) => ProductData.fromJson(x))).length,
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(productsList.map((x) => x.toJson())),
        "count": count,
       
      };
}
