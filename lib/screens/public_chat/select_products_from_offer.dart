import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/products/send_to_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectProductsFromOffer extends StatefulWidget {
  final List<Product> products;
  final String offerName;

  const SelectProductsFromOffer({
    super.key,
    required this.products,
    required this.offerName,
  });

  @override
  State<SelectProductsFromOffer> createState() =>
      _SelectProductsFromOfferState();
}

class _SelectProductsFromOfferState extends State<SelectProductsFromOffer> {
  late List<bool> selectedIndex;
  final UserController _userController = Get.find<UserController>();

  bool areProductsSelected() {
    return selectedIndex.contains(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.offerName,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Products to Pool",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "MontserratM",
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: widget.products.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  mainAxisExtent: 200,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  var product = widget.products[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex[index] = !selectedIndex[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: selectedIndex[index]
                              ? Colors.orange
                              : Colors.grey.shade300,
                          width: selectedIndex[index] ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip
                            .hardEdge, // This allows the checkbox to go out of bounds if needed
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 120,
                                ),
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  color: Colors.white,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Center(
                                  child: (product.images.isEmpty)
                                      ? Image.asset(
                                          "assets/images/ic_launcher.png",
                                          fit: BoxFit.fill,
                                        )
                                      : CachedNetworkImage(
                                          width: double.infinity,
                                          imageUrl: product.images.first,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "₹ ${product.offerPrice}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "MontserratM",
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 5, // Adjusted to stay within bounds
                            right: 5, // Adjusted to stay within bounds
                            child: Checkbox(
                              value: selectedIndex[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedIndex[index] = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              activeColor: Colors.orange,
                              side: const BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: areProductsSelected()
                    ? () {
                        _sendToWhatsApp();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "MontserratM",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = List.filled(widget.products.length, false);
  }

  void _sendToWhatsApp() async {
    var listOfProducts = widget.products
        .where((product) => selectedIndex[widget.products.indexOf(product)])
        .toList();
    var waLink = generateWhatsAppLink(
      _userController.user!.name!,
      _userController.user!.id,
      listOfProducts,
    );

    log(waLink);

    if (!await launchUrl(Uri.parse(waLink))) {
      Get.snackbar("Error", "Could not get WhatsApp link");
    }
  }
}
