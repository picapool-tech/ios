import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/Products/selected_product_page.dart';
import 'package:picapool/utils/theme.dart';

class ViewProductsPage extends StatelessWidget {
  final List<Product> products;
  final String partnerName;

  const ViewProductsPage({
    super.key,
    required this.products,
    required this.partnerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Deals',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        centerTitle: false,
        actions: const [
          // Padding(
          //   padding: EdgeInsets.only(right: 16.0),
          //   child: CircleAvatar(
          //     backgroundImage: AssetImage(
          //       'assets/avatar.jpg',
          //     ), // Replace with your image asset path
          //   ),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (products.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 9 / 10,
                    mainAxisSpacing: 25,
                    crossAxisSpacing: 2,
                    mainAxisExtent: 220,
                  ),
                  itemCount: products.length, // Number of items
                  itemBuilder: (context, index) {
                    return _buildProductCard(context, index);
                  },
                ),
              )
            else
              const Center(
                child: Text(
                  "No products available at this moment.",
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final product = products[index];
    const isSoldOut = false; // Replace with your logic

    return InkWell(
      onTap: () {
        Get.to(
          () => SelectedProductPage(
            product: product,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.currentTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.currentTheme.shadowColor.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                    offset: const Offset(0, 3)),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: (product.images.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: product.images.first,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/dominos/Onion Pizza.png",
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${partnerName.split(" ").firstOrNull ?? partnerName} Offer',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${product.offerPrice}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // if (isSoldOut)
          //   Positioned(
          //     top: 0,
          //     right: 0,
          //     bottom: 0,
          //     left: 0,
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.6),
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       child: const Center(
          //         child: Text(
          //           'SOLD OUT',
          //           style: TextStyle(
          //             color: Colors.white,
          //             fontFamily: 'MontserratM',
          //             fontSize: 16,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
