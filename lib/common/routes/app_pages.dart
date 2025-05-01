import 'package:get/get.dart';
import 'package:picapool/common/routes/app_routes.dart';
import 'package:picapool/screens/buy_and_sell/buy_and_sell.dart';
import 'package:picapool/screens/buy_and_sell/features/product_details/product_details.dart';
import 'package:picapool/screens/cabs/share_cab_page.dart';
import 'package:picapool/screens/login/login_screen_imp.dart';
import 'package:picapool/screens/login/otp_screen.dart';
import 'package:picapool/screens/splash_screen/splash_screen.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';
// import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart';
import 'package:picapool/widgets/main_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreenImp(),
    ),
    GetPage(
      name: AppRoutes.otpScreen,
      page: () {
        final args = Get.arguments;
        if (args == null || !args.containsKey('phoneNumber')) {
          throw Exception("Missing required arguments for \"phoneNumber\"");
        }

        return OtpScreen(phoneNumber: args['phoneNumber']);
      },
    ),
    GetPage(name: AppRoutes.home, page: () => const MainScreen()),
    GetPage(
        name: AppRoutes.requestVicinity, page: () => const RequestVicinity()),
    GetPage(name: AppRoutes.cabListing, page: () => const ShareCabScreen()),
    GetPage(name: AppRoutes.createCab, page: () => const CreateLiveOffer()),
    GetPage(name: AppRoutes.buyAndSell, page: () => const BuyAndSell()),
    GetPage(
      name: AppRoutes.productInfo,
      page: () {
        final args = Get.arguments;
        if (args == null ||
            !args.containsKey('product') ||
            !args.containsKey('offer')) {
          throw Exception(
              "Missing required arguments for $AppRoutes.productInfo");
        }

        return ProductDetails(
          product: Get.arguments['product'],
          offer: Get.arguments['offer'],
          offersController: Get
              .arguments['offersController'], // will be extracted from bindings
        );
      },
    ),
  ];
}
