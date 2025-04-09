import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:picapool/common/widgets/dialog_widgets.dart';
import 'package:picapool/controllers/brand_controller.dart';
import 'package:picapool/controllers/category_controller.dart';
import 'package:picapool/controllers/live_offer_controller.dart';
import 'package:picapool/controllers/network_controller.dart';
import 'package:picapool/controllers/sell_form_controller.dart';
import 'package:picapool/core/core.dart';
import 'package:picapool/core/env.dart';
import 'package:picapool/features/assets/assets_controller.dart';
import 'package:picapool/features/auth/auth_controller.dart';
import 'package:picapool/features/auth/auth_state_manager.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/features/chats/chat_controller.dart';
import 'package:picapool/features/feedback/feedback_controller.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/features/network/connection_status_listener.dart';
import 'package:picapool/features/notification/notification_service.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/partners/partner_controller.dart';
import 'package:picapool/features/storage/storage_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/tokens/token_service.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/features/vicinity/vicinity_controller.dart';
import 'package:picapool/firebase_options_new.dart';
import 'package:picapool/models/live_offer_model.dart';
import 'package:picapool/models/offer_model.dart';
import 'package:picapool/screens/auth_check_screen.dart';
import 'package:picapool/screens/public_chat/chat_page.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "new-picapool",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  await Env.load();

  Get.put(StorageController(), permanent: true);
  Get.put(AuthStateManager(), permanent: true);
  Get.put(NetworkController.getInstance(), permanent: true);
  Get.put(AuthTokenService(), permanent: true);
  Get.put(PicapoolApi(), permanent: true);

  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => AuthController(), fenix: true);
  Get.put(LocationController());
  Get.lazyPut(() => VicinityController(), fenix: true);
  Get.lazyPut(() => OffersController(), fenix: true);
  Get.lazyPut(() => ChatController(), fenix: true);
  Get.lazyPut(() => FeedbackController(), fenix: true);
  Get.lazyPut(() => AssetsController(), fenix: true);
  Get.lazyPut(() => LiveOfferController(), fenix: true);
  Get.lazyPut(() => TagController(), fenix: true);
  Get.lazyPut(() => ProductsController(), fenix: true);
  Get.lazyPut(() => BrandController(), fenix: true);
  Get.lazyPut(() => FormController(), fenix: true);
  Get.lazyPut(() => CategoryController(), fenix: true);
  Get.lazyPut(() => PartnerController(), fenix: true);
  Get.lazyPut(() => TagController(), fenix: true);

  NotificationService().requestPermission();
  FirebaseMessaging.onBackgroundMessage(handleNotification);
  NotificationService().handleTokenGeneration();

  await checkingForDynamicLink();

  runApp(const MyApp());
}

Future<void> checkingForDynamicLink() async {
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinksPlatform.instance.getInitialLink();

  if (initialLink != null) {
    handleDynamicLink(initialLink);
  }

  FirebaseDynamicLinksPlatform.instance.onLink
      .listen((PendingDynamicLinkData? pendingDynamicLinkData) {
    if (pendingDynamicLinkData != null) {
      handleDynamicLink(pendingDynamicLinkData);
    }
  });
}

FutureVoid handleChatNavigation(int? chatId) async {
  if (chatId == null) {
    hidePicaDialog();
    Get.to(
      () => const NewBottomBar(
        currentIndex: 1,
      ),
    );
    return;
  }

  var chat = await Get.find<ChatController>().getChatFromId(chatId: chatId);
  if (chat == null) {
    hidePicaDialog();
    Get.to(
      () => const NewBottomBar(
        currentIndex: 1,
      ),
    );
    return;
  }

  Offer? offer;
  LiveOffer? liveOffer;
  if (chat.offerId != null) {
    offer = await Get.find<OffersController>().getOfferDetails(chat.offerId!);
  }

  if (chat.liveOfferId != null) {
    var liveOfferEntity = await Get.find<LiveOfferController>()
        .getLiveOffer("${chat.liveOfferId!}");
    try {
      liveOffer = LiveOffer.fromJson(liveOfferEntity!.toJson());
    } catch (e) {
      debugPrint("Got errror in converting live offer");
    }
  }
  hidePicaDialog();
  Get.to(ChatPage(
    chat: chat,
    chatTitle: parseChatTitle(offer, liveOffer),
    offer: offer,
    liveOffer: liveOffer,
  ));
}

void handleDynamicLink(PendingDynamicLinkData? dynamicLinkData) {
  if (Get.context == null) {
    debugPrint(
        "Application has not been started yet but here is link ${dynamicLinkData?.link.toString()}");
    return;
  }

  debugPrint(
      "Application has not been started yet but here is link ${dynamicLinkData?.link.toString()}");
}

void handleMessage(RemoteMessage message) async {
  debugPrint("MESSAGE FOUND: ${message.data}");

  showPicaLoadingDialog();
  try {
    var action = message.data['action'];
    if (action == null) {
      hidePicaDialog();
      return;
    }

    if (action == 'openAlertsPage') {
      var offerId = message.data['offerId'];
      if (offerId != null) {
        hidePicaDialog();
        Get.to(
          () => const NewBottomBar(
            currentIndex: 2,
          ),
        );
      }
      return;
    }

    if (message.data['chatId'] != null) {
      String? chatId = message.data['chatId'];
      if (chatId == null) {
        hidePicaDialog();
        return;
      }
      int? chatIdInt = int.tryParse(chatId);
      if (chatIdInt == null) {
        hidePicaDialog();
        return;
      }
      await handleChatNavigation(chatIdInt);
    }
  } catch (e) {
    debugPrint("Some error occured $e");
    hidePicaDialog();
  }
}

@pragma('vm:entry-point')
Future<void> handleNotification(RemoteMessage message) async {
  debugPrint('Notification opened the app: ${message.notification?.title}');
  debugPrint('Notification opened the app: ${message.data.toString()}');
  debugPrint('Notification opened the app: ${message.notification?.body}');

  handleMessage(message);
}

listenNotification() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received in foreground: ${message.notification?.title}');
    showInAppNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleMessage(message);
  });

  FirebaseMessaging.instance.getInitialMessage().then(
    (message) {
      print('---- getInitialMessage called ----');
      if (message != null) {
        handleMessage(message);
      } else {
        print('---- getInitialMessage is not opened ----');
      }
    },
  );
}

String parseChatTitle(Offer? offer, LiveOffer? liveOffer) {
  if (offer != null) {
    return offer.name;
  }

  if (liveOffer != null) {
    return liveOffer.to ?? "";
  }

  return "";
}

void showInAppNotification(RemoteMessage message) {
  // Don't show if notification is empty
  if (message.notification == null) {
    return;
  }

  final title = message.notification!.title ?? 'Notification';
  final body = message.notification!.body ?? '';

  // Show a compact snackbar
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    messageText: Text(
      body,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    icon: Padding(
      padding: const EdgeInsets.only(left: 4, right: 8),
      child: Image.asset(
        "assets/images/ic_launcher.png",
        width: 24,
        height: 24,
      ),
    ),
    shouldIconPulse: false,
    maxWidth: 500, // Add max width constraint
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 6,
        offset: const Offset(0, 3),
      )
    ],
    duration: const Duration(seconds: 4),
    isDismissible: true,
    onTap: (_) => handleMessage(message),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: GetRoutes.routes,
      title: 'Picapool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      home: const AuthCheckScreen(),
    );
  }

  void checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        try {
          await InAppUpdate.performImmediateUpdate();
        } catch (e) {
          debugPrint('Immediate update failed: $e');
          await InAppUpdate.startFlexibleUpdate();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'An update is available. Please restart the app to complete the update.',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    ConnectionStatusListener.getInstance().initialize();
    listenNotification();
    if (Platform.isAndroid) {
      checkForUpdate();
    }
  }
}
