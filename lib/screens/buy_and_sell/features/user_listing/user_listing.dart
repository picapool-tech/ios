import 'package:flutter/material.dart';
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
      child: const SingleChildScrollView(
        child: Column(
          children: [
            // The poster at the top
            ListingPoster(),

            // Small space
            SizedBox(height: 8),

            // Category section header
            CustomDivider(text: "Select your selling category"),

            // Sell Category
            SellCategory(),

            // Divider
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: CustomDivider(text: "View Your Listings")),
                // const SizedBox(
                //   width: 10,
                // ),
                // IconButton(
                //   onPressed: () async {
                //     await _offersController.getAllUserCreatedOffer();
                //   },
                //   icon: const Icon(Icons.refresh),
                // )
              ],
            ),

            // User listings (now part of the same scrollable area)
            UserItemListingDetails(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
