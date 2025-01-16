import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picapool/widgets/home/down_sheet.dart';
import 'package:picapool/widgets/home/location_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff02005D),
        title: const LocationWidget(),
        automaticallyImplyLeading: false,
        primary: true,
      ),
      backgroundColor: const Color(0xff02005D),
      body: DownSheet(
        searchQuery: searchQuery,
        scrollController: _scrollController,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }
}
