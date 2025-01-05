// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/screens/Products/products_homePage.dart';

extension StringExtension on String {
  String toTitleCase() {
    if (length <= 1) return toUpperCase();
    return split(' ').map((word) {
      if (word.length <= 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final ProductController productController = Get.find();
  late final String productId;

  @override
  void initState() {
    super.initState();
    productId = Get.arguments['productId'];
    // Fetch data after widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productController.getProductDetails(productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GetBuilder<ProductController>(
            builder: (productInstance) {
              return productInstance.individualProductsState ==
                      IndividualProductsState.productsLoaded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productInstance.productDetails.name.toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              fontFamily: "MontserratR"),
                        ),
                        const SizedBox(height: 5),
                        ElevatedButton(
                          onPressed: () {
                            // Define what happens when the button is tapped
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFFE9DA),
                            side: const BorderSide(color: Color(0xffFF6600)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // To minimize the button width
                              children: [
                                Text(
                                  'Go to site',
                                  style: TextStyle(
                                      fontFamily: "MontserratR",
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffFF6600)),
                                ),
                                SizedBox(
                                    width: 5), // Space between text and icon
                                Icon(Icons.arrow_circle_right_outlined,
                                    size: 20,
                                    color: Color(0xffFF6600)), // Icon with size
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              if (productInstance.productDetails.images !=
                                      null &&
                                  productInstance
                                      .productDetails.images!.isNotEmpty)
                                CarouselSlider(
                                  items: productInstance.productDetails.images!
                                      .map((imageUrl) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                print(
                                                    'Error loading image: $error');
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.error_outline,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  ),
                                                );
                                              },
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                      color: Colors.orange,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                  options: CarouselOptions(
                                    height: MediaQuery.of(context).size.width *
                                        9 /
                                        16,
                                    aspectRatio: 16 / 9,
                                    viewportFraction: 1.0,
                                    autoPlay: true,
                                    autoPlayInterval:
                                        const Duration(seconds: 3),
                                    autoPlayAnimationDuration:
                                        const Duration(milliseconds: 800),
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    enlargeCenterPage: true,
                                    enlargeFactor: 0.3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              'Selling price : ',
                              style: TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            ),
                            Text(
                              productInstance.productDetails.offerPrice
                                  .toString(),
                              style: const TextStyle(
                                  fontFamily: "MontserratM",
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.orange),
                            ),
                          ],
                        ),
                        Text(
                          '(MRP Rs. ${productInstance.productDetails.mrp.toString()} )',
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: "MontserratM",
                              color: Color(0xff565656)),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason for selling : ',
                              style: TextStyle(
                                  fontFamily: "MontserratR",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                              productInstance.productDetails.attributes
                                      ?.reasonForSell ??
                                  "N/A",
                              style: TextStyle(
                                  fontFamily: "MontserratR",
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'Description - ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: "MontserratR",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          productInstance.productDetails.description.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "MontserratR",
                              color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: "MontserratR",
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        if (productInstance.productDetails.attributes !=
                            null) ...[
                          Builder(
                            builder: (context) {
                              // Convert Attributes class to Map using toJson()
                              final attributes = productInstance
                                  .productDetails.attributes!
                                  .toJson();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: attributes.entries
                                    .where((entry) => entry.value != null)
                                    .map((entry) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            entry.key
                                                .replaceAll('_', ' ')
                                                .toTitleCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: "MontserratR",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            entry.value?.toString() ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: "MontserratR",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ],
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: LinearProgressIndicator(color: Colors.orange),
                      ),
                    );
            },
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProductsHomepage(
                        currentIndex: 1,
                      )),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "MontserratSB"),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
