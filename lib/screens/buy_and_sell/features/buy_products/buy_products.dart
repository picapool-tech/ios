import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:picapool/features/buy_and_sell/products_controller.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/nearby_products.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/widgets/top_row_widgets.dart';
import 'package:picapool/screens/buy_and_sell/values/enums.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/divider.dart';

class BuyProducts extends StatefulWidget {
  const BuyProducts({super.key});

  @override
  State<BuyProducts> createState() => _BuyProductsState();
}

class _BuyProductsState extends State<BuyProducts>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ProductsController _productsController = Get.find();
  Timer? _debounce;

  @override
  bool get wantKeepAlive => true;

  SortOption? get _currentSortOption => _productsController.currentSortOption;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.currentTheme.dividerColor.withAlpha(10),
      ),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: TopRowWidgets(
                  searchController: _searchController,
                  currentSort: _currentSortOption,
                  onSortSelected: _handleSortSelection,
                  removeSort: _removeSorting,
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: FilterRow(onSelected: (selectedFilter) {}),
            // ),
          ];
        },
        body: const Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: CustomDivider(
                text: "Products near you",
              ),
            ),
            Expanded(
              child: NearbyProducts(),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _searchController.text = _productsController.lastSearchQuery;

    _searchController.addListener(_onSearchChanged);
  }

  void _clearFilters() {
    _searchController.clear();
    _productsController.resetAll();
  }

  void _handleSortSelection(SortOption option) {
    _productsController.setSortOption(option);
    setState(() {});
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _productsController.searchProductsLocal(_searchController.text);
    });
  }

  void _removeSorting() {
    _productsController.removeSorting();
    setState(() {});
  }
}
