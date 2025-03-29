import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/screens/alerts/alerts_page.dart';
import 'package:picapool/screens/chats/chat_homeScreen.dart';
import 'package:picapool/screens/home/home_screen.dart';
import 'package:picapool/screens/middle_button/middle_button.dart';
import 'package:picapool/screens/profile_page/profile_page.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';

class NavbarConfig {
  static const List<String> iconPaths = [
    'assets/bottombar/Home1.svg',
    'assets/bottombar/chats.svg',
    'assets/bottombar/alert.svg',
    'assets/bottombar/settings.svg',
  ];

  static const List<String> activeIconPaths = [
    'assets/bottombar/Home1_active.svg',
    'assets/bottombar/chats_active.svg',
    'assets/bottombar/alert_active.svg',
    'assets/bottombar/settings_active.svg',
  ];

  static const List<String> titles = [
    'Home',
    'Chats',
    'Alerts',
    'Settings',
  ];
}

class NewBottomBar extends StatefulWidget {
  final int currentIndex;
  const NewBottomBar({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<NewBottomBar> createState() => _NewBottomBarState();
}

class _NewBottomBarState extends State<NewBottomBar> {
  int _selectedIndex = 0;

  late TagController _tagController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyChatsPage(),
    const AlertsPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      extendBody: true,
      floatingActionButton: (_selectedIndex == 0)
          ? SizedBox(
              width: 70,
              height: 70,
              child: FittedBox(
                child: FloatingActionButton(
                  elevation: 0,
                  onPressed: () {
                    Get.to(() => const PoolOffersScreen());
                  },
                  backgroundColor: AppTheme.currentTheme.primaryColor,
                  shape: const CircleBorder(),
                  child: Transform(
                    transform: Matrix4.translationValues(0, 2, 0),
                    child: const SvgIcon(
                      "assets/bottombar/live.svg",
                      // Size of the center icon
                    ),
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: AppTheme.currentTheme.scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(0),
            _buildNavItem(1),
            if (_selectedIndex == 0)
              const SizedBox(width: 70), // The space for the center icon
            _buildNavItem(2),
            _buildNavItem(3),
          ],
        ),
      ),
    );
  }

  @override
  initState() {
    super.initState();

    _selectedIndex = widget.currentIndex;

    listenNotification();

    Get.put(TagController());
    _tagController = Get.find<TagController>();
  }

  listenNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title}');
      // You can show a dialog, toast, or in-app UI here.
      if (message.notification == null) {
        return;
      }

      debugPrint(
          'Notification opened the app in home: ${message.notification?.title}');
      debugPrint('Notification opened the app: ${message.data.toString()}');
      debugPrint('Notification opened the app: ${message.notification?.body}');

      Get.snackbar(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? 'Notification',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        icon: Image.asset(
          "assets/images/ic_launcher.png",
          width: 20,
          height: 20,
        ),
        duration: const Duration(seconds: 5),
        onTap: (snack) {
          // if it has chat id, offer id  action to openAlertPage.
          var action = message.data['action'];
          if (action != null) {
            if (action == 'openAlertsPage') {
              var offerId = message.data['offerId'];
              if (offerId != null) {
                setState(() {
                  _selectedIndex = 2;
                });
              }
            } else if (action == "openChatPage" ||
                message.notification!.title!.contains("New Message")) {
              setState(() {
                _selectedIndex = 1;
              });
            }
          } else {
            if (message.notification!.title!.contains("New Message")) {
              setState(() {
                _selectedIndex = 1;
              });
              // }
            }
          }
          debugPrint("Performing click on snack bar : ${_selectedIndex}");
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked while in background: ${message.data}');

      // Handle navigation or other actions.
      var action = message.data['action'];
      if (action != null) {
        if (action == 'openAlertsPage') {
          var offerId = message.data['offerId'];
          if (offerId != null) {
            setState(() {
              _selectedIndex = 2;
            });
          }
        } else if (action == "openChatPage" ||
            message.notification!.title!.contains("New Message")) {
          setState(() {
            _selectedIndex = 1;
          });
        }
      } else {
        if (message.notification!.title!.contains("New Message")) {
          setState(() {
            _selectedIndex = 1;
          });
          // }
        }
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print('---- getInitialMessage called ----');
        if (message != null) {
          var action = message.data['action'];
          if (action != null) {
            if (action == 'openAlertsPage') {
              var offerId = message.data['offerId'];
              if (offerId != null) {
                setState(() {
                  _selectedIndex = 2;
                });
              }
            } else if (action == "openChatPage" ||
                message.notification!.title!.contains("New Message")) {
              setState(() {
                _selectedIndex = 1;
              });
            }
          } else {
            if (message.notification!.title!.contains("New Message")) {
              setState(() {
                _selectedIndex = 1;
              });
              // }
            }
          }
        } else {
          print('---- getInitialMessage is not opened ----');
        }
      },
    );
  }

  Widget _buildNavItem(int index) {
    final bool isActive = index == _selectedIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => _handleTabChange(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive
                  ? NavbarConfig.activeIconPaths[index]
                  : NavbarConfig.iconPaths[index],
              width: 24,
              height: 24,
              fit: BoxFit.cover,
              colorFilter: !isActive
                  ? ColorFilter.mode(
                      AppTheme.currentTheme.hintColor,
                      BlendMode.srcIn,
                    )
                  : null,
            ),
            Text(
              NavbarConfig.titles[index],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? const Color(0xffFF8D41)
                        : AppTheme.currentTheme.hintColor,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTabChange(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }
}
