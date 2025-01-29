import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/functions/tags/tag_controller.dart';
import 'package:picapool/screens/Middle%20Button/middleButton.dart';
import 'package:picapool/screens/ProfilePage/ProfilePage.dart';
import 'package:picapool/screens/alerts/alertsPage.dart';
import 'package:picapool/screens/chats/chat_homeScreen.dart';
import 'package:picapool/screens/home_screen.dart';
import 'package:picapool/utils/svg_icon.dart';

class NewBottomBar extends StatefulWidget {
  final int currentIndex;
  const NewBottomBar({Key? key, this.currentIndex = 0}) : super(key: key);

  @override
  State<NewBottomBar> createState() => _NewBottomBarState();
}

class _NewBottomBarState extends State<NewBottomBar> {
  int _selectedIndex = 0;
  // double height = Platform.isAndroid ? 70 : 100;
  late TagController _tagController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyChatsPage(),
    // ProductsHomepage(currentIndex: 1),
    const AlertsPage(),
    const ProfileScreen(),
  ];

  final List<String> _iconPaths = [
    'assets/bottombar/Home1.svg',
    'assets/bottombar/chats.svg',
    'assets/bottombar/alert.svg',
    'assets/bottombar/settings.svg',
  ];

  final List<String> _activeIconPaths = [
    'assets/bottombar/Home1_active.svg',
    'assets/bottombar/chats_active.svg',
    'assets/bottombar/alert_active.svg',
    'assets/bottombar/settings_active.svg',
  ];

  final List<String> _titles = [
    'home',
    'chats',
    'alerts',
    'settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              Get.to(() => const PoolOffersScreen());
            },
            backgroundColor: const Color(0xffFF8D41),
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 10,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildNavItem(0),
              
            ),
            Expanded(
              child: _buildNavItem(1),
            ),
            const SizedBox(width: 40), // The space for the center icon
            Expanded(
              child: _buildNavItem(2),
            ),
            Expanded(
              child: _buildNavItem(3),
            ),
          ],
        ),
      ),
      // Stack(
      //   clipBehavior: Clip.none,
      //   children: [
      // BottomAppBar(
      //   color: Colors.white,
      //   child: SizedBox(
      //     height: height,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         Expanded(
      //           child: _buildNavItem(0),
      //         ),
      //         Expanded(
      //           child: _buildNavItem(1),
      //         ),
      //         const SizedBox(width: 40), // The space for the center icon
      //         Expanded(
      //           child: _buildNavItem(2),
      //         ),
      //         Expanded(
      //           child: _buildNavItem(3),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      //     Positioned(
      //       top: -30, // Adjust this value to move the icon up or down
      //       left: MediaQuery.of(context).size.width / 2 -
      //           35, // Center the icon horizontally
      //       child: InkWell(
      //         onTap: () {
      //           Get.to(
      //             () => const PoolOffersScreen(),
      //           );
      //         },
      // child: const SvgIcon(
      //   "assets/bottombar/live.svg",
      //   size: 70, // Size of the center icon
      // ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  @override
  initState() {
    super.initState();
    listenNotification();
    Get.put(TagController());
    _tagController = Get.find<TagController>();
    _tagController.subscribeToTopics();
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
        icon: const Icon(Icons.notification_important, color: Colors.white),
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
    bool isActive = index == _selectedIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            isActive ? _activeIconPaths[index] : _iconPaths[index],
            size: 24,
          ),
          Text(
            _titles[index],
            style: TextStyle(
              color: isActive ? const Color(0xffFF8D41) : Colors.black,
              fontSize: 12,
              fontFamily: 'MontserratR',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
