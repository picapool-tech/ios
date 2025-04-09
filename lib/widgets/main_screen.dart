import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/alerts/alerts_page.dart';
import 'package:picapool/screens/chats/chat_homeScreen.dart';
import 'package:picapool/screens/home/home_screen.dart';
import 'package:picapool/screens/middle_button/middle_button.dart';
import 'package:picapool/screens/profile_page/profile_page.dart';
import 'package:picapool/utils/routes.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/bottom_navbar/common_bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MyChatsPage(),
    const AlertsPage(),
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
            ),
          ),
        ],
      ),
    );
  }
}
