import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picapool/screens/Products/products_home_page.dart';
import 'package:picapool/screens/home/home_screen.dart';
import 'package:picapool/utils/svg_icon.dart';

class NewBottomBarProduct extends StatefulWidget {
  final int currentIndex;
  const NewBottomBarProduct({Key? key, this.currentIndex = 0})
      : super(key: key);

  @override
  State<NewBottomBarProduct> createState() => _NewBottomBarProductState();
}

class _NewBottomBarProductState extends State<NewBottomBarProduct> {
  int _selectedIndex = 0;
  double height = Platform.isAndroid ? 70 : 100;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsHomepage(
      brandName: "Food",
    ),
    // Add more screens as needed
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
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            color: Colors.white,
            child: SizedBox(
              height: height,
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
          ),
          Positioned(
            top: -30, // Adjust this value to move the icon up or down
            left: MediaQuery.of(context).size.width / 2 -
                35, // Center the icon horizontally
            child: InkWell(
              onTap: () {
                // Define action for this icon
              },
              child: const SvgIcon(
                "assets/bottombar/sell.svg",
                size: 70, // Size of the center icon
              ),
            ),
          ),
        ],
      ),
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
