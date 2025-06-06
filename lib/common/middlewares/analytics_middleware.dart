import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnalyticsMiddleware extends GetMiddleware {
  Stopwatch? _stopwatch;

  @override
  Widget onPageBuilt(Widget page) {
    final screenName =
        Get.currentRoute.isNotEmpty ? Get.currentRoute : 'unknown_screen';
    debugPrint("%% AnalyticsMiddleware onPageBuilt: $screenName");
    FirebaseAnalytics.instance.setCurrentScreen(screenName: screenName);
    FirebaseAnalytics.instance.logEvent(name: 'page_opened', parameters: {
      'screen_name': screenName,
    });

    return page;
  }

  @override
  void onPageDispose() {
    final screenName =
        Get.currentRoute.isNotEmpty ? Get.currentRoute : 'unknown_screen';
    final duration = _stopwatch?.elapsed.inSeconds ?? 0;
    debugPrint("%% AnalyticsMiddleware onPageDispose: $screenName");
    FirebaseAnalytics.instance
        .logEvent(name: 'screen_duration_tracked', parameters: {
      'screen_name': screenName,
      'duration_seconds': duration,
    });
    super.onPageDispose();
  }

  @override
  RouteSettings? redirect(String? route) {
    debugPrint("%% AnalyticsMiddleware redirect called: $route");
    if (route != null) {
      final appLinksPatterns = [
        RegExp(r'^/offer/\d+$'),
        RegExp(r'^/liveOffer/\d+$'),
      ];

      for (var pattern in appLinksPatterns) {
        if (pattern.hasMatch(route)) {
          log(
            "%% App Link found: $route",
            name: 'AnalyticsMiddleWare',
          );
          FirebaseAnalytics.instance.logEvent(
            name: 'app_link_opened',
            parameters: {'path': route},
          );
          _stopwatch = Stopwatch()..start();
          return RouteSettings(name: "/homePage");
        }
      }
    }
    log("%% No App Link found: $route", name: 'AnalyticsMiddleWare');
    _stopwatch = Stopwatch()..start();
    return super.redirect(route);
  }
}
