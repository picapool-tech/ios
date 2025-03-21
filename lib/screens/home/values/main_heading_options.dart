import 'package:picapool/models/main_heading_options_data.dart';
import 'package:picapool/screens/buy_and_sell/buy_and_sell.dart';
import 'package:picapool/screens/cabs/share_cab_page.dart';
import 'package:picapool/screens/medical/medical_first_page.dart';
import 'package:picapool/screens/products/products_home_page.dart';
import 'package:picapool/screens/trekking/trekking_page.dart';
import 'package:picapool/screens/turf/turf_first_page.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';

class MainHeadingOptions {
  static const List<MainHeadingOptionsData> poolingCategories = [
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 39.png",
      text: "Food",
      destinationPage: ProductsHomepage(brandName: "Food"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 41.png",
      text: "Apparel",
      destinationPage: ProductsHomepage(brandName: "Apparel"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 44.png",
      text: "Entertain",
      destinationPage: ProductsHomepage(brandName: "Entertain"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 43.png",
      text: "Medical",
      destinationPage: ProductsHomepage(brandName: "Medical"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 42.png",
      text: "Electronics",
      destinationPage: ProductsHomepage(brandName: "Electronics"),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/homepagebottomassets/image 46.png",
      text: "Music",
      destinationPage: ProductsHomepage(brandName: "Music"),
    ),
  ];

  static const List<MainHeadingOptionsData> headingOptions = [
    MainHeadingOptionsData(
      imagePath: "assets/images/request_vicinity.png",
      text: "Ask Around",
      destinationPage: RequestVicinity(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/share_a_cab.png",
      text: "Share a cab",
      destinationPage: ShareCabScreen(),
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/buy_sell.png",
      text: "Buy and sell",
      destinationPage: BuyAndSell(),
    ),
    // Item(imagePath: "assets/images/medical_help.png", text: "Medical help", destinationPage: RequestVicinityPage()),
    MainHeadingOptionsData(
      imagePath: "assets/images/trekking.png",
      text: "Trekking",
      destinationPage: TrekkingPage(),
      isDisabled: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/medical_help.png",
      text: "Medical help",
      destinationPage: MedicalAttentionPage(),
      isDisabled: true,
    ),
    MainHeadingOptionsData(
      imagePath: "assets/images/share_turf.png",
      text: "Share a turf",
      destinationPage: TurfPage1(),
      isDisabled: true,
    ),

    // Add more items as needed
  ];
}
