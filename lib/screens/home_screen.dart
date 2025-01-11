import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/network_controller.dart';
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
  final NetworkController _networkController = Get.find<NetworkController>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: NewBottomBar(),
      // appBar: PreferredSize(
      //   preferredSize: const Size.fromHeight(100),
      //   child: Center(
      //     child: Obx(() {
      //       if (_networkController.isConnected.value) {
      //         return const Text(
      //           "Network Connected",
      //           style: TextStyle(
      //             color: Colors.green,
      //           ),
      //         );
      //       }
      //       return const Text(
      //         "Not not available",
      //         style: TextStyle(
      //           color: Colors.red,
      //         ),
      //       );
      //     }),
      //   ),
      // ),
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
      // NestedScrollView(
      //   physics: const ClampingScrollPhysics(),
      //   headerSliverBuilder: (context, innerBoxIsScrolled) => [
      //     SliverToBoxAdapter(
      //       child: ExploreWidget(
      //         onSearch: (query) {
      //           setState(() {
      //             searchQuery = query;
      //           });
      //         },
      //       ),
      //     ),
      //   ],
      //   floatHeaderSlivers: false,
      // body: DownSheet(
      //   searchQuery: searchQuery,
      //   scrollController: _scrollController,
      // ),
      // ),
      // Container(
      //   decoration: const BoxDecoration(color: Color(0xff02005D)),
      //   child:

      //   Stack(
      //     children: [
      // ExploreWidget(
      //   onSearch: (query) {
      //     setState(() {
      //       searchQuery = query;
      //     });
      //   },
      // ),
      //       Container(
      //         alignment: Alignment.bottomCenter,
      //         child: DownSheet(
      //           searchQuery: searchQuery,
      //         ),
      //       ),
      //       // Container(alignment: Alignment.bottomCenter, child: const UpSheet())
      //     ],
      //   ),
      // ),
    );
  }
}
