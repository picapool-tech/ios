import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/tables.dart';
import 'package:picapool/screens/buy_and_sell/widgets/image_gallery.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:share_plus/share_plus.dart';

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
  final OffersController offersController;
  const ProductDetails({
    super.key,
    required this.product,
    required this.offer,
    required this.offersController,
  });

  bool get isProductSold =>
      product.attributes?['sold'] != null && product.attributes?['sold'];

  @override
  Widget build(BuildContext context) {
    UserController? userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text: offer.shareOfferString,
                  // uri: Uri.parse("https://offer.picapool.com/offers/${widget.offer?.id}"),
                  subject: "Check out this offer on Picapool!",
                  // previewThumbnail: XFile(filePath),
                ),
              );
            },
            icon: Icon(Icons.share),
          ),
          // if (storageController.user.value!.id == product.userId)
          //   IconButton(
          //     onPressed: () {
          //       Widget? destination;
          //       var values = FilterDataEnum.values;
          //       var category = values.firstWhere(
          //           (data) => data.name == product.attributes!['category']);

          //       switch (category) {
          //         case FilterDataEnum.books:
          //           destination = CreateBookProducts(
          //             product: product,
          //           );
          //           break;
          //         default:
          //       }
          //       if (destination == null) {
          //         return;
          //       }

          //       Get.to(destination);
          //     },
          //     icon: const Icon(
          //       Icons.edit,
          //     ),
          //   ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isProductSold)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shopping_bag, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This product is sold!",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontFamily: "MontserratR",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(
              height: PicaValues.largeSpacing,
            ),

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
                        text: "₹${product.price ?? product.mrp ?? "N/A"}",
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
                        text: "₹${offer.price ?? product.offerPrice ?? 'N/A'},",
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
            Column(
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
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kBottomNavigationBarHeight,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: PicaPrimaryButton(
            text: "Go to chat",
            onPressed: (!isProductSold ||
                    (isProductSold &&
                        product.userId == userController.user!.id))
                ? () async {
                    var chat = await offersController.createOrGetPvtChat(
                        offerId: offer.id,
                        buyerId: userController.user!.id,
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
                  }
                : null,
            isLoading: offersController
                .getLoadingState(OfferLoadingEnums.fetchingChat),
          ),
        ),
      ),
    );
  }
}
