import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/offers/offers_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/Public%20Chat/select_products_from_offer.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';

class BrandOfferModel {
  final String title;
  final String description;
  final String imageUrl;
  final bool remoteImageUrl;

  BrandOfferModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.remoteImageUrl = true,
  });

  factory BrandOfferModel.fromJson(Map<String, dynamic> json) {
    return BrandOfferModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class OfferDetailsPage extends StatefulWidget {
  final Offer offer;

  const OfferDetailsPage({
    super.key,
    required this.offer,
  });

  @override
  State<OfferDetailsPage> createState() => _OfferDetailsPageState();
}

class _OfferDetailsPageState extends State<OfferDetailsPage> {
  final OffersController _offersController = Get.find<OffersController>();

  Future<Offer?> offerDetails = Future.value(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () async {
            // Handle pooling action
            if (widget.offer.top) {
              var offerValue = await offerDetails;
              if (offerValue?.products == null ||
                  offerValue!.products!.isEmpty) {
                Get.snackbar(
                  'No products in this offer',
                  'Please try again later',
                  snackPosition: SnackPosition.TOP,
                );
                return;
              }
              Get.to(
                () => SelectProductsFromOffer(
                  products: offerValue.products!,
                  offerName: widget.offer.name,
                ),
              );
              return;
            }
            var model = BrandOfferModel(
                title: widget.offer.name,
                description: widget.offer.desc,
                imageUrl: widget.offer.images.firstOrNull ?? "",
                remoteImageUrl: widget.offer.images.firstOrNull != null);
            Get.to(() => const RequestVicinity(), arguments: {
              "brands": {
                ...model.toJson(),
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
          ),
          child: Text(
            (widget.offer.top) ? 'Select Products' : 'Start Pooling',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'MontserratM',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.offer.name,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: () {
                if (widget.offer.images.isEmpty) {
                  return Image.asset(
                    'assets/dominos/OfferImag1.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return CachedNetworkImage(
                    imageUrl: widget.offer.images.first,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
              }(),
              // Image.asset(
              //   width: double.infinity,
              //   'assets/dominos/OfferImag1.png', // Replace with your image asset path
              //   fit: BoxFit.cover,
              // ),
            ),
            const SizedBox(height: 20),
            // View Details Text
            const Text(
              'View Details',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'MontserratM',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _productDetailsList(),
            const SizedBox(height: 20),
            Text("""
${widget.offer.desc}
""")
            // Product 1 Details
            // _buildProductDetail(
            //   imagePath: 'assets/images/image 80.png',
            //   title: 'Margherita Pizza',
            //   display: '6.7" Fluid AMOLED, 120Hz',
            //   processor: 'Snapdragon 8 Gen 2',
            //   ram: '12GB/16GB',
            //   storage: '256GB/512GB',
            //   camera: '50MP+48MP+8MP rear, 32MP front',
            //   price: '₹ 89',
            //   originalPrice: '₹ 104',
            // ),
            // const SizedBox(height: 20),
            // // Product 2 Details
            // _buildProductDetail(
            //   imagePath: 'assets/images/image 82.png',
            //   title: 'OnePlus 10 Pro :',
            //   display: '6.7" Fluid AMOLED, 120Hz',
            //   processor: 'Snapdragon 8 Gen 1',
            //   ram: '12GB/16GB',
            //   storage: '256GB/512GB',
            //   camera: '50MP+48MP+8MP rear, 32MP front',
            //   price: '₹ 89',
            //   originalPrice: '₹ 104',
            // ),
            // const SizedBox(height: 20),
            // // Start Pooling Button
            // // Center(
            // //   child:
            // // ),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<Offer?> getOfferDetails(int id) async {
    return await _offersController.getOfferDetails(id);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((duration) {
      setState(() {
        offerDetails = _offersController.getOfferDetails(widget.offer.id);
      });
    });
  }

  Widget _buildProductDetailDominos({
    required String? imagePath,
    required String title,
    required String description,
    required int? price,
    required int? originalPrice,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: (imagePath == null)
              ? Image.asset(
                  "assets/dominos/Margherita Pizza.png",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'MontserratR',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  text: "$price",
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'MontserratM',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: ' M.R.P. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: "$originalPrice",
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _productDetailsList() {
    return FutureBuilder<Offer?>(
        future: offerDetails,
        builder: (context, snapshot) {
          debugPrint("OFFER : ${snapshot.data}");
          if (snapshot.hasData) {
            var offer = snapshot.data;

            if (offer == null) {
              return const Center(
                child: Text("No product in this offer"),
              );
            }
            var products = offer.products ?? [];
            return ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductDetailDominos(
                  imagePath: product.images.firstOrNull,
                  title: product.name,
                  price: product.offerPrice,
                  description: product.description,
                  originalPrice: product.mrp,
                );
              },
            );
          } else if (snapshot.hasError) {
            debugPrint("Error: ${snapshot.error}");
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
