import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/books.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/clothes.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/electronics.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/furniture.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/others.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/sports.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/selling_category/vehicle.dart';

enum FilterDataEnum {
  books(
    title: "Books",
    assetImage: "assets/images/buy_and_sell/",
    destination: CreateBookProducts(),
  ),
  clothes(
    title: "Clothes",
    assetImage: "assets/images/buy_and_sell/",
    destination: CreateClothesProduct(),
  ),
  electronics(
    title: "Electronics",
    assetImage: "assets/images/buy_and_sell/",
    destination: Electronics(),
  ),
  furniture(
    title: "Furniture",
    assetImage: "assets/images/buy_and_sell/",
    destination: CreateFurnitureProduct(),
  ),
  sports(
    title: "Sports",
    assetImage: "assets/images/buy_and_sell/",
    destination: Sports(),
  ),
  vehicle(
    title: "Vehicle",
    assetImage: "assets/images/buy_and_sell/",
    destination: VehicleCategory(),
  ),
  other(
    title: "Other",
    assetImage: "assets/images/buy_and_sell/",
    destination: CreateOthersCategoryProduct(),
  );

  final String assetImage;
  final String title;
  final Widget destination;

  const FilterDataEnum({
    required this.title,
    required this.assetImage,
    required this.destination,
  });
}
