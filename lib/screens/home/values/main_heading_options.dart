import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/utils/routes.dart';

class MainHeadingOptions {
  static List<MainHeadingOptionsData> poolingCategories = [
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 39.png",
      text: "Food",
      routePath: GetRoutes.productsWithBrand("Food"), //Ex: '/products/Food'
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 41.png",
      text: "Apparel",
      routePath: GetRoutes.productsWithBrand("Apparel"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 44.png",
      text: "Entertain",
      routePath: GetRoutes.productsWithBrand("Entertain"),
    ),
    // MainHeadingOptionsData(
    //   imagePath: "assets/homepagebottomassets/image 43.png",
    //   text: "Medical",
    //   routePath: GetRoutes.productsWithBrand("Medical"),
    // ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 42.png",
      text: "Electronics",
      routePath: GetRoutes.productsWithBrand("Electronics"),
    ),
    // MainHeadingOptionsData(
    //   imagePath: "assets/homepagebottomassets/image 46.png",
    //   text: "Music",
    //   routePath: GetRoutes.productsWithBrand("Music"),
    // ),
  ];

  static const List<MainHeadingOptionsData> headingOptions = [
    MainHeadingOptionsData(
      imagePath: "assets/images/request_vicinity.png",
      text: "Ask Around",
      routePath: GetRoutes.requestVicinity,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/share_a_cab.png",
      text: "Share a cab",
      routePath: GetRoutes.shareCabScreen,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/buy_sell.png",
      text: "Buy and sell",
      routePath: GetRoutes.buyAndSell,
    ),
    // Item(imagePath: "assets/images/medical_help.png", text: "Medical help", destinationPage: RequestVicinityPage()),
    MainHeadingOptionsData(
      imagePath: "assets/images/trekking.png",
      text: "Trekking",
      routePath: GetRoutes.trekkingPage,
      isDisabled: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/medical_help.png",
      text: "Medical help",
      routePath: GetRoutes.medicalAttentionPage,
      isDisabled: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/share_turf.png",
      text: "Share a turf",
      routePath: GetRoutes.turfPage1,
      isDisabled: true,
    ),
    // MainHeadingOptionsData(
    //   imagePath: "assets/images/live_pooling/live_pooling_icon.png",
    //   text: "Live Pooling",
    //   routePath: GetRoutes.livePooling,
    //   isDisabled: true,
    // ),

    // Add more items as needed
  ];
}
