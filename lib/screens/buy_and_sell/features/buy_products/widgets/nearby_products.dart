import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/empty_states.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/nearby_products_item.dart';
import 'package:picapool/screens/buy_and_sell/values/filter_data.dart';

class NearbyProducts extends StatefulWidget {
  final FilterDataEnum? filterData;

  const NearbyProducts({
    super.key,
    this.filterData,
  });

  @override
  State<NearbyProducts> createState() => _NearbyProductsState();
}

class _NearbyProductsState extends State<NearbyProducts> {
  final ProductsController _productsController = Get.find<ProductsController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _productsController.searchProducts(),
      child: GetBuilder(
        init: _productsController,
        initState: (state) {
          _productsController.searchProducts();
        },
        builder: (productsController) {
          if (productsController
                  .getLoadingState(ProductLoadingEnums.searchProducts)
                  .value &&
              productsController.searchedProducts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (productsController.searchedProducts.isEmpty) {
            return productsController.lastSearchQuery.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "No results for '${productsController.lastSearchQuery}'",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : const EmptyStates(); // Default empty state
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _productsController.searchedProducts.length,
            itemBuilder: (context, index) {
              Product? product = _productsController
                          .searchedProducts[index].products?.isNotEmpty ==
                      true
                  ? _productsController.searchedProducts[index].products!.first
                  : null;
              if (product == null) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "No product available",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return NearbyProductsItem(
                product: product,
                offer: _productsController.searchedProducts[index],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productsController.searchProducts();
    });
  }
}
