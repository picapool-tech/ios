import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/features/user_item_listing_details.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/listing_poster.dart';
import 'package:picapool/screens/buy_and_sell/features/user_listing/widgets/sell_category.dart';
import 'package:picapool/utils/theme.dart';
import 'package:picapool/widgets/home/divider.dart';

class UserListing extends StatefulWidget {
  const UserListing({super.key});

  @override
  State<UserListing> createState() => UserListingState();
}

class UserListingState extends State<UserListing> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.currentTheme.dividerColor.withAlpha(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: const CustomScrollView(
        slivers: [
          // The poster at the top
          SliverToBoxAdapter(
            child: ListingPoster(),
          ),

          // Small space
          SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // Category section header
          SliverToBoxAdapter(
            child: Text("Select your selling category"),
          ),

          // Sell Category
          SliverToBoxAdapter(
            child: SellCategory(),
          ),

          // Divider
          SliverToBoxAdapter(
            child: CustomDivider(text: "View Your Listings"),
          ),

          // User listings (now part of the same scrollable area)
          SliverToBoxAdapter(
            child: UserItemListingDetails(),
          ),
        ],
      ),
    );
  }
}
