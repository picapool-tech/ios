import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/widgets/buttons_widgets.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/buy_and_sell/values/enums.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/offers/values/offer_loading_enums.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/models/product_model.dart';
import 'package:picapool/screens/buy_and_sell/features/product_details/product_details.dart';
import 'package:picapool/utils/theme.dart';

class UserItemListingItem extends StatefulWidget {
  final Offer offer;
  final Product product;

  const UserItemListingItem({
    super.key,
    required this.offer,
    required this.product,
  });

  @override
  State<UserItemListingItem> createState() => _UserItemListingItemState();
}

class _UserItemListingItemState extends State<UserItemListingItem> {
  final OffersController _offersController = Get.find<OffersController>();
  final ProductsController _productsController = Get.find<ProductsController>();
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpansionTile(
          title: Text(widget.offer.name),
          subtitle: Text(
              '₹${widget.offer.price?.toStringAsFixed(2) ?? widget.product.offerPrice?.toStringAsFixed(2) ?? 'N/A'}'),
          childrenPadding: const EdgeInsets.all(5),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppTheme.currentTheme.scaffoldBackgroundColor,
          collapsedBackgroundColor:
              AppTheme.currentTheme.scaffoldBackgroundColor,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.product.isProductSold())
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "SOLD",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ],
          ),
          onExpansionChanged: (value) {
            setState(() {
              isExpanded = value;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.description),
                  const SizedBox(height: 8.0),
                  Text(
                      'Condition: ${widget.product.attributes?['productCondition']}'),
                  const SizedBox(height: 8.0),
                  Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: PicaPrimaryButton(
                          onPressed: (!widget.offer.isOfferExpired() &&
                                  !widget.product.isProductSold())
                              ? () async {
                                  var product = widget.product;
                                  var updatedOffer = widget.offer
                                      .copyWith(expiryAt: DateTime.now());

                                  product.attributes?['sold'] = true;

                                  Offer? updatedOfferResponse =
                                      await _offersController.updateOffer(
                                    updatedOffer: updatedOffer,
                                  );

                                  if (updatedOfferResponse == null) {
                                    showPicaAlertDialog(
                                      message:
                                          "Unable to mark the product as sold.",
                                      confirmText: "Ok",
                                      onConfirm: () {
                                        Get.back();
                                      },
                                    );
                                    return;
                                  }

                                  Product? updatedProduct =
                                      await _productsController.updateProduct(
                                    updatedProduct: product,
                                  );

                                  if (updatedProduct != null) {
                                    _offersController.getAllUserCreatedOffer();
                                    showPicaAlertDialog(
                                      title: "Listing marked as sold",
                                      message:
                                          "Your product ${product.name} is successfully marked as solved.",
                                      confirmText: "Feels good",
                                      onConfirm: () {
                                        Get.back();
                                      },
                                    );
                                  } else {
                                    Offer? updatedOfferResponse =
                                        await _offersController.updateOffer(
                                      updatedOffer: updatedOffer.copyWith(
                                        expiryAt: widget.offer.expiryAt,
                                      ),
                                    );
                                    _offersController.getAllUserCreatedOffer();
                                  }

                                  // var updatedOffer =
                                  //     await _offersController.u(
                                  //         updatedOffer: widget.offer
                                  //             .copyWith(expiryAt: DateTime.now()));

                                  // if (updatedOffer != null) {
                                  //   await _offersController
                                  //       .getAllUserCreatedOffer();
                                  // showPicaAlertDialog(
                                  //   title: "Listing marked as sold",
                                  //   message:
                                  //       "Your product ${updatedOffer.name} is successfully marked as solved.",
                                  //   confirmText: "Feels good",
                                  //   onConfirm: () {
                                  //     Get.back();
                                  //   },
                                  // );
                                  // }
                                }
                              : null,
                          text: (widget.product.isProductSold())
                              ? "PRODUCT SOLD"
                              : "Mark as sold",
                          isLoading: _productsController.getLoadingState(
                            ProductLoadingEnums.updateProduct,
                          ),
                        ),
                      ),
                      Expanded(
                        child: PicaTextButton(
                          onPressed: () {
                            Get.to(
                              () => ProductDetails(
                                product: widget.product,
                                offer: widget.offer,
                                offersController: _offersController,
                              ),
                            );
                          },
                          text: "More details",
                          isLoading: _offersController
                              .getLoadingState(OfferLoadingEnums.offerDetails),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0), // Added space after each item
      ],
    );
  }
}
