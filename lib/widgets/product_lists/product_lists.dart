import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/features/location/location_provider.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/models/offers/location_entity.dart';
import 'package:picapool/models/offers/search_offer_payload.dart';
import 'package:picapool/models/product_grid_model.dart';
import 'package:picapool/screens/sell/select_category_page.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/location_widget.dart';

class ProductListsPage extends StatefulWidget {
  const ProductListsPage({super.key});

  @override
  State<ProductListsPage> createState() => ProductListsPageState();
}

class ProductListsPageState extends State<ProductListsPage> {
  Position? currentPosition;
  LatLng? selectedCoordinates;
  final TextEditingController _productSearchController =
      TextEditingController();
  final LocationController _locationController = Get.find<LocationController>();

  // Radius options
  final List<Map<String, int>> radiusOptions = [
    {'1km': 1000},
    {'3km': 3000},
    {'5km': 5000},
  ];

  int selectedRadius = 1000; // Default radius
  ProductController get productController => Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppTheme.light.primaryColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategorySelectionPage(),
                ),
              );
            },
            elevation: 2,
            shape: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(36)),
                  border: Border.all(
                      color: Colors.white, width: 2, style: BorderStyle.solid)),
              child: const Icon(
                Icons.label_important_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sell Now',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const LocationWidget(
                            color: Colors.black,
                          ),
                          // Radius selector dropdown
                          DropdownButton<int>(
                            value: selectedRadius,
                            items: radiusOptions.map((Map<String, int> option) {
                              String label = option.keys.first;
                              int value = option.values.first;
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: "MontserratR",
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedRadius = newValue;
                                });
                                _searchWithLocation(); // Trigger new search with updated radius
                              }
                            },
                            dropdownColor: Colors.white,
                            icon: const Icon(Icons.radio_button_checked,
                                color: Colors.orange),
                            underline: Container(
                              height: 2,
                              color: Colors.orange,
                            ),
                          ),
                        ],
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productSearchController.removeListener(_onSearchChanged);
    _productSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeLocationAndSearch();
    _productSearchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchLocation() async {
    if (_locationController.state.value.location == null) {
      await _locationController.getLocation();
    }
    var location = _locationController.state.value.location;
    if (location == null) {
      debugPrint("NULL LOCATION : VICINITY");
      Get.snackbar(
        'Error',
        'Failed to get current location.',
        snackStyle: SnackStyle.GROUNDED,
      );
      return;
    }

    setState(() {
      selectedCoordinates = LatLng(location.latitude, location.longitude);

      // Not needed in this page
      // if (_controller != null && !_isMapInitialized) {
      //   _controller!.animateCamera(
      //     CameraUpdate.newCameraPosition(
      //       CameraPosition(
      //         target: selectedCoordinates!,
      //         zoom: 16.0,
      //       ),
      //     ),
      //   );
      //   _isMapInitialized = true;
      // }
    });
  }

  Future<void> _initializeLocationAndSearch() async {
    _fetchLocation();
    if (selectedCoordinates != null) {
      _searchWithLocation();
    } else {
      _searchWithCurrentLocation();
    }
  }

  void _onSearchChanged() {
    final query = _productSearchController.text.toLowerCase();
    productController.filterProducts(query);
  }

  void _searchWithCurrentLocation() {
    if (currentPosition != null) {
      productController.searchOffers(
        SearchOfferPayload(
          chats: true,
          loc: Loc(
            lat: currentPosition!.latitude,
            lng: currentPosition!.longitude,
          ),
          products: true,
          radius: selectedRadius,
        ),
      );
    }
  }

  void _searchWithLocation() {
    var tagController = Get.find<TagController>();
    var tag = tagController.getTagsByTagName("Buy");
    if (tag == null) {
      debugPrint("Tag not found");
    }
    if (selectedCoordinates != null && tag != null) {
      productController.searchOffers(
        SearchOfferPayload(
          chats: true,
          loc: Loc(
            lat: selectedCoordinates!.latitude,
            lng: selectedCoordinates!.longitude,
          ),
          products: true,
          tagIds: [tag.id],
          radius: selectedRadius,
        ),
      );
    }
  }
}
