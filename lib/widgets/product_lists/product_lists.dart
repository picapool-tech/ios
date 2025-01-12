import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/models/offers/search_offer_payload.dart';
import 'package:picapool/models/product_grid_model.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
import 'package:picapool/widgets/home/location_widget.dart';

class ProductListsPage extends StatefulWidget {
  const ProductListsPage({super.key});

  @override
  State<ProductListsPage> createState() => ProductListsPageState();
}

class ProductListsPageState extends State<ProductListsPage> {
  ProductController get productController => Get.find();

  @override
  void initState() {
    super.initState();
    productController.searchOffers(
      SearchOfferPayload(
        chats: true,
        loc: Loc(
          lat: 12.92,
          lng: 77.64,
        ),
        products: true,
        radius: 500,
      )
    );
    // Add listener for search
    _productSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _productSearchController.removeListener(_onSearchChanged);
    _productSearchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _productSearchController.text.toLowerCase();
    productController.filterProducts(query);
  }

  //TODO: Implement location services
  String currentLocation = "6th st, Connaught place, New Delhi, India";

  // List of categories and corresponding icons from assets
  // final List<Map<String, String>> categories = [
  //   {"name": "Electronics", "icon": "assets/icons/electronics.svg"},
  //   {"name": "Clothes", "icon": "assets/icons/clothes.svg"},
  //   {"name": "Furniture", "icon": "assets/icons/furniture.svg"},
  //   {"name": "Electronics", "icon": "assets/icons/electronics.svg"},
  //   {"name": "Clothes", "icon": "assets/icons/clothes.svg"},
  //   {"name": "Furniture", "icon": "assets/icons/furniture.svg"},
  // ];

  void _updateLocation(String location) {
    setState(() {
      currentLocation = location;
    });
  }

  final TextEditingController _productSearchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: Colors.orange,
          elevation: 7,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(36)),
                border: Border.all(
                    color: Colors.white, width: 2, style: BorderStyle.solid)),
            child: const Icon(
              Icons.label_important_outlined,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategorySelectionPage(),
              ),
            );
            // Get.toNamed(
            //   GetRoutes.categoryPage,
            // );
          }),
      body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GetBuilder<ProductController>(
              builder: (ProductController productInstance) {
            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 50),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: LocationWidget(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                const SvgIcon(
                                  'assets/icons/search_icon.svg',
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: _productSearchController,
                                    enabled: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Find Offers and Brands',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "MontserratR",
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                if (_productSearchController.text.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      _productSearchController.clear();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(children: <Widget>[
                      Expanded(
                          child: Divider(
                        indent: 50,
                        color: Color(0xffFF8D41),
                      )),
                      Text(
                        "  Products near you  ",
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "MontserratM",
                            fontSize: 14),
                      ),
                      Expanded(
                          child: Divider(
                        endIndent: 50,
                        color: Color(0xffFF8D41),
                      )),
                    ]),
                    const SizedBox(height: 20),
                    const Expanded(child: ProductGrid())
                  ],
                ),
              ],
            );
          })),
    );
  }
}
