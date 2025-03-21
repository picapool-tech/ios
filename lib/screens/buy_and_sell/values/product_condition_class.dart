final productBooksCondition = [
  ProductCondition(name: 'New', assetLocation: "assets/icons/new.svg"),
  ProductCondition(name: 'Gentle Used', assetLocation: "assets/icons/used.svg"),
  ProductCondition(name: 'Used', assetLocation: "assets/icons/used.svg"),
];

final productClothsCondition = [
  ProductCondition(name: 'New', assetLocation: "assets/icons/new.svg"),
  ProductCondition(name: 'Gentle Used', assetLocation: "assets/icons/new.svg"),
  ProductCondition(name: 'Used', assetLocation: "assets/icons/used.svg"),
];

var productClothSize = [
  ClothesSize(name: "xs"),
  ClothesSize(name: "s"),
  ClothesSize(name: "m"),
  ClothesSize(name: "l"),
  ClothesSize(name: "xl"),
];

final productElectronicsCondition = [
  ProductCondition(name: 'New', assetLocation: "assets/icons/new.svg"),
  ProductCondition(name: 'Used', assetLocation: "assets/icons/used.svg"),
  ProductCondition(name: 'Repaired', assetLocation: "assets/icons/used.svg"),
];

class BookCondition extends ProductCondition {
  BookCondition({
    required super.name,
    required super.assetLocation,
  });
}

class ClothesSize extends ProductCondition {
  ClothesSize({
    required super.name,
    super.assetLocation,
  });
}

class ProductCondition {
  final String name;
  final String? assetLocation;

  ProductCondition({
    required this.name,
    this.assetLocation,
  });
}
