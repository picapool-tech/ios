import 'package:flutter/material.dart';
import 'package:picapool/screens/buy_and_sell/features/buy_products/buy_products.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/user_listing.dart';

class BuyAndSell extends StatefulWidget {
  const BuyAndSell({super.key});

  @override
  State<BuyAndSell> createState() => _BuyAndSellState();
}

class _BuyAndSellState extends State<BuyAndSell>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Buy Products'),
            Tab(text: 'Your Listings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BuyProducts(),
          UserListing(),
        ],
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
    _tabController = TabController(length: 2, vsync: this);
  }
}
