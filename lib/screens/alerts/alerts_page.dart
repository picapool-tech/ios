import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/common/values/values.dart';
import 'package:picapool/features/offers/offers_controller.dart';
import 'package:picapool/features/tags/tag_controller.dart';
import 'package:picapool/features/user/user_controller.dart';
import 'package:picapool/models/tag_model.dart';
import 'package:picapool/screens/alerts/widgets/alert_list_view.dart';
import 'package:picapool/screens/alerts/widgets/category_selector.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  int selectedCategory = 0;
  final ScrollController _tagsScrollController = ScrollController();

  final OffersController _offersController = Get.find<OffersController>();
  final UserController _userController = Get.find<UserController>();
  final TagController _tagController = Get.find<TagController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alerts',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        systemOverlayStyle: uiOverlayStyle(
          context,
          brightness: Brightness.dark,
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xff02005D),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kBottomNavigationBarHeight),
          child: Obx(
            () {
              var tags = _tagController.tags.value;
              if (tags.isEmpty && _tagController.isLoading.value) {
                return const LinearProgressIndicator();
              }

              if (tags.isEmpty) {
                return const SizedBox.shrink();
              }

              return CategorySelector(
                scrollController: _tagsScrollController,
                selectedCategory: selectedCategory,
                onCategorySelected: _onCategorySelected,
                tags: tags,
              );
            },
          ),
        ),
      ),
      body: _userController.user != null
          ? RefreshIndicator(
              onRefresh: () => _refreshOffers(),
              child: Column(
                children: [
                  _buildLoadingIndicator(),
                  Expanded(
                    child: AlertsList(
                      selectedCategory: selectedCategory,
                      offersController: _offersController,
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Text("You don't have an account to show alerts"),
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaultCategory(_);
    });
  }

  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (selectedCategory == 0) {
        if (_offersController.offers.isNotEmpty &&
            _offersController.isLoading.value) {
          return const LinearProgressIndicator();
        }
      }

      var isValid =
          _offersController.offersByTagId[selectedCategory]?.isNotEmpty ??
              false;
      if (_offersController.isLoading.value && isValid) {
        return const LinearProgressIndicator();
      }

      return const SizedBox.shrink();
    });
  }

  void _initializeDefaultCategory(_) async {
    if (_tagController.tags.isEmpty) {
      await _tagController.initialize();
    }
    Tag? tag = _tagController.getTagsByTagName("Ask") ??
        _tagController.getTagsByTagName("Req");

    if (tag == null) {
      debugPrint("Tag is null on alertsPage");
      return;
    }

    var tagsIndex = _tagController.tags.indexWhere((tagN) => tagN.id == tag.id);
    setState(() {
      selectedCategory = tagsIndex + 1;
      _offersController.getOffersByTagId(tag.id);
    });
  }

  void _onCategorySelected(int category) {
    setState(() {
      selectedCategory = category;
      if (category == 0) {
        _offersController.getOffersForUser();
      } else {
        _offersController.getOffersByTagId(category);
      }
    });
  }

  Future<void> _refreshOffers() async {
    if (selectedCategory == 0) {
      await _offersController.getOffersForUser();
    } else {
      await _offersController.getOffersByTagId(selectedCategory);
    }
  }
}
