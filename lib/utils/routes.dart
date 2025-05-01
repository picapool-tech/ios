import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/middlewares/analytics_middleware.dart';
import 'package:picapool/controllers/bindings/brand_bindings.dart';
import 'package:picapool/controllers/bindings/category_bindings.dart';
import 'package:picapool/controllers/bindings/live_offer_bindings.dart';
import 'package:picapool/controllers/bindings/product_bindings.dart';
import 'package:picapool/screens/Medical/medical_first_page.dart';
import 'package:picapool/screens/Products/products_home_page.dart';
import 'package:picapool/screens/buy_and_sell/buy_and_sell.dart';
import 'package:picapool/screens/cabs/CreateCab.dart';
import 'package:picapool/screens/cabs/share_cab_page.dart';
import 'package:picapool/screens/create_cab.dart';
import 'package:picapool/screens/create_pool.dart';
import 'package:picapool/screens/middle_button/middle_button.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
import 'package:picapool/screens/splash_screen/splash_screen.dart';
import 'package:picapool/screens/trekking/trekking_page.dart';
import 'package:picapool/screens/turf/turf_first_page.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';
// import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';
import 'package:picapool/widgets/brands/brand_listing.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart';
import 'package:picapool/widgets/main_screen.dart';
import 'package:picapool/widgets/product_lists/product_lists.dart';
import 'package:picapool/widgets/sell/sell_confirmation_page.dart';
import 'package:picapool/widgets/sell/sell_form.dart';
import 'package:picapool/widgets/sell/sell_form_two.dart';

class GetRoutes {
  static const String splash = '/';
  static const String onBoarding = '/onBoarding';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String forgotPassword = '/forgotPassword';
  static const String profileDetails = '/profileDetails';

  static const String productsListPage = '/productsList';
  static const String brandListPage = '/brandList';
  static const String categoryPage = '/categoryPage';
  static const String sellProductsFormPage = '/sellProductsForm';
  static const String sellProductsSecondFormPage = '/sellProductsSecondForm';
  static const String sellProductsConfirmationPage =
      '/sellProductsConfirmation';
  static const String sellProductsUserFormPage = '/sellProductsUserForm';
  static const String getLiveOffer = '/getLiveOffer';
  static const String createLiveOffer = '/createLiveOffer';

  static const String search = '/search';

  static const String testRoute = '/testRoute';

  // Main routes
  static const String home = '/homePage';
  static const String publicChat = '/publicChat';
  static const String createCabPool = '/createCabPool';
  static const String createCabShare = '/createCabShare';
  static const String createPool = '/createPool';
  static const String poolOffers = '/poolOffers';
  static const String requestVicinity = '/requestVicinity';
  static const String shareCabScreen = '/shareCabScreen';
  static const String buyAndSell = '/buyAndSell';
  static const String trekkingPage = '/trekkingPage';
  static const String medicalAttentionPage = '/medicalAttentionPage';
  static const String turfPage1 = '/turfPage1';

  static const String productsWithBrandBase = '/products/:brandName';
  // Define the routes list using a more concise structure
  static final List<GetPage<dynamic>> routes = [
    _buildRoute(
      name: splash,
      page: () => const SplashScreen(),
      checkWithNetwork: false,
    ),
    // _buildRoute(
    //     name: publicChat,
    //     page: const SelectProductsFromOffer(),
    //     checkWithNetwork: false),
    _buildRoute(
        name: createCabPool,
        page: () => const CreateCabPoolScreen(),
        checkWithNetwork: false),
    _buildRoute(
        name: createCabShare,
        page: () => const CreateCabShareScreen(),
        checkWithNetwork: false),
    _buildRoute(
        name: createCabShare,
        page: () => const CreatePoolScreen(),
        checkWithNetwork: false),

    // Products
    _buildRoute(
      name: productsListPage,
      page: () => const ProductListsPage(),
      binding: ProductBindings(),
    ),
    // Brands
    _buildRoute(
      name: brandListPage,
      page: () => const BrandListsPage(),
      binding: BrandBindings(),
    ),
    // Category
    _buildRoute(
      name: categoryPage,
      page: () => const CategorySelectionPage(),
      binding: CategoryBindings(),
    ),
    _buildRoute(
      name: sellProductsFormPage,
      page: () => const SellForm(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: sellProductsSecondFormPage,
      page: () => const SellFormTwo(),
      binding: CategoryBindings(),
    ),
    _buildRoute(
      name: sellProductsConfirmationPage,
      page: () => const SellConfirmationPage(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: sellProductsUserFormPage,
      page: () => const CategorySelectionPage(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: createLiveOffer,
      page: () => const CreateLiveOffer(),
      binding: LiveOfferBindings(),
    ),
    _buildRoute(
      name: poolOffers,
      page: () => const PoolOffersScreen(),
    ),
    _buildRoute(
      name: requestVicinity,
      page: () => const RequestVicinity(),
    ),
    _buildRoute(
      name: shareCabScreen,
      page: () => const ShareCabScreen(),
    ),
    _buildRoute(
      name: buyAndSell,
      page: () => const BuyAndSell(),
    ),
    _buildRoute(
      name: trekkingPage,
      page: () => const TrekkingPage(),
    ),
    _buildRoute(
      name: medicalAttentionPage,
      page: () => const MedicalAttentionPage(),
    ),
    _buildRoute(
      name: turfPage1,
      page: () => const TurfPage1(),
    ),
    _buildRoute(
      name: productsWithBrandBase,
      page: () {
        final brandName = Get.parameters['brandName']!;
        return ProductsHomepage(brandName: brandName);
      },
    ),
  ];

  static String productsWithBrand(String brandName) => '/products/$brandName';

  /// Helper method to build routes with an optional network check
  static GetPage<dynamic> _buildRoute({
    required String name,
    required Widget Function() page,
    Bindings? binding,
    bool checkWithNetwork = true,
  }) {
    return GetPage<dynamic>(
      name: name,
      // TODO: Implement check with network and network controller
      page: page,
      // page: () => checkWithNetwork ? CheckInternet(page: page) : page(),
      binding: binding,
      middlewares: [AnalyticsMiddleware()],
    );
  }
}
