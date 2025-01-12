import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/bindings/brand_bindings.dart';
import 'package:picapool/controllers/bindings/category_bindings.dart';
import 'package:picapool/controllers/bindings/live_offer_bindings.dart';
import 'package:picapool/controllers/bindings/product_bindings.dart';
import 'package:picapool/screens/Public%20Chat/publicChatScreen.dart';
import 'package:picapool/screens/cabs/CreateCab.dart';
import 'package:picapool/screens/create_cab.dart';
import 'package:picapool/screens/create_pool.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';
import 'package:picapool/widgets/brands/brand_listing.dart';
import 'package:picapool/widgets/cab/create_live_offer.dart';
import 'package:picapool/widgets/product_lists/product_lists.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
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

  // Define the routes list using a more concise structure
  static final List<GetPage<dynamic>> routes = [
    _buildRoute(
        name: splash, page: const NewBottomBar(), checkWithNetwork: false),
    _buildRoute(
        name: publicChat,
        page: const PublicChatPage(),
        checkWithNetwork: false),
    _buildRoute(
        name: createCabPool,
        page: const CreateCabPoolScreen(),
        checkWithNetwork: false),
    _buildRoute(
        name: createCabShare,
        page: const CreateCabShareScreen(),
        checkWithNetwork: false),
    _buildRoute(
        name: createCabShare,
        page: const CreatePoolScreen(),
        checkWithNetwork: false),

    // Products
    _buildRoute(
      name: productsListPage,
      page: ProductListsPage(),
      binding: ProductBindings(),
    ),
    // Brands
    _buildRoute(
      name: brandListPage,
      page: const BrandListsPage(),
      binding: BrandBindings(),
    ),
    // Category
    _buildRoute(
      name: categoryPage,
      page: const CategorySelectionPage(),
      binding: CategoryBindings(),
    ),
    _buildRoute(
      name: sellProductsFormPage,
      page: const SellForm(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: sellProductsSecondFormPage,
      page: const SellFormTwo(),
      binding: CategoryBindings(),
    ),
    _buildRoute(
      name: sellProductsConfirmationPage,
      page: const SellConfirmationPage(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: sellProductsUserFormPage,
      page: const CategorySelectionPage(),
      binding: ProductBindings(),
    ),
    _buildRoute(
      name: createLiveOffer,
      page: const CreateLiveOffer(),
      binding: LiveOfferBindings(),
    ),
  ];

  /// Helper method to build routes with an optional network check
  static GetPage<dynamic> _buildRoute({
    required String name,
    required Widget page,
    Bindings? binding,
    bool checkWithNetwork = true,
  }) {
    return GetPage<dynamic>(
      name: name,
      // TODO: Implement check with network and network controller
      page: () => checkWithNetwork ? page : page,
      // page: () => checkWithNetwork ? CheckInternet(page: page) : page(),
      binding: binding,
    );
  }
}
