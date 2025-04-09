import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/models/product_model.dart';

class SelectedProductPage extends StatefulWidget {
  final Product product;

  const SelectedProductPage({
    super.key,
    required this.product,
  });

  @override
  State<SelectedProductPage> createState() => _SelectedProductPageState();
}

class _SelectedProductPageState extends State<SelectedProductPage> {
  final List<String> imgList = [
    'assets/images/Controller.png', // Replace with your image asset paths
    'assets/images/Controller.png',
    'assets/images/Controller.png',
  ];

  int _current = 0;

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
          'Offer',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: "MontserratM",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 250,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        viewportFraction: 1,
                        autoPlay: true,
                        clipBehavior: Clip.hardEdge,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      items: [
                        if (widget.product.images.isEmpty)
                          Image.asset(
                            width: double.infinity,
                            'assets/images/Controller.png',
                            fit: BoxFit.cover,
                          )
                        else
                          CachedNetworkImage(
                            width: double.infinity,
                            imageUrl: widget.product.images.first,
                            fit: BoxFit.cover,
                          )
                      ],
                      
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.product.images.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? const Color.fromRGBO(0, 0, 0, 0.9)
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                  text: 'MRP : ₹ ${widget.product.mrp ?? "Not Available"}',
                  style: const TextStyle(
                      fontFamily: "MontserratM",
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                      decoration: TextDecoration.lineThrough),
                  children: [
                    if (widget.product.offerPrice != null)
                      TextSpan(
                        text: " ${widget.product.offerPrice}",
                        style: const TextStyle(
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ]),
            ),
            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(
                fontFamily: "MontserratM",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.product.description,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "MontserratR",
                color: Colors.black,
              ),
            ),
            // const Text(
            //   'Read more',
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontFamily: "MontserratM",
            //     color: Colors.orange,
            //   ),
            // ),
            const SizedBox(height: 20),
            // const Text(
            //   'Details',
            //   style: TextStyle(
            //     fontSize: 16,
            //     fontFamily: "MontserratM",
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // const SizedBox(height: 10),
            // Text(
            //   widget.product. ?? "Product Details",
            //   style: const TextStyle(
            //     fontSize: 14,
            //     fontFamily: "MontserratM",
            //     color: Colors.black,
            //   ),
            // ),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Features',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratM",
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //         Text(
            //           'Built-In Microphone',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratR",
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           '',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratM",
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //         Text(
            //           'Headset Jack',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratR",
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle See Offers action
            Get.back();
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'See More Offers',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: "MontserratSB",
            ),
          ),
        ),
      ),
    );
  }
}
