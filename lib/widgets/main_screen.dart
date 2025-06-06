import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/alerts/alerts_page.dart';
import 'package:picapool/screens/chats/chat_home_screen.dart';
import 'package:picapool/screens/home/home_screen.dart';
import 'package:picapool/screens/profile_page/profile_page.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';

class MainScreen extends StatefulWidget {
  final int goToIndex;
  const MainScreen({
    super.key,
    this.goToIndex = 0,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatHomeScreen(),
    AlertsPage(
      showOfferDetails: Get.arguments?['offerId'],
    ),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
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
                    Get.toNamed(GetRoutes.poolOffers);
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
        padding: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: Row(
          children: [
            Expanded(child: _buildTabItem(0)),
            Expanded(child: _buildTabItem(1)),
            // Center space for FAB
            if (_selectedIndex == 0) const SizedBox(width: 70),

            Expanded(child: _buildTabItem(2)),
            Expanded(child: _buildTabItem(3)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _selectedIndex = widget.goToIndex;
    });

    _tabController = TabController(
      length: NavbarConfig.titles.length,
      vsync: this,
      initialIndex: _selectedIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedIndex = _tabController.index);
      }
    });
  }

  Widget _buildTabItem(int index) {
    final bool isActive = index == _selectedIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _tabController.animateTo(index);
        });
    },
      child: Container(
        height: double.infinity,
        // color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isActive
                  ? NavbarConfig.activeIconPaths[index]
                  : NavbarConfig.iconPaths[index],
              width: 24,
              height: 24,
              colorFilter: !isActive
                  ? ColorFilter.mode(
                      AppTheme.currentTheme.hintColor,
                      BlendMode.srcIn,
                    )
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              NavbarConfig.titles[index],
              style: TextStyle(
                fontSize: 12,
                color: isActive
                    ? const Color(0xffFF8D41)
                    : AppTheme.currentTheme.hintColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Future<void> handleMessage(RemoteMessage message) async {
//     debugPrint("MESSAGE FOUND: ${message.data}");

//     try {
//       var action = message.data['action'];
//       if (action == null) {
//         return;
//       }

//       if (action == 'openAlertsPage') {
//         int? offerId = int.tryParse(message.data['offerId']);
//         if (offerId != null) {
//           Get.to(
//               () => const MainScreen(
//                     goToIndex: 2,
//                   ),
//               arguments: {
//                 'offerId': offerId,
//               });
//         }
//         return;
//       }

//       if (message.data['chatId'] != null) {
//         String? chatId = message.data['chatId'];
//         if (chatId == null) {
//           return;
//         }
//         int? chatIdInt = int.tryParse(chatId);
//         if (chatIdInt == null) {
//           return;
//         }
//         await handleChatNavigation(chatIdInt);
//       }
//     } catch (e) {
//       debugPrint("Some error occured $e");
//     }
//   }

  // void handleMessageWithOverlay(RemoteMessage message) {
  //   Get.showOverlay(asyncFunction: () => handleMessage(message));
  // }
}
