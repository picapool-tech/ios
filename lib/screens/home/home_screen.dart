import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/location/location_controller.dart';
import 'package:picapool/screens/home/widgets/down_sheet.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/location_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  final LocationController _locationController = Get.find<LocationController>();

  late final AppLifecycleListener _listener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocationWidget(),
        backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
        systemOverlayStyle: uiOverlayStyle(
          context,
          brightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        primary: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      backgroundColor: AppTheme.currentTheme.colorScheme.secondary,
      body: DownSheet(
        searchQuery: searchQuery,
        scrollController: _scrollController,
      ),
    );
  }

  @override
  dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    debugPrint("HomeScreen");

    _listener = AppLifecycleListener(
      onResume: () => _onStateChanged(AppLifecycleState.resumed),
    );
  }

  _onStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("AppLifecycleState.resumed");
      if (!_locationController.isUserProvidedLocation) {
        _locationController.getLocation();
      }
    }
  }
}
