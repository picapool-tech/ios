import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/utils/theme.dart';

class ListingPoster extends StatelessWidget {
  const ListingPoster({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: roundedContainer().copyWith(
          color: AppTheme.currentTheme.scaffoldBackgroundColor,
          boxShadow: [
            const BoxShadow(
              color: Colors.transparent,
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 0),
            ),
          ]),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Image.asset(
            "assets/images/buy_and_sell/sell_poster.png",
            height: Get.width * 0.3,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sell\nYour\nProducts",
                  style: Get.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.currentTheme.colorScheme.secondary,
                  ),
                ),
                FittedBox(
                  child: Text(
                    "in your local vicinity",
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppTheme.currentTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
