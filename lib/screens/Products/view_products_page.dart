import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/Products/selected_product_page.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Deals',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            // Container(
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: TextField(
            //     decoration: InputDecoration(
            //       hintText: 'Find "$partnerName" deals',
            //       hintStyle: const TextStyle(
            //         color: Color(0xff000000),
            //         fontFamily: "MontserratR",
            //       ),
            //       prefixIcon: const Icon(Icons.search, color: Colors.orange),
            //       border: InputBorder.none,
            //       contentPadding:
            //           const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 20),
            // Products Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 0.75,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 16,
                  mainAxisExtent: 200,
                ),
                itemCount: products.length, // Number of items
                itemBuilder: (context, index) {
                  return _buildProductCard(context, index);
                },
              ),
            ),
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
        Get.to(() => SelectedProductPage(
              product: product,
            ));
        // // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const SelectedProductPage(),
        //   ), // Navigate to SelectedProductPage
        // );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
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
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'MontserratR',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MontserratM',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹ ${product.offerPrice}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MontserratM',
                          color: Colors.black,
                        ),
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
