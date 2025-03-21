import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/tables.dart';
import 'package:picapool/screens/buy_and_sell/widgets/image_gallery.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/theme.dart';

class HeadingText extends StatelessWidget {
  final String headingText;
  const HeadingText({
    super.key,
    required this.headingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0, top: 8),
      child: Text(
        headingText,
        style: Get.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProductDetails extends StatelessWidget {
  final Product product;
  final Offer offer;
  const ProductDetails({
    super.key,
    required this.product,
    required this.offer,
  });

  @override
  Widget build(BuildContext context) {
    final offerController = Get.find<OffersController>();

    return Scaffold(
      appBar: AppBar(
        actions: const [
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(
          //     Icons.mode_edit,
          //   ),
          // ),
        ],
      ),
      body: Container(
        color: AppTheme.currentTheme.dividerColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ImageGallery(
                imageUrl: product.images,
              ),
              const SizedBox(
                height: PicaValues.largeSpacing,
              ),
              Text(
                product.name,
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: PicaValues.mediumSpacing,
              ),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      text: "MRP: ",
                      children: [
                        TextSpan(
                          text: "₹${product.mrp}",
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      style: Get.textTheme.bodySmall
                          ?.copyWith(decoration: TextDecoration.lineThrough),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * 0.1,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Selling Price: ",
                      children: [
                        TextSpan(
                          text: "₹${product.offerPrice}",
                          style: Get.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      style: Get.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: PicaValues.mediumSpacing,
              ),
              // product details
              Container(
                width: double.infinity,
                decoration: roundedContainer().copyWith(
                  color: AppTheme.currentTheme.scaffoldBackgroundColor,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeadingText(headingText: "Description"),
                    Text(product.description),

                    const HeadingText(headingText: "Reason for selling"),
                    Text(product.attributes?['reasonForSell'] ?? ""),
                    const HeadingText(headingText: "Details"),
                    if (product.attributes != null &&
                        product.attributes!.isNotEmpty)
                      ProductTable(
                        data: product.attributes!,
                      ),
                    // Wrap(
                    //   direction: Axis.horizontal,
                    //   children:
                    //       List.generate(product.attributes!.length, (index) {
                    //     var entries = product.attributes!.entries.toList();
                    //     return TextButton.icon(
                    //       style: const ButtonStyle(
                    //         backgroundColor:
                    //             WidgetStatePropertyAll(Colors.red),
                    //       ),
                    //       onPressed: null,
                    //       label: Text(entries[index].key.toString().trim()),
                    //     );
                    //   }),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kBottomNavigationBarHeight,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: PicaPrimaryButton(
            text: "Go to chat",
            onPressed: () async {
              var chat = await offerController.getChatFromOfferId(
                offerId: offer.id,
              );
              if (chat == null) {
                showPicaAlertDialog(
                  message: "Chat for this product doesn't exits",
                  confirmText: "Okay",
                  onConfirm: () {
                    Get.back();
                  },
                );
                return;
              }

              Get.to(
                () => ChatPage(
                  chat: chat,
                  offer: offer,
                  chatTitle: product.name,
                ),
              );
            },
            isLoading:
                offerController.getLoadingState(OfferLoadingEnums.fetchingChat),
          ),
        ),
      ),
    );
  }
}
