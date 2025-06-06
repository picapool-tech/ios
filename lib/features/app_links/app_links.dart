import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/functions/model_bottom_sheet_caller.dart';
import 'package:picapool/main.dart';
import 'package:picapool/screens/alerts/widgets/show_live_offer_details.dart';
import 'package:picapool/utils/theme.dart';

void showLiveOfferDetails(int id) {
  if (Get.context == null) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
        child: ShowLiveOfferDetails(
          liveOfferId: id,
        ),
      ),
      isScrollControlled: false,
      persistent: false,
      backgroundColor: AppTheme.currentTheme.bottomSheetTheme.backgroundColor,
    );
  } else {
    showPicaModelBottomSheet(
      context: Get.context!,
      isScrollController: true,
      child: ShowLiveOfferDetails(liveOfferId: id),
    );
  }
}

class DynamicLinkHandler {
  static final instance = DynamicLinkHandler._();

  final _appLinks = AppLinks();

  /// Singleton instance of [DynamicLinkHandler].
  /// This class is used to handle dynamic links in the app.
  /// It listens to incoming dynamic links and performs navigation based on the link data.
  /// It also provides a method to create short URLs for products.

  DynamicLinkHandler._();

  /// Provides the short url for your dynamic link.
  // Future<String> createProductLink({
  //   required int id,
  //   required String title,
  // }) async {
  //   // Call Rest API if link needs to be generated from backend.
  //   return 'https://example.com/products?id=$id&title=$title';
  // }

  /// Initializes the [DynamicLinkHandler].
  Future<void> initialize() async {
    // * Listens to the dynamic links and manages navigation.
    _appLinks.uriLinkStream.listen(_handleLinkData).onError((error) {
      log('$error', name: 'Dynamic Link Handler');
    });
    _checkInitialLink();
  }

  /// Handle navigation if initial link is found on app start.
  Future<void> _checkInitialLink() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleLinkData(initialLink);
    }
  }

  /// Handles the link navigation Dynamic Links.
  void _handleLinkData(Uri data) {
    final path = data.path;
    log(data.toString(), name: 'Dynamic Link Handler');

    if (path.isEmpty) {
      return;
    }

    log("Path: $path", name: 'Dynamic Link Handler');

    // Extract path segments and IDs
    final pathResult = DynamicPath.parsePathData(path);
    if (pathResult != null) {
      final (pathType, id) = pathResult;
      log("Parsed path type: $pathType, ID: $id", name: 'Dynamic Link Handler');

      // Navigate based on path type and ID
      switch (pathType) {
        case DynamicPath.offer:
          showOfferDetails(id);
          break;
        case DynamicPath.liveOffer:
          // Navigate to live offer details
          showLiveOfferDetails(id);
          break;
      }
    }
  }
}

enum DynamicPath {
  offer,
  liveOffer;

  String get pathName {
    switch (this) {
      case DynamicPath.offer:
        return "offer";
      case DynamicPath.liveOffer:
        return "liveOffer";
    }
  }

  static (DynamicPath, int)? parsePathData(String path) {
    final cleanPath = path.startsWith("/") ? path.substring(1) : path;

    final segments = cleanPath.split("/");

    if (segments.length == 1 && _isNumeric(segments[0])) {
      return (DynamicPath.offer, int.parse(segments[0]));
    }

    if (segments.length >= 2 && _isNumeric(segments[1])) {
      final pathType = segments[0].toLowerCase();
      final id = int.parse(segments[1]);

      for (var type in DynamicPath.values) {
        if (pathType == type.pathName.toLowerCase()) {
          return (type, id);
        }
      }
    }

    return null;
  }

  static bool _isNumeric(String str) {
    return int.tryParse(str) != null;
  }
}
